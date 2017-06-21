import tournament

# tournament.registerPlayer('Will Nelson')
# tournament.deletePlayers()

# for name in ["Bakker",
#              "Goan",
#              "Hochstein",
#              "Kliewer",
#              "Langford",
#              "McFarland",
#              "Montgomery",
#              "Nelson",
#              "Ott",
#              "Prasoloff",
#              "Vlad",
#              "Wheelock"]:
#     tournament.registerPlayer(name)

for tup in tournament.dirtyPairUp():
    print tup[0]