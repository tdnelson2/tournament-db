-- Table definitions for the tournament project.


DROP DATABASE IF EXISTS tournament;

CREATE DATABASE tournament;

\c tournament;

CREATE TABLE players ( name TEXT,
                       id SERIAL,
                       PRIMARY KEY (id) );

CREATE TABLE matches ( winner INTEGER REFERENCES players (id),
					   loser INTEGER REFERENCES players (id) );


-- show how each player is doing sorted by number of games played and wins

CREATE VIEW standings AS
    SELECT
        player_wins.id,
        player_wins.name,
        SUM(player_wins.wins) AS wins,
        SUM(player_loses.loses)+SUM(player_wins.wins) AS totalplayed
    FROM
    	-- add up wins for each player (players may appear twice)
        (
        SELECT
            players.id, players.name, COUNT(matches.winner) AS wins
        FROM
            players
        LEFT JOIN 
        	matches
        ON players.id = matches.winner
        GROUP BY players.id, players.name
        )
        AS player_wins
    LEFT JOIN
    	-- add up loses for each player
        (
        SELECT
            players.id, COUNT(matches.loser) AS loses
        FROM
            players
        LEFT JOIN
            matches
        ON players.id = matches.loser
        GROUP BY players.id
        )
        AS player_loses
    ON player_wins.id = player_loses.id
    GROUP BY player_wins.id, player_wins.name
    ORDER BY SUM(player_wins.wins) DESC;



-- inject row count into the standings table
CREATE VIEW enumerated_standings AS
	SELECT
		ROW_NUMBER() OVER(),
		*
	FROM
		standings;

-- standings from rows 2, 4, 6, 8, etc in the standings view
CREATE VIEW even_standings AS
	SELECT
		ROW_NUMBER() OVER() even_row_number,
		*
	FROM
		enumerated_standings
	WHERE
		(enumerated_standings.row_number % 2) = 0;

-- standings from rows 1, 3, 5, 7, etc in the standings view
CREATE VIEW odd_standings AS
	SELECT
		ROW_NUMBER() OVER() odd_row_number,
		*
	FROM
		enumerated_standings
	WHERE
		(enumerated_standings.row_number % 2) = 1;

-- create match ups with players who have the most simular win records
CREATE VIEW pairup AS

	SELECT
		standings_a.id id1,
		standings_a.name name1,
		standings_b.id id2,
		standings_b.name name2
	FROM
		odd_standings standings_a, even_standings standings_b
	WHERE
		-- each adjacent row from standings becomes a match
		standings_a.odd_row_number = standings_b.even_row_number;







