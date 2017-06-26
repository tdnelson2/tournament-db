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
        a.id,
        a.name,
        SUM(a.wins) AS wins,
        SUM(b.loses)+SUM(a.wins) AS totalplayed
    FROM
        (
        SELECT 
            players.id, players.name, COUNT(m1.winner) AS wins 
        FROM 
            players
        LEFT JOIN 
            (SELECT winner FROM matches) AS m1
        ON players.id = m1.winner
        GROUP BY players.id, players.name
        ) 
        AS a
    LEFT JOIN
        (
        SELECT 
            players.id, players.name, COUNT(m2.loser) AS loses 
        FROM 
            players
        LEFT JOIN 
            (SELECT loser FROM matches) AS m2
        ON players.id = m2.loser
        GROUP BY players.id, players.name
        ) 
        AS b
    ON a.id = b.id
    GROUP BY a.id, a.name
    ORDER BY SUM(a.wins) DESC;