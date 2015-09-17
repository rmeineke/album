#!/usr/bin/perl
use strict;
use warnings;
my @letters = qw(a b c d e f g h i j k l m n o p q r s t u v w x y z);
my $range = 25;

my $random_number = int(rand($range));

print $random_number . "\n";
print $letters[$random_number] . "\n";


