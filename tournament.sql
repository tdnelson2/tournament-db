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

CREATE TABLE pairings ( id1 INTEGER UNIQUE,
					   id2 INTEGER UNIQUE,
					   UNIQUE (id1, id2));


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
		evenid as id1,
		p1.name as name1,
		oddid as id2,
		p2.name as name2
	FROM
	players AS p1,
	players AS p2,
	(
		WITH subq AS
		(
		SELECT
	        id, wins, totalplayed, ROW_NUMBER()
	        OVER (ORDER BY wins DESC)
	    FROM standings
		)
	    SELECT
	        a.id AS evenid,
	        a.wins AS evenwins,
	        a.totalplayed AS eventotalplayed,
	        b.id AS oddid,
	        b.wins AS oddwins,
	        b.totalplayed AS oddtotalplayed
	    FROM
	        subq as a, subq as b
	    WHERE
	        a.row_number+1 = b.row_number
	        AND (a.row_number % 2) = 1
	        AND (b.row_number % 2) = 0
    )
    AS
	    div
    WHERE
    	evenwins = oddwins
    	AND
    	eventotalplayed = oddtotalplayed
    	AND
    	evenid = p1.id
    	AND
    	oddid = p2.id
    ORDER BY
    	evenwins DESC;



-- WITH subq AS
-- 	(
-- 	WITH subq AS
-- 		(
-- 		SELECT
-- 	        id, wins, totalplayed, ROW_NUMBER()
-- 	        OVER (ORDER BY id ASC)
-- 	    FROM standings
-- 		)
-- 	SELECT
-- 	 	a.id as id1,
-- 	 	b.id as id2
-- 	 FROM
-- 	 	subq as a, subq as b
-- 	 WHERE
-- 	 	a.wins = b.wins
-- 	 	AND
-- 	 	a.totalplayed = b.totalplayed
-- 	 	AND
-- 	 	b.row_number > a.row_number
-- 	 ORDER BY
-- 	 	a.id DESC
-- 	)
-- SELECT
-- 	min(id1),
-- 	id2
-- FROM
-- 	subq
-- GROUP BY
-- 	id2;

-- -------
CREATE VIEW pairupv2 AS
	WITH combos AS
		(
		WITH combos AS
			(
			WITH subq AS
				(
				SELECT
				 	a.id as id1,
				 	b.id as id2
				 FROM
				 	standings as a, standings as b
				 WHERE
				 	a.wins = b.wins
				 	AND
				 	a.totalplayed = b.totalplayed
				 	AND
				 	a.id != b.id
				 ORDER BY
				 	a.id DESC
				 )
				SELECT
				        id1, id2, ROW_NUMBER()
				        OVER (ORDER BY id1 ASC)
				FROM subq
			)
			SELECT
				c1.id1,
				c1.id2,
				-- https://stackoverflow.com/questions/15814400/remove-rows-with-duplicate-values
				ROW_NUMBER() OVER (PARTITION BY c1.id2 ORDER BY c1.id2) as occurance
			FROM
				combos AS c1,
				(
					SELECT
						id1,
						min(row_number) as row_number
					FROM
						combos
					GROUP BY
						id1
				)
				AS c2
			WHERE
				c1.row_number = c2.row_number
			ORDER BY
				c1.id2
		)
		SELECT
			id1,
			id2
		FROM
			combos
		WHERE
			occurance = 1;



-- __________

--     WITH subq AS
--     	(
-- 		SELECT
-- 		 	a.id as id1,
-- 		 	b.id as id2
-- 		 FROM
-- 		 	standings as a, standings as b
-- 		 WHERE
-- 		 	a.wins = b.wins
-- 		 	AND
-- 		 	a.totalplayed = b.totalplayed
-- 		 	AND
-- 		 	a.id != b.id
-- 		 ORDER BY
-- 		 	a.id DESC
-- 		 )
-- 	SELECT
-- 		min(id1) as id1,
-- 		min(id2) as id2
-- 	FROM subq
-- 	GROUP BY
-- 		id1,
-- 		id2;






