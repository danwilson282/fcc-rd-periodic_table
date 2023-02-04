#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

RETURN_INFO() {
  ATOMIC_NUMBER=$1
  RETURN_PERIODIC=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING (atomic_number) INNER JOIN types USING (type_id) WHERE atomic_number=$ATOMIC_NUMBER")
  #echo "$RETURN_PERIODIC" | while read AT_NUM BAR AT_NAME BAR AT_SYMBOL BAR AT_TYPE BAR ATOMIC_MASS BAR MP BAR BP
  delim="|"    # col delim. in sql output
  echo "$RETURN_PERIODIC" |  while IFS="$delim" read  AT_NUM AT_NAME AT_SYMBOL AT_TYPE ATOMIC_MASS MP BP
  do
    echo "The element with atomic number $AT_NUM is $AT_NAME ($AT_SYMBOL). It's a $AT_TYPE, with a mass of $ATOMIC_MASS amu. $AT_NAME has a melting point of $MP celsius and a boiling point of $BP celsius."
  done
}

INPUT=$1
if [[ -z $INPUT ]]
then
  echo "Please provide an element as an argument."
else
  #check atomic number
  re='^[0-9]+$'
  if [[ $INPUT =~ $re ]]
  then
    ATOMIC_CHECK=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$INPUT")
  fi
  
  #if no atomic number
  if [[ -z $ATOMIC_CHECK ]]
  then
    #check symbol or name
      ATOMIC_CHECK=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$INPUT' OR name='$INPUT'") 
  fi
  if [[ -z $ATOMIC_CHECK ]]
  then
    echo "I could not find that element in the database."
  else
    RETURN_INFO "$ATOMIC_CHECK"
  fi
fi

