#!/bin/bash

set -e

rows=$(tput lines)
cols=$(tput cols)
max_chars=$((rows * cols))
blank=0

echo -e "\e[32m"

for ((i = 0; i <= max_chars; i++))
do
  random_x=$((RANDOM % cols))
  random_y=$((RANDOM % rows))

  tput cup $random_y $random_x

  r=$(( RANDOM % 2 ));
  if [ $r = 1 ]
  then
    echo -n "\\"
  else
    echo -n "/"
  fi
done

echo -e "\e[0m"

while true
do
  random_x=$((RANDOM % cols))
  random_y=$((RANDOM % rows))

  tput cup $random_y $random_x

  if [ $blank = 1 ]
  then
    echo -ne "\e[30m.\e[0m"
  else
    r=$(( RANDOM % 2 ));
    if [ $r = 1 ]
    then
      echo -n "\\"
    else
      echo -n "/"
    fi
  fi

  if [ $blank = 1 ]
  then
    r=$(( RANDOM % 2 ));
  else
    r=$(( RANDOM % 25 ));
  fi

  if [ $r = 1 ]
  then
    if [ $blank = 1 ]
    then
      blank=0
    else
      blank=1
    fi
  fi
done
