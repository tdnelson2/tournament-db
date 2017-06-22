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
					   winner INTEGER);

-- winners:
-- select id, count(*) from players, matches where winner = id group by players.id;

-- matches played:
-- select id, count(*) from players, matches where player1 = id or player2 = id group by players.id;
-- (select id, count(*) from players, matches where player1 = id or player2 = id group by players.id) as m

-- matches lost:
-- select id, count(*) from players, matches where (player1 = id or player2 = id) and winner != id group by players.id;



-- together id, name, wins, matches:
-- select p.id as id, p.name as name, w.count as wins, m.count as total


-- select pl.id, pl.name, m.count as total
-- from players as pl,
--     (select p.id as id, p.name as name, w.count as wins
--     from players as p,
--     (select id, count(*) from players, matches where winner = id group by players.id) as w
--     where p.id = w.id
--     group by p.id, p.name, w.count) as allwins,
--     (select p.id as id, p.name as name, 0 as wins
--     from players as p,
--     (select id, count(*) from players, matches where (player1 = id or player2 = id) and winner != id group by players.id) as l
--     where p.id = l.id
--     group by p.id, p.name) as allloses,
--     (select id, count(*) from players, matches where player1 = id or player2 = id group by players.id) as m
-- where pl.id = allwins.id
-- or pl.id = allloses.id
-- group by pl.id, pl.name, m.count;

