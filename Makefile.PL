use inc::Module::Install;

name 'Redis-Key';
all_from 'lib/Redis/Key.pm';

tests 't/*.t';
author_tests 'xt';

auto_include;
do 'cpanfile';
WriteAll;
