#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 2;
use Package::FromData;

my $data = {
    'Test::Package' => {
        functions => {
            constant => '42',
        },
    },
};

create_package_from_data($data);

is Test::Package::constant(),   '42';
is Test::Package::constant(12), '42';
