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
                       id SERIAL,
                       PRIMARY KEY (id));

CREATE TABLE matches ( winner INTEGER REFERENCES players (id),
					   loser INTEGER REFERENCES players (id),
					   PRIMARY KEY (winner, loser));


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
            players.id, COUNT(m2.loser) AS loses
        FROM
            players
        LEFT JOIN
            (SELECT loser FROM matches) AS m2
        ON players.id = m2.loser
        GROUP BY players.id
        )
        AS b
    ON a.id = b.id
    GROUP BY a.id, a.name
    ORDER BY SUM(a.wins) DESC;



CREATE VIEW pairup AS
	SELECT
			a.id1 id1,
			b.name name1,
			a.id2 id2,
			c.name name2
		FROM
		(
		WITH sq4 AS
		(
			WITH sq3 AS
			(
				WITH sq2 AS
				(
				WITH sq AS
				    ( -- get all possible match combinations
				    SELECT
				        a.id as id1,
				        b.id as id2,
				        a.wins,
				        a.totalplayed,
						ROW_NUMBER() OVER (ORDER BY a.wins, a.totalplayed)
				     FROM
				        standings a
				        LEFT JOIN
				        standings b
				     ON
				        a.wins = b.wins
				        AND
				        a.totalplayed = b.totalplayed
				        AND
				        a.id != b.id
				        AND
				        -- remove possible match combinations that have already been played
				        NOT EXISTS (SELECT
				                        1
				                    FROM
				                        matches
				                    WHERE
				                        (a.id = matches.winner
				                        AND
				                        b.id = matches.loser)
				                        OR
				                        (b.id = matches.winner
				                        AND
				                        a.id = matches.loser))
				     ORDER BY
				        a.wins, a.totalplayed
				    )
				    SELECT
					    id1,
					    id2,
					    wins,
					    totalplayed,
					    -- ROW_NUMBER() OVER (PARTITION BY id1) as occurance
					    -- ROW_NUMBER() OVER (PARTITION BY id1 ORDER BY wins, totalplayed) as occurance
					    ROW_NUMBER() OVER (ORDER BY wins, totalplayed)
				    FROM
					    sq a
				    WHERE
				    	-- remove inverted duplicates
						NOT EXISTS (WITH minisq AS
								( -- limit to everything up to the current row
									SELECT *
									FROM sq b
									LIMIT a.row_number
								)
								SELECT
									1
								FROM
									minisq c
								WHERE
								a.id2 = c.id1
								AND
								a.id1 = c.id2
								)
				     ORDER BY
				        wins, totalplayed
				)
				SELECT
					id1,
					id2,
					wins,
					totalplayed,
				    ROW_NUMBER() OVER (PARTITION BY id1 ORDER BY row_number) as occurance
				FROM
					sq2
				ORDER BY
					row_number
			)
			SELECT
				id1,
				id2,
				wins,
				totalplayed,
			    ROW_NUMBER() OVER (ORDER BY wins, totalplayed)
			FROM
				sq3
			WHERE
				occurance = 1
			ORDER BY
				wins, totalplayed
		)
		SELECT
			id1,
			id2,
			wins,
			totalplayed,
			row_number
		FROM
			sq4 a
		WHERE
			-- remove rows with values in column 2 that exist in column 1
			-- this should be the case for win-totalplayed 
			NOT EXISTS (WITH minisq AS
		    		   ( -- group all the pairs by totalplayed, wins 
					   	SELECT b.id1, b.id2, ROW_NUMBER() OVER (ORDER BY row_number) as inner_rn
						   FROM sq4 b
						   WHERE
							   a.wins = b.wins
							   AND a.totalplayed = b.totalplayed
						   ORDER BY
							   b.id2 >= b.id1
						)
						SELECT
							1
						FROM
							minisq c
						WHERE
						a.id1 = c.id1
						AND a.id2 = c.id2
						-- return true only if it's an odd row (within the win-totalplayed group)
						AND (c.inner_rn % 2) = 0
						)
		) a, players b, players c
		WHERE
			a.id1 = b.id
			AND
			a.id2 = c.id;


