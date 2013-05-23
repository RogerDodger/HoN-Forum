-- SQL database to store threads and posts

DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS threads;

CREATE TABLE threads (
	id         INTEGER,
	title      TEXT,
	retrieved  TIMESTAMP
);

CREATE TABLE posts (
	id         INTEGER PRIMARY KEY,
	thread     INTEGER,
	user       TEXT,
	body       TEXT,
	wordcount  INTEGER,
	created    TIMESTAMP,
	retrieved  TIMESTAMP
);
