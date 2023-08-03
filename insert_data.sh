#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE TABLE teams, games;")

IS_HEADER=true

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
  # skip header
  if [[ $IS_HEADER = true ]]
  then
    IS_HEADER=false
    continue
  fi

  # INSERT DATA INTO TEAMS TABLE

  # get winner's team_id
  W_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")

  # if not found
  if [[ -z $W_ID ]]
  then
    # insert winning team
    echo $($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")

    #get winner's new team_id
    W_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
  fi

  # get opponent's team_id
  O_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

  # if not found
  if [[ -z $O_ID ]]
  then
    # insert opposing team
    echo $($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")

    # get opponent's new team_id
    O_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
  fi

  # INSERT DATA INTO GAMES TABLE

  echo $($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR,'$ROUND', $W_ID, $O_ID, $W_GOALS, $O_GOALS);")
  
done
