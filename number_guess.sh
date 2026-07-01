#!/bin/bash

# Conectar a la base de datos
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Solicitar el nombre de usuario
echo "Enter your username:"
read USERNAME

# Buscar al usuario en la base de datos
USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

# Verificar si el usuario ya existe
if [[ -z $USER_INFO ]]
then
  # Usuario nuevo
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # Insertar en la base de datos
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  GAMES_PLAYED=0
  BEST_GAME=""
else
  # Usuario existente
  GAMES_PLAYED=$(echo $USER_INFO | cut -d'|' -f1)
  BEST_GAME=$(echo $USER_INFO | cut -d'|' -f2)
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generar el número aleatorio entre 1 y 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESS_COUNT=0

echo "Guess the secret number between 1 and 1000:"

# Bucle del juego
while true; do
  read GUESS
  ((GUESS_COUNT++))

  # Verificar si la entrada es un número entero
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -eq $SECRET_NUMBER ]]
  then
    # Adivinó el número
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done

# Actualizar estadísticas en la base de datos
GAMES_PLAYED=$(( GAMES_PLAYED + 1 ))

# Verificar si es su mejor partida (menor número de intentos)
if [[ -z $BEST_GAME || $GUESS_COUNT -lt $BEST_GAME ]]
then
  BEST_GAME=$GUESS_COUNT
fi

# Guardar los datos actualizados
UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME'")# fix
# feat
# refactor
