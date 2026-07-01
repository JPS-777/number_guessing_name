#!/bin/bash

# Connect to database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompt for username
echo "Enter your username:"
read USERNAME

# Query database for user
USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

# Check if user exists
if [[ -z $USER_INFO ]]
then
  # New user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # Insert into database
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  GAMES_PLAYED=0
  BEST_GAME=""
else
  # Returning user
  GAMES_PLAYED=$(echo $USER_INFO | cut -d'|' -f1)
  BEST_GAME=$(echo $USER_INFO | cut -d'|' -f2)
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#  random number
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESS_COUNT=0

echo "Guess the secret number between 1 and 1000:"

# Game loop
while true; do
  read GUESS
  ((GUESS_COUNT++))

  # Check if guess is an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -eq $SECRET_NUMBER ]]
  then
    # Correct guess
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    # Guess is too high
    echo "It's lower than that, guess again:"
  else
    # Guess is too low
    echo "It's higher than that, guess again:"
  fi
done

# Update user statistics
GAMES_PLAYED=$(( GAMES_PLAYED + 1 ))

# Determine if this is the best game
if [[ -z $BEST_GAME || $GUESS_COUNT -lt $BEST_GAME ]]
then
  BEST_GAME=$GUESS_COUNT
fi

# Save the updated stats
UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME'")# minor change
# another minor change
# third minor change
# final minor change
