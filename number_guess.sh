#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

ANSWER_NUMBER_RANDOM=$((RANDOM % 1000 + 1))

echo -e "\n~~~ Number Guessing Game ~~~\n"

echo "Enter your username:"
read USERNAME

DATA_USER=$($PSQL "SELECT * FROM users_data WHERE username = '$USERNAME'")

if [[ -z $DATA_USER ]]
then
  INSERTED_DATA_USER=$($PSQL "INSERT INTO users_data(username, games_played, best_game) VALUES ('$USERNAME', 0, 0)")
  if [[ $INSERTED_DATA_USER = "INSERT 0 1" ]]
  then
      echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
  fi
else
  GAME_PLAYED=$(echo "$DATA_USER" | cut -d '|' -f 3)
  BEST_GAME=$(echo "$DATA_USER" | cut -d '|' -f 4)
  echo -e "Welcome back, $USERNAME! You have played $GAME_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo -e "\nGuess the secret number between 1 and 1000:"
read USER_GUESS_NUMBER
NUMBER_OF_GAMES=1

if [[ $USER_GUESS_NUMBER != $ANSWER_NUMBER_RANDOM ]]
then
  while [[ $USER_GUESS_NUMBER != $ANSWER_NUMBER_RANDOM ]]
  do
    ((NUMBER_OF_GAMES++))
    if [[ ! $USER_GUESS_NUMBER =~ ^[0-9]+$ ]]
    then
      echo -e "\nThat is not an integer, guess again:"
      read USER_GUESS_NUMBER
    else
      if [[ $USER_GUESS_NUMBER > $ANSWER_NUMBER_RANDOM ]]
      then
        echo -e "\nIt's lower than that, guess again:"
        read USER_GUESS_NUMBER
      elif [[ $USER_GUESS_NUMBER < $ANSWER_NUMBER_RANDOM ]]
      then
        echo -e "\nIt's higher than that, guess again:"
        read USER_GUESS_NUMBER
      fi
    fi
  done

  if [[ $USER_GUESS_NUMBER == $ANSWER_NUMBER_RANDOM ]]
  then
    GAMES_PLAYED_DATABASE=$($PSQL "SELECT games_played FROM users_data WHERE username = '$USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_game FROM users_data WHERE username = '$USERNAME'")
    ((GAMES_PLAYED_DATABASE++))

    if [[ $BEST_GAME == 0 ]]
    then
      UPDATED_DATA_USER_1=$($PSQL "UPDATE users_data SET games_played = $GAMES_PLAYED_DATABASE, best_game = $NUMBER_OF_GAMES WHERE username = '$USERNAME'")
    else
      if [[ $NUMBER_OF_GAMES < $BEST_GAME ]]
      then
        UPDATED_DATA_USER_1=$($PSQL "UPDATE users_data SET games_played = $GAMES_PLAYED_DATABASE, best_game = $NUMBER_OF_GAMES WHERE username = '$USERNAME'")
      else
        UPDATED_DATA_USER_1=$($PSQL "UPDATE users_data SET games_played = $GAMES_PLAYED_DATABASE WHERE username = '$USERNAME'")
      fi
    fi
    echo "You guessed it in $NUMBER_OF_GAMES tries. The secret number was $ANSWER_NUMBER_RANDOM. Nice job!"
  fi
else
  ((NUMBER_OF_GAMES++))
  
  GAMES_PLAYED_DATABASE=$($PSQL "SELECT games_played FROM users_data WHERE username = '$USERNAME'")
  ((GAMES_PLAYED_DATABASE++))

  UPDATED_DATA_USER_1=$($PSQL "UPDATE users_data SET games_played = $GAMES_PLAYED_DATABASE, best_game = 1 WHERE username = '$USERNAME'")

  echo "You guessed it in $NUMBER_OF_GAMES tries. The secret number was $ANSWER_NUMBER_RANDOM. Nice job!"
fi
