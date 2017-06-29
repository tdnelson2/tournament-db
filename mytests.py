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
print pairings

#### 2ND ROUND

for result in [(4, 2), (14, 10), (12, 8), (16, 6), (7, 15), (11, 1), (9, 5), (3, 13)]:
	tournament.reportMatch(*result)

pairings = tournament.swissPairings()
print pairings

##### 3RD ROUND

for result in [(2, 10), (6, 8), (4, 1), (14, 16), (13, 5), (12, 15), (9, 11), (3, 7)]:
	tournament.reportMatch(*result)

pairings = tournament.swissPairings()
print pairings

# ###### 4TH ROUND

# for result in [(8, 10), (6, 15), (2, 5), (1, 16), (11, 7), (7, 14), (4, 13), (9, 3)]:
# 	tournament.reportMatch(*result)

# pairings = tournament.swissPairings()
# print str(len(pairings)) + " pairings found"
# print pairings




# tournament.pairup()





