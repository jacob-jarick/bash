#!/bin/bash

set -e

rows=$(tput lines)
cols=$(tput cols)
max_chars=$((rows * cols))
blocked=0
logfile=/tmp/log1

free_cell_count=0
declare -A free_cells_x_array
declare -A free_cells_y_array
declare -A free_cells_char_array
last_cell="/"
cell_char="/"

echo "" > $logfile

log()
{
  true
  #echo "$1" >> $logfile
}

clear

echo -ne "\e[0m"
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

bc=0
blocked_check()
{
  id="${1}.${2}"
  #log "blocked_check: $id"

  if [[ -v hashtable["$id"] ]]
  then
    bc=1
    #log "blocked_check $id in hash"
    return 0
  fi

  if [ "$1" -lt 0 ] || [ "$1" -ge "$cols" ] || [ "$2" -lt 0 ] || [ "$2" -ge "$rows" ]
  then
    bc=1
    #log "blocked_check $id out of bounds"
    return 0
  fi

  #log "blocked_check $id not blocked"

  bc=0
}

free_cells_helper()
{
  x=$1
  y=$2
  c=$3
  blocked_check "$x" "$y"
  if [ "$bc" -eq 0 ]
  then
    free_cells_x_array[$free_cell_count]=$x
    free_cells_y_array[$free_cell_count]=$y
    free_cells_char_array[$free_cell_count]=$c
    free_cell_count=$((free_cell_count+1))
  fi
}

free_cells()
{
  free_cell_count=0
  unset free_cells_x_array
  unset free_cells_y_array
  unset free_cells_char_array

  # 0 1 2
  # 3 X 4
  # 5 6 7

  # Last Cell / - 0 and 7 not available

  # X\/
  # \/\
  # /\X

  # last cell \ - 3 nd 5 not available

  # \/X
  # /\/
  # X/\

  # 0

  log "free_cells: random_x=$random_x random_y=$random_y last_cell=$last_cell"

  if [ $last_cell = "\\" ]; then
    free_cells_helper "$((random_x-1))" "$((random_y-1))" "\\"
  fi

  # 1
  if [ $last_cell = "\\" ]; then
    free_cells_helper "$random_x" "$((random_y-1))" "/"
  else
    free_cells_helper "$random_x" "$((random_y-1))" "\\"
  fi

  # 2
  if [ $last_cell = "/" ]; then
    free_cells_helper "$((random_x+1))" "$((random_y-1))" "/"
  fi

  # 3
  if [ $last_cell = "\\" ]; then
    free_cells_helper "$((random_x-1))" "$random_y" "/"
  else
    free_cells_helper "$((random_x-1))" "$random_y" "\\"
  fi

  # 4
  if [ $last_cell = "\\" ]; then
    free_cells_helper "$((random_x+1))" "$random_y" "/"
  else
    free_cells_helper "$((random_x+1))" "$random_y" "\\"
  fi

  # 5
  if [ $last_cell = "/" ]; then
    free_cells_helper "$((random_x-1))" "$((random_y+1))" "/"
  fi

  # 6
  if [ $last_cell = "\\" ]; then
    free_cells_helper "$random_x" "$((random_y+1))" "/"
  else
    free_cells_helper "$random_x" "$((random_y+1))" "\\"
  fi

  # 7
  if [ $last_cell = "\\" ]; then
    free_cells_helper "$((random_x+1))" "$((random_y+1))" "\\"
  fi


  log "free_cell_count: $free_cell_count"
}

declare -A hashtable

fill_cell()
{
  id="${random_x}.${random_y}"
  log "fill_cell: id=$id cell_char=$cell_char"

  hashtable["$id"]="1"

  tput cup "$random_y" "$random_x"

  echo -n "$cell_char"
  last_cell="$cell_char"
}

walk_put()
{
  log "walk_put start: $random_x $random_y ";

  free_cells

  if [ "$free_cell_count" -eq 0 ]
  then
    log "$id - no free cells."
    blocked=1
    tput cup "$random_y" "$random_x"
    echo -n "O"
    return 0
  fi

  random_pos=$((RANDOM % free_cell_count))

  random_x=${free_cells_x_array[random_pos]}
  random_y=${free_cells_y_array[random_pos]}
  cell_char=${free_cells_char_array[random_pos]}

  fill_cell

  log "next: random_pos=$random_pos, free_cell_count=$free_cell_count, random_x=$random_x, random_y=$random_y";
}


walk()
{
  change_colour
  declare -A hashtable

  random_x=$((RANDOM % cols))
  random_y=$((RANDOM % rows))

  r=$(( RANDOM % 2 ));
  if [ $r = 1 ]
  then
    cell_char="\\"
  else
    cell_char="/"
  fi

  fill_cell

  blocked=0
  while [ "$blocked" -ne 1 ]
  do
    walk_put
  done
}

# display colours in use

echo -e "\n\e[0mColours in use: \n"
for ((i = 0; i < colour_count; i++))
do
  color="${text_colours[i]}"
  echo -e "${color}${i}"
done
sleep 1

# set initial colour
change_colour

# main loop
while true
do
  walk
  #exit
done
