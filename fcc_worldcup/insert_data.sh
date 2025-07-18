#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # get team_id 
    W_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    O_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # if not found
    if [[ -z $W_TEAM_ID ]]; then
      # insert winner_team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      # if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]; then
      #   echo Inserted into teams, $WINNER
      # fi
      # get new team_id
      W_TEAM_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
    fi
    if [[ -z $O_TEAM_ID ]]; then
      # insert opponent_team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      # if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]; then
      #   echo Inserted into teams, $OPPONENT
      # fi
      # get new team_id
      O_TEAM_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
    fi

    # get game_id
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year='$YEAR' and round='$ROUND' and winner_id='$W_TEAM_ID'")

    # if not found
    if [[ -z $GAME_ID ]]
    then
      # insert year
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
        VALUES($YEAR, '$ROUND', '$W_TEAM_ID', $O_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
      # if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
      # then
      #   echo Inserted into games, $YEAR - $ROUND between $WINNER-$OPPONENT
      # fi
    fi
  fi
done