#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ $# = 0 ]] ; then
  echo Please provide an element as an argument.
elif [[ $# = 1 ]] ; then
  if [[ $1 =~ ^[0-9]+$ ]] ; then
    ELEMENT_ID=$($PSQL "SELECT atomic_number FROM elements 
                            WHERE atomic_number = $1")
  else
    ELEMENT_ID=$($PSQL "SELECT atomic_number FROM elements 
                            WHERE name = '$1' OR symbol = '$1'")
  fi

  # check for chosen element
  if [[ -z $ELEMENT_ID ]] ; then
    echo I could not find that element in the database.
  else
    # check element type & properties
    PROPERTIES=$($PSQL "SELECT type, atomic_mass, melting_point_celsius, boiling_point_celsius 
                        FROM properties LEFT JOIN types USING(type_id) 
                        WHERE atomic_number=$ELEMENT_ID")
    CHOSEN_ELEMENT=$($PSQL "SELECT atomic_number, symbol, name FROM elements 
                            WHERE atomic_number = $ELEMENT_ID")
    # readings 
    IFS="|" read TYPE ATOMIC_MASS MELT_POINT BOIL_POINT <<< "$PROPERTIES"
    IFS="|" read ATOMIC_NUM SYMBOL NAME <<< "$CHOSEN_ELEMENT"
    
    # print chosen element with its details
    echo "The element with atomic number $ATOMIC_NUM is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELT_POINT celsius and a boiling point of $BOIL_POINT celsius."
  fi
else
  echo Plase provide a single element as an argument.
fi