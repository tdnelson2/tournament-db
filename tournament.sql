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
					   winner INTEGER );


CREATE VIEW standings AS
    SELECT 
        players.id, 
        players.name, 
        COUNT(matches.winner) AS wins, 
        m.count AS totalplayed
    FROM 
        players 
        LEFT JOIN matches 
        ON players.id = matches.winner
        LEFT JOIN 
            (SELECT id, COUNT(*) 
             FROM players, matches 
             WHERE 
                player1 = id 
             OR 
                player2 = id 
             GROUP BY players.id) 
             AS m 
        ON players.id = m.id
        GROUP BY players.id, players.name, m.count
        ORDER BY players.id ASC;