package Plugins::GoogleMusic::GoogleAPI;

use strict;
use warnings;
use File::Spec::Functions;

my $inlineDir;
my $googleapi = Plugins::GoogleMusic::GoogleAPI::Mobileclient->new(0, 0);

sub get {
	return $googleapi;
}

sub get_device_id {
	my ($username, $password) = @_;

	my $id;

	my $webapi = Plugins::GoogleMusic::GoogleAPI::Webclient->new(0, 0);
	if (!$webapi->login($username, $password)) {
		return;
	}

	my $devices = $webapi->get_registered_devices();
	for my $device (@$devices) {
		if ($device->{type} eq 'PHONE' and $device->{id} =~ /^0x/) {
			# Omit the '0x' prefix
			$id = substr($device->{id}, 2);
			last;
		} elsif ($device->{type} eq 'IOS' and $device->{id} =~ /^ios:/) {
			# Omit the 'ios:' prefix
			$id = substr($device->{id}, 4);
			last;
		}
	}

	$webapi->logout();
	return $id;
}

BEGIN {
	$inlineDir = catdir(Slim::Utils::Prefs::preferences('server')->get('cachedir'), '_Inline');
	mkdir $inlineDir unless -d $inlineDir;
}

use Inline (Config => DIRECTORY => $inlineDir);
use Inline Python => <<'END_OF_PYTHON_CODE';

import gmusicapi
from gmusicapi import Mobileclient, Webclient, CallFailure

def get_version():
	return gmusicapi.__version__

END_OF_PYTHON_CODE


1;
