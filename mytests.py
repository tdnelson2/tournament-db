import tournament

tournament.deletePlayers()
tournament.deleteMatches()

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