#!/usr/bin/env perl
# Scrape a thread and put its posts into the database

use Mojo::Base -strict;
use HoNForum;
use DateTime::Format::Strptime;
our ($dbh, $thread);

my $base_url = "http://forums.heroesofnewerth.com/showthread.php?$thread";
my $ua       = Mojo::UserAgent->new;

# S2 is on Michigan time and forum posts appear in that time zone
my $strptime = DateTime::Format::Strptime->new(
	pattern   => '%m-%d-%Y, %I:%M %p',
	time_zone => 'America/Detroit',
	on_error  => 'croak',
);
my $today     = DateTime->now(time_zone => 'America/Detroit')->mdy;
my $yesterday = DateTime->now(time_zone => 'America/Detroit')->subtract(days => 1)->mdy;

my $insert_post = $dbh->prepare('INSERT INTO posts VALUES (?, ?, ?, ?, ?, ?, ?)');
my $delete_post = $dbh->prepare('DELETE FROM posts WHERE id = ?');

my $insert_thread = $dbh->prepare('INSERT INTO threads VALUES (?, ?, ?)');
my $delete_thread = $dbh->prepare('DELETE FROM threads WHERE id = ?');

my $count = $dbh->prepare('SELECT COUNT(*) FROM POSTS WHERE thread = ?');
my $pages = int(($count->execute($thread) && $count->fetchrow_array) / 20) + 1;
$count->finish;

for (my $page = $pages; $page <= $pages; $page++) {
	say STDERR "Fetching page $page" . ($pages == $page ? '' : " of $pages") . '...';
	my $dom = $ua->get("$base_url/page$page")->res->dom;

	if ($pages == $page) {
		# Last page, check if there are more
		if (defined(my $e = $dom->at('#pagination_top .popupctrl'))) {
			($pages) = $e->text =~ /Page \d+ of (\d+)/;
		}
	}

	$dom->find('.threadtitle')->each(sub {
		$delete_thread->execute($thread);
		$insert_thread->execute($thread, $_->all_text, DateTime->now);
	});

	$dom->find('.postcontainer')->each(sub {
		my $id      = $_->attrs('id') =~ s/^post_//r; #/
		my $user    = $_->at('a.username')->all_text =~ s/^\[.+\]//r; #/
		my $body    = $_->at('.postcontent')->to_xml;
		my $created = $strptime->parse_datetime(
				$_->at('.postdate .date')->all_text
						=~ s/Yesterday/$yesterday/r #/
						=~ s/Today/$today/r         #/
		);
		# Don't want quoted text to be counted in the wordcount
		$_->at('.postcontent')->find('.bbcode_blockquote')->each(sub {
			$_->parent->remove
		});
		my $wordcount = split /\s+/, $_->at('.postcontent')->all_text;

		$delete_post->execute($id);
		$insert_post->execute($id, $thread, $user, $body, $wordcount,
		                      $created->set_time_zone('UTC'), DateTime->now);
	});
}

$dbh->commit;
