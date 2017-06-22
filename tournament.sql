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

CREATE TABLE matches ( player1 INTEGER,
					   player2 INTEGER,
					   winner INTEGER,
                       round INTEGER );

CREATE VIEW standings AS
WITH subq as
	(SELECT id, name, count(winner) as loses, count(round) as matches
	FROM players, matches
	WHERE id != winner
	AND (id = player1 or id = player2)
	GROUP BY id, name, round)
SELECT p.id as id, p.name as name, (count(m.winner) - s.loses) as wins, (m.round + s.matches) as matches
FROM players as p, matches as m, subq as s
WHERE s.id = p.id
AND p.id = m.winner
GROUP BY p.id, p.name, s.loses, m.round, s.matches;



OR id = player1
OR id = player2
-- WITH subq as
-- (select * from players, matches where id = player1 or id = player2)
-- SELECT id, name, wins, round
-- FROM subq
-- WHERE 

-- WITH subq as
--     (SELECT id, ROW_NUMBER()
--      OVER (ORDER BY id ASC)
--      FROM players)
-- INSERT INTO matches (player1, player2, winner, round)
-- SELECT a.id as player1, b.id as player2, NULL as winner, 1 as round
-- FROM subq as a, subq as b
-- WHERE a.row_number+1 = b.row_number
-- AND (a.row_number % 2) = 1
-- AND (b.row_number % 2) = 0;