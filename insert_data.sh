#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

SQL=$(while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  printf "INSERT INTO teams(name) VALUES ('%s'), ('%s') ON CONFLICT (name) DO NOTHING;\n" "$winner" "$opponent"
  printf "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) SELECT %s, '%s', winner.team_id, opponent.team_id, %s, %s FROM teams AS winner, teams AS opponent WHERE winner.name = '%s' AND opponent.name = '%s';\n" "$year" "$round" "$winner_goals" "$opponent_goals" "$winner" "$opponent"
done < <(tail -n +2 "$(dirname "$0")/games.csv"))

$PSQL "$SQL"
