#!/usr/bin/env python
#
# tournament.py -- implementation of a Swiss-system tournament
#

import psycopg2, bleach

def connect():
    """Connect to the PostgreSQL database.  Returns a database connection."""
    return psycopg2.connect("dbname=tournament")


def deleteMatches():
    """Remove all the match records from the database."""
    db = connect()
    c = db.cursor()
    c.execute("DELETE FROM matches;")
    db.commit()
    db.close



def deletePlayers():
    """Remove all the player records from the database."""
    db = connect()
    c = db.cursor()
    c.execute("DELETE FROM players;")
    db.commit()
    db.close


def countPlayers():
    """Returns the number of players currently registered."""
    db = connect()
    c = db.cursor()
    c.execute("SELECT COUNT(*) FROM players;")
    rows = c.fetchall()
    db.commit()
    db.close
    return rows[0][0]


def registerPlayer(name):
    """Adds a player to the tournament database.

    The database assigns a unique serial id number for the player.  (This
    should be handled by your SQL database schema, not in your Python code.)

    Args:
      name: the player's full name (need not be unique).
    """

    db = connect()
    c = db.cursor()
    c.execute("INSERT INTO players (name) values (%s)", (bleach.clean(name),))
    db.commit()
    db.close()

def pairUp():
    db = connect()
    c = db.cursor()
    query = """
    WITH subq as
        (SELECT id, ROW_NUMBER()
         OVER (ORDER BY id ASC)
         FROM players)
    INSERT INTO matches (player1, player2, winner)
    SELECT a.id as player1, b.id as player2, NULL as winner
    FROM subq as a, subq as b
    WHERE a.row_number+1 = b.row_number
    AND (a.row_number % 2) = 1
    AND (b.row_number % 2) = 0;
    """
    c.execute(query)
    db.commit()
    db.close()


def playerStandings():
    """Returns a list of the players and their win records, sorted by wins.

    The first entry in the list should be the player in first place, or a player
    tied for first place if there is currently a tie.

    Returns:
      A list of tuples, each of which contains (id, name, wins, matches):
        id: the player's unique id (assigned by the database)
        name: the player's full name (as registered)
        wins: the number of matches the player has won
        matches: the number of matches the player has played
    """
    db = connect()
    c = db.cursor()
    c.execute("SELECT * FROM standings")
    rows = c.fetchall()
    db.close()
    return rows


def reportMatch(winner, loser):
    """Records the outcome of a single match between two players.

    Args:
      winner:  the id number of the player who won
      loser:  the id number of the player who lost
    """
    w = str(winner)
    l = str(loser)
    db = connect()
    c = db.cursor()
    c.execute("INSERT INTO matches values (%s, %s)" % (w, l))
    db.commit()
    db.close()



def swissPairings():
    """Returns a list of pairs of players for the next round of a match.

    Assuming that there are an even number of players registered, each player
    appears exactly once in the pairings.  Each player is paired with another
    player with an equal or nearly-equal win record, that is, a player adjacent
    to him or her in the standings.

    Returns:
      A list of tuples, each of which contains (id1, name1, id2, name2)
        id1: the first player's unique id
        name1: the first player's name
        id2: the second player's unique id
        name2: the second player's name
    """
    db = connect()
    c = db.cursor()
    c.execute("SELECT max(totalplayed) FROM standings;")
    rows = c.fetchall()
    maxRoundsPlayed = rows[0][0]
    print "maxRoundsPlayed"
    print maxRoundsPlayed
    c.execute("SELECT max(wins) FROM standings;")
    rows = c.fetchall()
    maxWins = rows[0][0]
    print "maxWins"
    print maxWins
    query = """
    WITH sq AS
        (SELECT id, name, ROW_NUMBER() OVER (ORDER BY id ASC) FROM (SELECT id, name FROM standings WHERE wins = {wins} and totalplayed = {totalplayed}) as sg)
    SELECT
        a.id AS id1,
        a.name AS name1,
        b.id AS id2,
        b.name AS name2
    FROM
        sq as a, sq as b
    WHERE
        a.row_number+1 = b.row_number
        AND (a.row_number % 2) = 1
        AND (b.row_number % 2) = 0;
    """
    pairings = []
    for x in range(maxRoundsPlayed+1):
        print "current round target"
        print x
        for y in range(maxWins+1):
            print "current win target"
            print y
            print ""
            c.execute(query.format(wins=str(y), totalplayed=str(x)))
            rows = c.fetchall()
            if rows:
                for row in rows: 
                    pairings.append(row)
    db.close()
    return pairings


