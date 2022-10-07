#!/bin/bash
# Number Guessing Game

PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c "

echo "Enter your username:"
read USERNAME

USER_RECORD=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME'")
if [[ -z $USER_RECORD ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # insert new user into db
  ADD_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  # INIT var GAMES_PLAYED 
  GAMES_PLAYED=0
  # INIT var BEST_GAME
  BEST_GAME=0
else
  # fetch all user stat and read into var GAMES_PLAYED, BEST_GAME
  read GAMES_PLAYED BAR BEST_GAME <<< $($PSQL "SELECT games_played, best_game FROM users WHERE username = '$USERNAME'")
  ##### Welcome back, <username>! You have played <games_played> games, and your best game took <best_game> guesses.,
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi


# init var ANSWER
ANSWER=$(($RANDOM % 1000))
#ANSWER=10
# init var NUMBER_OF_GUESSES 
NUMBER_OF_GUESSES=0
# increment var GAMES_PLAYED
(( GAMES_PLAYED+=1 ))

# echo quiz start message
echo "Guess the secret number between 1 and 1000:"
#define QUIZ function:
QUIZ() {
  # read input user_answer
  read USER_ANSWER
  # if input not a number
  if [[ ! $USER_ANSWER =~ ^[0-9]+$ || -z $USER_ANSWER ]]
  then
    # echo invalid input message
    echo "That is not an integer, guess again:"
    # call QUIZ function. NOTE: not incrementing number_of_guesses
    QUIZ
  fi

  # increment var number_of_guesses 
  ((NUMBER_OF_GUESSES+=1))
  # if USER_ANSWER to ANSWER
  if [[ $USER_ANSWER -eq $ANSWER ]]
  then
    # echo correct answer message
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $ANSWER. Nice job!"
    # if NUMBER_OF_GUESSES less than BEST_PLAYED
    if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME || $BEST_GAME = 0 ]]
    then
      # update db best_game and db games_played current user
      UPDATE=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
    # else
    else
      # update db games_played only current user
      UPDATE=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'")
    fi
    ## EXIT POINT

  # else
  else
    # if USER_ANSWER less than ANSWER
    if [[ $USER_ANSWER -lt $ANSWER ]]
    then
      # echo higher than
      echo "It's higher than that, guess again:"
      # call QUIZ function
      QUIZ
    # else 
    else
      # echo lower than
      echo "It's lower than that, guess again:"
      # call QUIZ function
      QUIZ
    fi
  fi
}
# call QUIZ function
QUIZ