#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$(($RANDOM % 1000 + 1))


MAIN(){
  echo "Enter your username:"
  read NAME
  GAMECOUNT=$($PSQL"SELECT game_count FROM users WHERE name = '${NAME}';")
  PB=$($PSQL"SELECT best_game FROM users WHERE name = '${NAME}';")
  if [[ -z $GAMECOUNT  ]]
    then
    echo "Welcome, $NAME! It looks like this is your first time here."
    else
    echo "Welcome back, $NAME! You have played $GAMECOUNT games, and your best game took $PB guesses."
  fi
  #gameloop
  echo "Guess the secret number between 1 and 1000:"
  read GUESS
  COUNT=1
  while (( $GUESS != $NUMBER ))
  do
    if [[ $GUESS =~ [0-9]+ ]]
    then
      if [[ $GUESS > $NUMBER ]]
      then
        COUNT=$(( $COUNT + 1 ))
        echo "It's lower than that, guess again:"
        read GUESS
      elif [[ $GUESS < $NUMBER ]]
      then
        COUNT=$(( $COUNT + 1 ))
        echo "It's higher than that, guess again:"
        read GUESS
      fi
    else
      echo "That is not an integer, guess again:"
      read GUESS
      
    fi
    #COUNT=$(( $COUNT + 1 ))
  done
  if [[ -z $GAMECOUNT ]] 
  then
    GAMECOUNT=1
  else
    GAMECOUNT=$(( $GAMECOUNT + 1))
  fi
    if [[ -z $PB ]] || [[ $PB > $COUNT ]]
  then
    PB=$COUNT
  fi
  echo "You guessed it in $COUNT tries. The secret number was $NUMBER. Nice job!"
  if  [[ $GAMECOUNT == 1 ]] 
  then
    INSERTRESULTS=$($PSQL"INSERT INTO users(name, game_count, best_game) VALUES('${NAME}', ${GAMECOUNT}, ${PB});")
  else
    UPDATE_COUNT=$($PSQL"UPDATE users SET game_count = ${GAMECOUNT} WHERE name = '${NAME}';")
    UPDATE_PB=$($PSQL"UPDATE users SET best_game = ${PB} WHERE name = '${NAME}';")
  fi
}

MAIN