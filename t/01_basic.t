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

subtest 'list' => sub {
    my $key = Redis::Key->new(redis => $redis, key => 'hoge');

    ok($key->rpush('one'), 'rpush one');
    ok($key->rpush('two'), 'rpush two');
    ok($key->rpush('three'), 'rpush three');

    my $s = $key->lrange(-3, 2);
    is_deeply($s, ['one', 'two', 'three'], 'scalar context');

    my @l = $key->lrange(-3, 2);
    is_deeply([@l], ['one', 'two', 'three'], 'list context');
};

subtest 'bind' => sub {
    my $key = Redis::Key->new(redis => $redis, key => 'hoge:{fugu}:piyo', need_bind => 1);
    $redis->set('hoge:FUGU:piyo', 'foobar');

    throws_ok {
        $key->get;
    } qr/needs bind/, 'needs bind';

    throws_ok {
        $key->bind;
    } qr/not passed/, 'not passed';

    my $key_bound = $key->bind(fugu => 'FUGU');
    ok($key_bound, 'bind');
    is($key_bound->get, 'foobar', 'get');

    $redis->flushall;
};

subtest 'keys' => sub {
    $redis->set("hoge:$_:piyo", 'foobar') for (1..10);
    $redis->set("Hoge:$_:piyo", 'foobar') for (1..10);
    my $key = Redis::Key->new(redis => $redis, key => 'hoge:{fugu}:piyo', need_bind => 1);
    my @keys = $key->keys;
    is_deeply([sort $key->keys], [sort map {"hoge:$_:piyo"} (1..10)], 'keys');
    is(scalar $key->keys, 10, 'keys count');

    $redis->flushall;
};


subtest 'keys for normal key' => sub {
    my $key = Redis::Key->new(redis => $redis, key => 'hoge:{fugu}:piyo');
    my @keys = $key->keys;
    is_deeply([sort $key->keys], [ "hoge:{fugu}:piyo" ], 'keys');
    is(scalar $key->keys, 1, 'keys count');

    $redis->flushall;
};

done_testing;

