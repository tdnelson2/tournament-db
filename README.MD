# Tournament Results Database
The purpose of this project is to demonstrate how you can used psql to manage a Swiss Pairing tournament. Databases are particually usefull for this type of tournament because of it's high levels complexity.

## Installation
* Clone this project to your system
* Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* Install [Vagrant](https://www.vagrantup.com/downloads.html)
* Clone [This VM configuration](https://github.com/udacity/fullstack-nanodegree-vm) onto your machine
* In terminal cd into the `vagrant` folder and run `vagrant up`
* Wait for installationt to complete
* Move this project into the `vagrant` folder

## Use
* From inside the `vagrant` folder, run `vagrant ssh`
* Once vagrant has launched, cd into this project folder
* Run `psql` then `\i tournament.sql` to setup the database
* Run `python mytests.py` to execute all the tests defined in `tournament_tests.py`