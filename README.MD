# Tournament Results Database
The purpose of this project is to demonstrate how you can used psql to manage a Swiss Pairing tournament. Databases are particularly usefull for this type of tournament because of it's high levels complexity.

## Installation
* Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* Install [Vagrant](https://www.vagrantup.com/downloads.html)
* Clone [This VM configuration](https://github.com/udacity/fullstack-nanodegree-vm) onto your machine
* You should have a folder named `FSND-Virtual-Machine` with another one named `vagrant` inside it
* In terminal, cd into the `vagrant` folder and run `vagrant up`
* Wait for installationt to complete
* Clone this project to your machine inside the `vagrant` folder

## Use
* From inside the `vagrant` folder, run `vagrant up`, `vagrant ssh`
* Once vagrant has launched, cd into this project folder (`cd \vagrant\tournament-db`)
* Run `psql` then `\i tournament.sql` to setup the database then `\q` to exit
* Launch a python shell and import the tournament tests module (type `python`, `import tournament_tests as t`
* Use `help(t)` to see the functions and docstrings available
* Run the tests per your choosing

## Build your own tournament
* Follow the first three steps in the 'Use' instructions
* Launch a python shell and load players into the database:
~~~
from tournament import *

for player in ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "H", "I"]:
	registerPlayer(player)
~~~
* See initial standings (before any matches have been played):
~~~
exit() # to exit shell
~~~
then:
~~~
psql -U vagrant -d tournament -c 'SELECT * from standings'
~~~
Output should be:
~~~
id | name | wins | totalplayed 
----+------+------+-------------
  8 | H    |    0 |           0
 11 | H    |    0 |           0
  4 | D    |    0 |           0
  1 | A    |    0 |           0
  7 | G    |    0 |           0
  5 | E    |    0 |           0
  9 | I    |    0 |           0
  3 | C    |    0 |           0
 10 | J    |    0 |           0
 12 | I    |    0 |           0
  2 | B    |    0 |           0
  6 | F    |    0 |           0
(12 rows)
~~~
* Go back to python shell and create initial pairings:
~~~
from tournament import *

swissPairings()
~~~
Output should be
~~~
[(2, 'B', 6, 'F'), 
(3, 'C', 12, 'I'), 
(9, 'I', 10, 'J'), 
(7, 'G', 5, 'E'), 
(4, 'D', 1, 'A'), 
(8, 'H', 11, 'H')]
~~~
* Report winners and losers using `reportMatch(<<Winner ID>>, <<Loser ID>>)`
~~~
# here I arbitrarily chose the left player as winner and right as loser
for result in [(2, 6), (3, 12), (9, 10), (7, 5), (4, 1), (8, 11)]:
	reportMatch(*result)
~~~
* Now if you do `exit()`, `psql -U vagrant -d tournament -c 'SELECT * from standings'`, you should see a table where half the players have one win and half have zero wins
* Continue getting pairings and reporting matches until `standings` reports only one player with the most wins
* You have an overall winner


