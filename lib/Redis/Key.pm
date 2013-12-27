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

sub wait_all_responses { shift->{redis}->wait_all_responses }
sub wait_one_responses { shift->{redis}->wait_one_response }
sub ping { shift->{redis}->ping }
sub info { shift->{redis}->info }

sub keys {
    my $self = shift;
    my $key = $self->{key};
    if($self->{need_bind}) {
        $key =~ s!{\w+}!*!g;
        my $redis = $self->{redis};
        return $redis->keys($key);
    } else {
        return wantarray ? ($key) : 1;
    }
}

sub scan {
    my ($self, $iter, @args) = @_;
    my $key = $self->{key};
    if($self->{need_bind}) {
        $key =~ s!{\w+}!*!g;
        my $redis = $self->{redis};
        return $redis->scan($iter, @args, MATCH => $key);
    } else {
        return (0, []);
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

      if($self->{need_bind}) {
          croak "$key needs bind";
      }

      $redis->$command($key, @_);
  };

  # Save this method for future calls
  no strict 'refs';
  *$AUTOLOAD = $method;

  goto $method;
}

1;
__END__

=head1

Redis::Key - wrapper class of Redis' key


=head1 SYNOPSIS

  use Redis;
  use Redis::Key;
  my $redis = Redis->new;
  
  # basic usage
  my $key = Redis::Key->new(redis => $redis, key => 'hoge');
  $key->set('fuga');  # => $redis->set('hoge', 'fuga');
  print $key->get;    # => $redis->get('hoge');
  
  # bind
  my $key_unbound = Redis::Key->new(redis => $redis, key => 'hoge:{fugu}:piyo', need_bind => 1);
  my $key_fugu = $key_unbound->bind(fugu => 'FUGU');
  $key_fugu->set('foobar');      # => $redis->set('hoge:FUGU:piyo', 'foobar');
  my @keys = $key_unbound->keys; # => $redis->keys('hoge:*:piyo');


=head1 DESCRIPTION

Redis::Key is a wrapper class of Redis' keys.


=head1 AUTHOR

Ichinose Shogo E<lt>shogo82148@gmail.comE<gt>


=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
