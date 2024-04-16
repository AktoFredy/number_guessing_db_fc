#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

ANSWER_NUMBER_RANDOM=$((RANDOM % 1000 + 1))

echo -e "\n~~~ Number Guessing Game ~~~\n"

echo "Enter your username:"
read USERNAME

DATA_USER=$($PSQL "SELECT * FROM users_data WHERE username = '$USERNAME'")

if [[ -z $DATA_USER ]]
then
  INSERTED_DATA_USER=$($PSQL "INSERT INTO users_data(username, games_played, best_game) VALUES ($USERNAME, 0, 0)")
  if [[ $INSERTED_DATA_USER = "INSERT 0 1" ]]
  then
      echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
  fi
else
  GAME_PLAYED=$(echo "$DATA_USER" | cut -d '|' -f 3)
  BEST_GAME=$(echo "$DATA_USER" | cut -d '|' -f 4)
  echo -e "\nWelcome back, $USERNAME!, You have played $GAME_PLAYED games, and your best game took $BEST_GAME guesses.\n"
fi

echo -e "Guess the secret number between 1 and 1000:"
read USER_GUESS_NUMBER
NUMBER_OF_GAMES=0

if [[ $USER_GUESS_NUMBER != $ANSWER_NUMBER_RANDOM ]]
then
  while [[ $USER_GUESS_NUMBER != $ANSWER_NUMBER_RANDOM ]]
  do
    NUMBER_OF_GAMES+=1
    if [[ $USER_GUESS_NUMBER > $ANSWER_NUMBER_RANDOM ]]
    then
      echo -e "\nIt's lower than that, guess again:"
      read USER_GUESS_NUMBER
    elif [[ $USER_GUESS_NUMBER < $ANSWER_NUMBER_RANDOM ]]
    then
      echo -e "\nIt's higher than that, guess again:"
      read USER_GUESS_NUMBER
    elif [[ ! $USER_GUESS_NUMBER =~ ^[0-9]+$ ]]
    then
      echo -e "\nThat is not an integer, guess again:"
      read USER_GUESS_NUMBER
    else
      echo -e "\nYou guessed it in $NUMBER_OF_GAMES tries. The secret number was $ANSWER_NUMBER_RANDOM. Nice job!\n"

    fi
  done
else
  echo -e "\nYou guessed it in 1 tries. The secret number was $ANSWER_NUMBER_RANDOM. Nice job!\n"
  
  GAMES_PLAYED_DATABASE=$($PSQL "SELECT games_played FROM users_data WHERE username = $USERNAME")
  $GAME_NOW=$(($GAME_PLAYED_DATABASE + 1))

  UPDATED_DATA_USER_1=$($PSQL "UPDATE users_data SET games_played = $GAME_NOW best_game = 1 WHERE username = $USERNAME")
  if [[ $UPDATED_DATA_USER_1 == "INSERT 0 1" ]]
  then
    echo -e "\n~~ Data 1 tries inserted successfully\n"
  fi
fi
