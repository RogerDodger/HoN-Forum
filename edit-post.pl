#!/usr/bin/env perl
# Edits a post with a given message/reason

use Mojo::UserAgent;
use IO::Prompt;
use Mojo::Base -strict;

my $ua = Mojo::UserAgent->new;
my $base_url = 'http://forums.heroesofnewerth.com';

our $usage = <<"USAGE";
usage: $0 post message [reason]

If message is `-`, message is read from STDIN.
USAGE

my $username = $ENV{HON_USERNAME} or die '$ENV{HON_USERNAME} not set';
my $password = $ENV{HON_PASSWORD} or die '$ENV{HON_PASSWORD} not set';

my $id = shift and
my $message = shift or die $usage;
my $reason = shift || '';

if ($message eq '-') {
	$message = do { local $/; <STDIN> };
}

$ua->post("$base_url/login.php", form => {
	do => 'login',
	vb_login_username => $username,
	vb_login_password => $password,
});

my $token = $ua->get("$base_url/index.php")->res->dom
		->at('input[name=securitytoken]')
		->attrs('value');

$ua->post("$base_url/editpost.php", form => {
	do => 'updatepost',
	ajax => 1,
	postid => $id,
	message => $message,
	reason => $reason,
	securitytoken => $token,
});
