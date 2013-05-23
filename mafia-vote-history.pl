#!/usr/bin/env perl
# Get vote history in Mafia games

use Mojo::Base -strict;

BEGIN {
	our $usage = "usage: $0 thread host [startdate]";
	our $thread = shift;
	our $host = shift or say $usage and exit(1);
}

use HoNForum -wrapper;
our ($dbh, $thread, $host);

my $gamedate = shift || "Night 1";
my $gamedate_qr = qr/\b(?:Day|Night) \d+\b/i;
if ($gamedate !~ $gamedate_qr) {
	say "Bad gamedate: `$gamedate`";
	exit(1);
}

my $sth = $dbh->prepare('SELECT * FROM posts WHERE thread = ?');
$sth->execute($thread);

my %votes;
while (my $post = $sth->fetchrow_hashref) {
	my $dom = Mojo::DOM->new($post->{body});

	if ($post->{user} eq $host) {
		my $text = $dom->all_text;
		while ($text =~ /It is now ($gamedate_qr)|($gamedate_qr) has (begun|ended)/ig) {
			$gamedate = $1 || $2;
			$gamedate =~ s/Night/Day/; # TheJoo liked not marking the
			                           # start of new days for some reason...
			%votes = ();
		}
	}

	$dom->find('.bbcode_quote')->each(sub { $_->parent->remove });
	$dom->find('font[color]')->each(sub {
		return unless $_->attrs('color') =~ /lime|#00ff00/i;
		my $text = $_->all_text;
		while ($text =~ /(un)?vote \b (?: [ ]? (\w{1,12}) \b )?/ixg) {
			if (defined(my $vote = $votes{$post->{user}})) {
				delete $votes{$post->{user}};
				printf "%s [%s] %12s unvoted %s\n", $gamedate,
						format_timestamp($post->{created}), $post->{user}, $vote;
			}
			if (!defined $1 && defined $2) {
				$votes{$post->{user}} = $2;
				printf "%s [%s] %12s voted   %s\n", $gamedate,
						format_timestamp($post->{created}), $post->{user}, $2;
			}
		}
	});
}
