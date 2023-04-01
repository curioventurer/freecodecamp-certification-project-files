#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ $1 ]]
then
  NUM=$(echo $1 | grep -E '^[0-9]+$')

  if [[ -n $NUM ]]  #is a number
  then
    ELEMENT=$($PSQL "SELECT * FROM elements WHERE atomic_number=$1")
  else
    ELEMENT=$($PSQL "SELECT * FROM elements WHERE symbol='$1' OR name='$1'")
  fi

  if [[ -z $ELEMENT ]]  #is an empty string
  then
    echo "I could not find that element in the database."
  else
    echo $ELEMENT | if IFS="|" read ATOMIC_NUMBER SYMBOL NAME
    then
      PROPERTIES=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM properties INNER JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER")
      
      echo $PROPERTIES | if IFS="|" read ATOM_MASS MELT_TEMP BOIL_TEMP TYPE
      then
        echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOM_MASS amu. $NAME has a melting point of $MELT_TEMP celsius and a boiling point of $BOIL_TEMP celsius."
      fi
    fi
  fi
else
  echo "Please provide an element as an argument."
fi
