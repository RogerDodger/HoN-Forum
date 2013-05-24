#!/usr/bin/env perl
# Output the last post and post count for each user in thread

use Mojo::Base -strict;
use HoNForum -wrapper;
our ($dbh, $thread);

my $sth = $dbh->prepare(q{
	SELECT
		me.user AS name,
		(SELECT MAX(created) FROM posts WHERE user = me.user AND thread = me.thread) AS last_post,
		(SELECT COUNT(*) FROM posts WHERE user = me.user AND thread = me.thread) AS post_count,
		(SELECT SUM(wordcount) FROM posts WHERE user = me.user AND thread = me.thread) AS wc_sum
	FROM
		posts me
	WHERE
		thread = ?
	GROUP BY
		name
	ORDER BY
		last_post DESC
});
$sth->execute($thread);

say '     Username  Last post          Total posts  Wordcount';
say '--------------------------------------------------------';
while (my $user = $sth->fetchrow_hashref) {
	printf " %12s  %17s  %-11d  %-9d\n",
			$user->{name},
			format_timestamp($user->{last_post}),
			$user->{post_count}, $user->{wc_sum};
}
$sth->finish;
