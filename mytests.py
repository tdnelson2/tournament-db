import tournament
import tournament_test

# tournament.deletePlayers()
# tournament.deleteMatches()
# tournament_test.testCount()
# tournament_test.testStandingsBeforeMatches()
# tournament_test.testReportMatches()
# tournament_test.testPairings()

###### PLAYERS

for name in ["Bakker",
             "Goan",
             "Hochstein",
             "Kliewer",
             "Langford",
             "McFarland",
             "Montgomery",
             "Nelson",
             "Ott",
             "Prasoloff",
             "Vlad",
             "Wheelock",
             "Day",
             "Ferguson",
             "Stevens",
             "Maesaya"]:
    tournament.registerPlayer(name)

##### 1ST ROUND

for result in [(1, 2),
			   (3, 4),
			   (5, 6),
			   (7, 8),
			   (9, 10),
			   (11, 12),
			   (13, 14),
			   (15, 16)]:
	tournament.reportMatch(*result)

pairings = tournament.swissPairings()
print str(len(pairings)) + " pairings found"
print pairings

##### 2ND ROUND

for result in [(4, 2),
			   (6, 8),
			   (12, 10),
			   (14, 16),
			   (1, 3),
			   (7, 5),
			   (9, 11),
			   (13, 15)]:
	tournament.reportMatch(*result)

pairings = tournament.swissPairings()
print str(len(pairings)) + " pairings found"
print pairings

##### 3RD ROUND

for result in [(8, 2),
			   (16, 10),
			   (4, 3),
			   (5, 6),
			   (11, 12),
			   (15, 14),
			   (1, 7),
			   (9, 13)]:
	tournament.reportMatch(*result)

pairings = tournament.swissPairings()
print str(len(pairings)) + " pairings found"
print pairings

###### 4TH ROUND

for result in [(10, 2),
			   (3, 6),
			   (8, 12),
			   (16, 14),
			   (5, 4),
			   (11, 7),
			   (13, 15),
			   (9, 1)]:
	tournament.reportMatch(*result)

pairings = tournament.swissPairings()
print str(len(pairings)) + " pairings found"
print pairings