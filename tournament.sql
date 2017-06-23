-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

DROP DATABASE IF EXISTS tournament;

CREATE DATABASE tournament;

\c tournament;

CREATE TABLE players ( name TEXT,
                       id SERIAL );

CREATE TABLE matches ( winner INTEGER,
					   loser INTEGER);


CREATE VIEW standings AS
    SELECT
        players.id,
        players.name,
        COUNT(m1.winner) AS wins,
        COUNT(m2.winner)+COUNT(m3.loser) AS totalplayed
    FROM
        players
        LEFT JOIN matches as m1
        ON players.id = m1.winner
        LEFT JOIN matches as m2
        ON players.id = m2.winner
        LEFT JOIN matches as m3
        ON players.id = m3.loser
        GROUP BY players.id, players.name
        ORDER BY COUNT(m1.winner) DESC;

