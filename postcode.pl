#!/usr/bin/perl

#Use Postcode module for object
use postcode;

#CSV File lists outcodes in uppercase
#Find matches from command line with regexp
my $input = uc(join("",@ARGV));
my @postCodes = ($input =~ m/[A-Z]{1,2}[0-9]{1,2}[A-Z]?\s?[0-9][A-Z]{2}/g);

my $nargs = scalar(@postCodes);

#Check for two postcodes
if($nargs!=2)
{
	print "postcode.pl finds the distance between 2 postcodes\n",
				"Usage: postcode.pl XXXNNN YYYNNN\n",
				"where XXXNNN is the first postcode\n",
				"and YYYNNN is the second.\n";
	exit;
}

my $fromPostcode = new postcode($postCodes[0]);

my $distance = $fromPostcode->distanceTo($postCodes[1]);
$distance = sprintf("%.2f", $distance);

print "The distance from $postCodes[0] to $postCodes[1] is $distance","km\n";

exit;
