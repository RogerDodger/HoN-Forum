package main;

use Mojo::Base -strict;
use DBI;
use DateTime::TimeZone;
use List::Util qw/min max/;

our ($thread, $wrapper, $dbh, %switch);

BEGIN {
	our %switch;
	chomp(our $usage ||= <<"USAGE");
usage: $0 [-hq] thread

options:
    -h    Display this help message
    -q    Don't print header/footer
USAGE

	while (defined $ARGV[0] && substr($ARGV[0], 0, 1) eq '-') {
		%switch = (%switch, map { $_ => 1 } split //, substr shift, 1);
	}

	if (defined $switch{h}) {
		say $usage;
		exit(1);
	}

	our $thread ||= shift or say $usage and exit(1);

	if ($thread =~ /[^0-9]/) {
		say "Invalid thread: `$thread`. Must be an integer";
		exit(1);
	}

	$ENV{TZ} //= 'UTC';
	if (!DateTime::TimeZone->is_valid_name($ENV{TZ})) {
		say "Invalid timezone: `$ENV{TZ}`.";
		exit(1);
	}

	if (!-e 'HoN-Forum.db') {
		say "Database `HoN-Forum.db` not found. Create it with `schema.sql`.";
		exit(1);
	}

	our $dbh = DBI->connect('dbi:SQLite:HoN-Forum.db', '', '', {
		RaiseError => 1,
		AutoCommit => 0,
		sqlite_unicode => 1,
	});
}

use Mojo::UserAgent;
use DateTime;
use DateTime::Format::ISO8601;

sub format_timestamp {
	my $timestamp = shift;
	my $fmt = shift || '%d %b %Y %H:%M';
	return DateTime::Format::ISO8601
			->parse_datetime($timestamp)
			->set_time_zone($ENV{TZ})
			->strftime($fmt);
}

sub rgb {
	my $attr = lc shift // '';
	$attr =~ s/^#//;
	$attr =~ s/[^a-f0-9]/0/g;

	$attr .= '0' while length($attr) % 3;
	if (length $attr == 3) {
		substr($attr, $_, 0, '0') for 0, 2, 4;
	}

	my $sep = length($attr) / 3;
	my $len = min(8, $sep);
	my $offset = max($sep - 8, 0);
	return map {
		hex substr substr($attr, $_ + $offset, $len), 0, 2
	} 0, $sep, 2 * $sep;
}

sub is_lime {
	my $attr = shift;
	$attr =~ s/ +/ /g;
	$attr =~ s/^ | $//g;

	return 1 if $attr =~ /^lime$/i;

	my ($r, $g, $b) = rgb($attr);
	return $g > 225
	    && $r < 33
	    && $b < 33
	    && abs($r - $b) < 25
	;
}

sub header {
	my $sth = $dbh->prepare('SELECT title FROM threads WHERE id = ?');
	$sth->execute($thread);
	my $header = $sth->fetchrow_array . " (id: $thread)";
	$sth->finish;
	return $header;
}

sub footer {
	my $sth = $dbh->prepare('SELECT retrieved FROM threads WHERE id = ?');
	$sth->execute($thread);
	my $footer = "Data retrieved " . format_timestamp($sth->fetchrow_array, '%d %b %Y %H:%M %z');
	$sth->finish;
	return $footer;
}

END {
	return if $? != 0;

	if ($wrapper) {
		say q{};
		say footer;
	}
	$dbh->disconnect;
}

package HoNForum;

sub import {
	my $class = shift;
	return unless my $flag = shift;

	if ($flag eq '-wrapper') {
		my $sth = $main::dbh->prepare('SELECT COUNT(*) FROM posts WHERE thread = ?');
		$sth->execute($main::thread);
		if ($sth->fetchrow_arrayref->[0] == 0) {
			say "No data for thread `$thread`. Try running `scrape.pl` first.";
			exit(1);
		}

		unless ($main::switch{q}) {
			my $header = main::header;
			say $header;
			say '=' x length $header;
			say q{};
			$main::wrapper = 1;
		}
	}
}

1;
