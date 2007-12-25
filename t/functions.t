#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 12;
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
            subtract  => [
                [1, 2] => '-1',
                [2, 1] => '1',
                42
            ],
            reftest => [
                [{foo => 'bar'}] => 'foo bar',
                [[qw/foo baz/]]  => 'foo baz',
                'fallback',
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

is Test::Package::subtract(), 42;
is Test::Package::subtract(1, 2), '-1';
is Test::Package::subtract(2, 1), '1';
is Test::Package::subtract(2, 2), 42;

is Test::Package::reftest(), 'fallback';
is Test::Package::reftest({foo => 'bar'}), 'foo bar';
is Test::Package::reftest([foo => 'baz']), 'foo baz';
