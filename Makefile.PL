use inc::Module::Install;

name 'Package-FromData';
all_from 'lib/Package/FromData.pm';

requires 'Readonly';
requires 'Test::Deep::NoTest';

build_requires 'Test::More';
build_requires 'Test::Exception';
build_requires 'ok';

WriteAll();
