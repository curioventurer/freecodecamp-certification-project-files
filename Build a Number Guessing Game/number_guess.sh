#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))

echo -e "\nEnter your username:"
read USERNAME

USERNAME_ID=$($PSQL "SELECT username_id FROM usernames WHERE username='$USERNAME'")
if [[ -z $USERNAME_ID ]]  #if no registered id, register
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  RESULT=$($PSQL "INSERT INTO usernames(username) VALUES('$USERNAME')")
  USERNAME_ID=$($PSQL "SELECT username_id FROM usernames WHERE username='$USERNAME'")
  GAMES_PLAYED=0
else
  GAMES=$($PSQL "SELECT games_played, best_game FROM usernames WHERE username_id=$USERNAME_ID")
  IFS="|" read GAMES_PLAYED BEST_GAME <<< $GAMES
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

GUESS_NUM=0
READ_GUESS() {
  read GUESS
  
  while [[ -z $(echo $GUESS | grep -E '^[0-9]+$') ]]
  do
    echo -e "\nThat is not an integer, guess again:"
    read GUESS
  done

  (( GUESS_NUM += 1 ))
}

echo -e "\nGuess the secret number between 1 and 1000:"
READ_GUESS

while [[ $GUESS -ne $SECRET_NUMBER ]]
do
  if [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo -e "\nIt's lower than that, guess again:"
  else
    echo -e "\nIt's higher than that, guess again:"
  fi
  READ_GUESS
done

if [[ $BEST_GAME ]]
then
  if [[ $GUESS_NUM -lt $BEST_GAME ]]
  then
    BEST_GAME=$GUESS_NUM
  fi
else
  BEST_GAME=$GUESS_NUM
fi
(( GAMES_PLAYED += 1 ))

RESULT=$($PSQL "UPDATE usernames SET games_played=$GAMES_PLAYED WHERE username_id=$USERNAME_ID")
RESULT=$($PSQL "UPDATE usernames SET best_game=$BEST_GAME WHERE username_id=$USERNAME_ID")
echo -e "\nYou guessed it in $GUESS_NUM tries. The secret number was $SECRET_NUMBER. Nice job!"
