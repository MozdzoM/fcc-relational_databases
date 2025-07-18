#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo Enter your username:
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

# If brak
if [[ -z $USER_ID ]]; then
  INSERT_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, NULL)")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo Welcome, $USERNAME! It looks like this is your first time here.
else
  IFS="|" read GAMES_PLAYED BEST_GAME <<< "$($PSQL "SELECT games_played, best_game FROM users WHERE user_id = $USER_ID")"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESSED_NUMBER=0
NUMBER_OF_GUESSES=0
echo Guess the secret number between 1 and 1000:

while [[ $GUESSED_NUMBER -ne $SECRET_NUMBER ]]
do
  read GUESSED_NUMBER

  # If != number
  if [[ ! $GUESSED_NUMBER =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((NUMBER_OF_GUESSES++))

  if [[ $GUESSED_NUMBER -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
    echo -e "\n"
  elif [[ $GUESSED_NUMBER -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
    echo -e "\n"
  fi
done

# Inkrementacja ilości gier
((GAMES_PLAYED++))
$PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE user_id=$USER_ID" > /dev/null

# Aktualizacja najlepszego wyniku (jeśli to pierwsza gra lub lepszy)
if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]; then
  $PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE user_id=$USER_ID" > /dev/null
fi
# Finalna wiadomość
echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
