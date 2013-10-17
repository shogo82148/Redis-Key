requires 'perl', '5.008001';

on 'test' => sub {
   requires 'Redis';
   requires 'Test::More';
   requires 'Test::Exception';
   requires 'File::Temp';
   requires 'Test::RedisServer';
};
