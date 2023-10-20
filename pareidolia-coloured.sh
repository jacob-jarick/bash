#!/bin/bash

set -e

rows=$(tput lines)
cols=$(tput cols)
max_chars=$((rows * cols))
change_colour_interval=$((max_chars * 5))
cls=0

echo "rows: $rows, cols: $cols, max_chars: $max_chars";

text_colours=(
  "\e[97m"   # White
  "\e[31m"   # Red
  "\e[32m"   # Green
  "\e[33m"   # Yellow
  "\e[34m"   # Blue
  "\e[35m"   # Magenta
  "\e[36m"   # Cyan
  "\e[37m"   # Light Gray
  "\e[90m"   # Dark Gray
  "\e[91m"   # Light Red
  "\e[92m"   # Light Green
  "\e[93m"   # Light Yellow
  "\e[94m"   # Light Blue
  "\e[95m"   # Light Magenta
  "\e[96m"   # Light Cyan
)

colour_count="${#text_colours[@]}"
random_colour_index=0
random_colour="${text_colours[random_colour_index]}"

change_colour()
{
  random_colour_index=$((RANDOM % colour_count))
  random_colour="${text_colours[random_colour_index]}"
  echo -ne "${random_colour}"
}

change_colour

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

while true; do
  random_c=$((RANDOM % change_colour_interval))
  random_x=$((RANDOM % cols))
  random_y=$((RANDOM % rows))

  if [ $random_c = 1 ]
  then
    change_colour
  fi

  tput cup $random_y $random_x

  if [ $cls = 1 ]
  then
    echo -ne "\e[30m.${random_colour}"
  else
    r=$(( RANDOM % 2 ));
    if [ $r = 1 ]
    then
      echo -n "\\"
    else
      echo -n "/"
    fi
  fi

  if [ $cls = 1 ]
  then
    r=$(( RANDOM % 2 ));
  else
    r=$(( RANDOM % 30 ));
  fi

  if [ $r = 1 ]
  then
    if [ $cls = 1 ]
    then
      cls=0
    else
      cls=1
    fi
  fi
done
