import tournament
import tournament_test

# tournament.deletePlayers()
# tournament.deleteMatches()

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
             "Wheelock"]:
    tournament.registerPlayer(name)

tournament.initialPairUp()

for result in [(1, 2), 
			   (3, 4), 
			   (5, 6), 
			   (7, 8), 
			   (9, 10), 
			   (11, 12)]:
	tournament.reportMatch(*result)

# tournament_test.testCount()