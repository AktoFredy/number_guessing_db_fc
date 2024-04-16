#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

ANSWER_NUMBER_RANDOM=$((RANDOM % 1000 + 1))

