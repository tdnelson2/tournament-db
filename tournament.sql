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
    WITH uni AS
    (
	WITH combos AS
		(
		WITH combos AS
			(
			WITH subq AS
				(
				SELECT
				 	a.id as id1,
				 	b.id as id2,
				 	ROW_NUMBER() OVER (ORDER BY a.id ASC)
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
			occurance = 1
    )
    SELECT
    	*
    FROM
    	uni
    WHERE
    	id1 NOT IN (SELECT
				        id1
				    FROM
				        uni a
				    WHERE
				    	id1 > id2
				    	AND
				    	EXISTS (SELECT *
				    			FROM uni b
				    			WHERE a.id1 = b.id2))
    	AND
    	id2 NOT IN (SELECT
				        id2
				    FROM
				        uni a
				    WHERE
				    	id1 > id2
				    	AND
				    	EXISTS (SELECT *
				    			FROM uni b
				    			WHERE a.id1 = b.id2));







-- objective:
-- get rid of mirrored duplicates
-- get rid of rows where id occures in 2 columns keeping the row where the pair id only occures in one column
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
					id1,
					id2
				FROM
					sq
				WHERE
					-- remove possible match combinations that have already been played
					NOT EXISTS (SELECT
							        1
							    FROM
							        matches
							    WHERE
							    	(sq.id1 = matches.winner
							    	AND
							    	sq.id2 = matches.loser)
							    	OR
							    	(sq.id2 = matches.winner
							    	AND
							    	sq.id1 = matches.loser))
		)
		SELECT
			id1,
			id2,
			ROW_NUMBER() OVER (ORDER BY id1 DESC)
		FROM
			sq2
	)
	SELECT
		a.id1,
		a.id2,
		ROW_NUMBER() OVER (PARTITION BY id1 ORDER BY id1 DESC) as occurance
	FROM
		sq3 a
	WHERE
		NOT EXISTS (WITH minisq AS
					( -- limit to everything up to the current row
						SELECT *
						FROM sq3 b
						LIMIT a.row_number
					)
					SELECT
						1
					FROM
						minisq c
					WHERE
					a.id2 = c.id1
					)
	ORDER BY
		a.id2 DESC
)
SELECT
	id1,
	id2
FROM
	sq4
WHERE
	occurance = 1
ORDER BY
	id2 ASC;





WITH sq AS
    ( -- get all possible match combinations
    SELECT
        a.id as id1,
        b.id as id2
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







-- WITH sq3 AS
-- (
-- 	SELECT
-- 	id1,
-- 	id2
-- 	FROM
-- 	(
-- 		SELECT
-- 			id1,
-- 			id2,
-- 		 	ROW_NUMBER() OVER (PARTITION BY id2 ORDER BY id2) as occurance
-- 		FROM
-- 		(
-- 		SELECT
-- 		 	a.id as id1,
-- 		 	b.id as id2,
-- 		 	ROW_NUMBER() OVER (PARTITION BY a.id ORDER BY a.id) as occurance
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
-- 		 ) as sq1
-- 		WHERE
-- 			occurance = 1
-- 	) as sq2
-- 	WHERE
-- 	 occurance = 1
-- )
-- -- objective:
-- -- get rid of mirrored duplicates
-- -- get rid of rows where id occures in 2 columns keeping the row where the pair id only occures in one column
-- SELECT
-- id1,
-- id2
-- FROM
-- sq3
-- WHERE
-- id1 NOT IN (SELECT
-- 			id1
-- 			FROM
-- 			sq3 a
-- 			WHERE
-- 			EXISTS (SELECT *
-- 					FROM sq3 b
-- 					WHERE a.id1 = b.id2)
-- 			AND
-- 			NOT EXISTS (SELECT *
-- 					FROM sq3 b
-- 					WHERE a.id2 = b.id1));




    -- SELECT
    --     *
    -- FROM
    --     uni as a
    --     LEFT JOIN
    --     (SELECT id1 as id3, id2 as id4 FROM uni) as b
    -- ON
    --     a.id1 = b.id4
    --     AND
    --     a.id2 = b.id3;



-- WITH allunique AS
-- (
--     WITH uniqueid2 AS
--     (
--         WITH uniqueid1 AS
--         (
--             SELECT
--                 a.id as id1,
--                 b.id as id2,
--                 ROW_NUMBER() OVER (PARTITION BY a.id ORDER BY b.id) as occurance
--              FROM
--                 standings as a, standings as b
--              WHERE
--                 a.wins = b.wins
--                 AND
--                 a.totalplayed = b.totalplayed
--                 AND
--                 a.id != b.id
--              ORDER BY
--                 a.id DESC
--         )
--         SELECT
--             id1,
--             id2
--         FROM
--             uniqueid1
--         WHERE
--             occurance = 1
--     )
--     SELECT
--         id1,
--         id2,
--         ROW_NUMBER() OVER (PARTITION BY id2 ORDER BY id2) as occurance
--     FROM
--         uniqueid2;
-- )
-- SELECT
--     id1,
--     id2
-- FROM
--     allunique
-- WHERE
--     occurance = 1;

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






