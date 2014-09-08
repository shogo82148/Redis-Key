requires 'perl', '5.008001';
recommends 'Redis';

on 'test' => sub {
   requires 'Test::More';
   requires 'Test::Exception';
   requires 'File::Temp';
   requires 'Test::RedisServer';
   requires 'Test::Kwalitee';
   requires 'Test::Kwalitee::Extra';
};
