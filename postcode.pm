#!/usr/bin/perl

#CSV Listing of postcodes, from http://www.freemaptools.com/download-uk-postcode-lat-lng.htm

package postcode;

#For calculating distances, we need the trig library
use Math::Trig;

#Filename of out-codes, change if necessary
my $outCodes = "postcodes.csv";		

#Set up new object with postcode, if given
sub new
{
	my $class = shift;
	my $self = {
		_postcode => shift
	};
	#Postcodes will be C[C]D[D][C] DCC
	#Where C = Character, D = Digit
	#We can check validity of a postcode
	#Note: this is a simple evaluation and doesn't take into account the full complexity of UK postcodes		
	if($self->{_postcode} !~ m/[A-Z]{1,2}[0-9]{1,2}[A-Z]?\s?[0-9][A-Z]{2}/)
	{
		die("Valid postcode required");
	}
	
	bless $self, $class;
	return $self;
}

#Return the latitude/longitude of a postcode
sub latlon
{
	my ($self) = shift;
	my @location;
	
	#Postcodes are split into in and out codes
	#We are only using the smaller out-codes file
	my $outCode = substr($self->{_postcode},0,-3);
	my $searchStr = ",$outCode,";	

	open(INPUT, $outCodes) or die ("Cannot open $outCodes\n");
	while(my $line = <INPUT>)
	{
		#Trying to find value within comma-separated values
		if(index($line,$searchStr) != -1)
		{
			@location = split(",",$line);
			break;
		}
	}
	close(INPUT);
	
	if(@location)
	{
		return @location[2,3];
	}
	else
	{
		die("No location data for $self->{_postcode}\n");
	}
}

sub distanceTo
{
	my ($self, $toPostcode) = @_;
	
	if(!defined($toPostcode))
	{
		die("You must pass a postcode to distanceTo()\n");
	}
	
	my $toPostcode = new postcode($toPostcode);
	my @toLatLon = $toPostcode->latlon();
	my @fromLatLon = $self->latlon();
	
	#Distance can be worked out a variety of methods
	#Here, we will use Haversines' law of cosines
	#Which is has a high accuracy
	my $radius = 6731; #Radius of earth in km
	my $latDist = deg2rad(@toLatLon[0] - @fromLatLon[0]);
	my $lonDist = deg2rad(@toLatLon[1] - @fromLatLon[1]);
	my $fromLat = deg2rad(@fromLatLon[0]);
	my $toLat = deg2rad(@toLatLon[0]);
	
	my $partA = sin($latDist/2) * sin($latDist/2) +
								sin($lonDist/2) * sin($lonDist/2) *
								cos($fromLat) * cos($toLat);
	my $partB = 2 * atan2(sqrt($partA), sqrt(1-$partA));
	my $distance = $radius * $partB;
		
	return $distance;
}

#Set/return object's postcode
sub setPostcode
{
	my ($self, $newPostcode) = @_;
	$self->{_postcode} = $newPostcode if($newPostcode =~ m/[A-Z]{1,2}[0-9]{1,2}[A-Z]?\s?[0-9][A-Z]{2}/);
	return $self->{_postcode};
}

#Close with true
1;
