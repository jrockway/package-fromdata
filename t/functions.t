#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 5;
use Package::FromData;
use Test::Exception;

my $data = {
    'Test::Package' => {
        functions => {
            constant => '42',
            add      => [
                [1, 1] => '2',
                [2, 2] => '4',
            ],
        },
    },
};

create_package_from_data($data);

is Test::Package::constant(),   '42';
is Test::Package::constant(12), '42';

is Test::Package::add(1,1), '2';
is Test::Package::add(2,2), '4';
throws_ok { Test::Package::add(3,3) }
  qr/add cannot handle \[3 3\] as input/;
