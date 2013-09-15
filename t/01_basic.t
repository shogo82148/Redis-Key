use strict;
use Test::More;
use Redis;
use Test::RedisServer;
use Test::Exception;

use Redis::Key;

my $redis_server = Test::RedisServer->new;
my $redis = Redis->new( $redis_server->connect_info );

subtest 'get/set' => sub {
    my $key = Redis::Key->new(redis => $redis, key => 'hoge');

    ok($key->set('piyo'), 'set');
    is($key->get, 'piyo', 'get');
    is($redis->get('hoge'), 'piyo', 'set result');

    $redis->flushall;
};

subtest 'bind' => sub {
    my $key = Redis::Key->new(redis => $redis, key => 'hoge:{fugu}:piyo', need_bind => 1);
    $redis->set('hoge:FUGU:piyo', 'foobar');

    throws_ok {
        $key->get;
    } qr/needs bind/, 'needs bind';

    my $key_bound = $key->bind(fugu => 'FUGU');
    ok($key_bound, 'bind');
    is($key_bound->get, 'foobar', 'get');
};

done_testing;
