#!/bin/perl
use strict;
use warnings;

my $now = localtime;
print "The date is $now\n";

my %birthdays = (
    "Alice Johnson"   => "15 March 1990",
    "Bob Smith"       => "22 July 1985",
    "Carol Davis"     => "03 November 1992",
    "David Lee"       => "19 January 1988",
    "Eve Martinez"    => "27 September 1995"
);

print "\nList of birthdays:\n";
foreach my $name (keys %birthdays) {
    print "$name: $birthdays{$name}\n";
}

print "\nEnter a full name to look up their birthday: ";
chomp(my $input_name = <STDIN>);

if (exists $birthdays{$input_name}) {
    print "Birthday of $input_name is $birthdays{$input_name}\n";
} else {
    print "Sorry, no birthday found for '$input_name'\n";
}
