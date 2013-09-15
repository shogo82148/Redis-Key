use strict;
use Test::More;
use Redis;
use Test::RedisServer;

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

done_testing;

