package Redis::Key;
use strict;
use warnings;
use Carp;
our $VERSION = '0.01';

use Redis;

sub new {
    my $class = shift;
    my %args = @_;
    my $self  = bless {}, $class;

    $self->{redis} = $args{redis} || Redis->new(%args);
    $self->{key} = $args{key};
    $self->{need_bind} = $args{need_bind};
    return $self;
}

sub redis { shift->{redis} }
sub key { shift->{key} }

sub keys {
    my $self = shift;
    my $key = $self->{key};
    if($self->{need_bind}) {
        $key =~ s!{\w+}!*!g;
        my $redis = $self->{redis};
        return $redis->keys($key);
    } else {
        return ($key);
    }
}

sub bind {
    my $self = shift;
    my $key = $self->{key};
    my %hash = @_;

    $key =~ s!{(\w+)}!
        $hash{$1} // croak("$1 is not passed to $key");
    !eg;

    return __PACKAGE__->new(
        redis     => $self->{redis},
        key       => $key,
        need_bind => 0,
    );
}

sub DESTROY { }

our $AUTOLOAD;
sub AUTOLOAD {
  my $command = $AUTOLOAD;
  $command =~ s/.*://;

  my $method = sub {
      my $self = shift;
      my $redis = $self->{redis};
      my $key = $self->{key};
      my $wantarray = wantarray;

      if($self->{need_bind}) {
          croak "$key needs bind";
      }

      if(!$wantarray) {
          $redis->$command($key, @_);
      } elsif($wantarray) {
          my @result = $redis->$command($key, @_);
          return @result;
      } else {
          my $result = $redis->$command($key, @_);
          return $result;
      }
  };

  # Save this method for future calls
  no strict 'refs';
  *$AUTOLOAD = $method;

  goto $method;
}

1;
__END__

=head1 NAME

Redis::Key -

=head1 SYNOPSIS

  use Redis::Key;

=head1 DESCRIPTION

Redis::Key is

=head1 AUTHOR

Ichinose Shogo E<lt>shogo82148@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
