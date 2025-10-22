#!/bin/bash

# Function to create question_bank.csv if it doesn't exist
create_question_bank() {
  if [ -f "question_bank.csv" ]; then
    return
  fi

  cat <<EOF > question_bank.csv
1. Who is the best Star Wars character?
a. Darth Vader
b. Yoda
c. Han Solo
d. Princess Leia
2. What's your favorite superhero?
a. Batman
b. Superman
c. Spider-Man
d. Wonder Woman
3. If you could time travel, where would you go?
a. Dinosaur era
b. Ancient Rome
c. The future
d. The 80s
4. What's the funniest animal?
a. Penguin
b. Sloth
c. Otter
d. Platypus
5. Best way to eat ice cream?
a. In a cone
b. In a bowl
c. Straight from the tub
d. With hot fudge
EOF
}

# Function for user registration
register() {
  while true; do
    read -p "Please choose your username: " username
    if ! [[ "$username" =~ ^[a-zA-Z0-9]+$ ]]; then
      echo "Username should contain only alphanumeric symbols"
      continue
    fi
    if grep -q "^$username," user_credentials.csv 2>/dev/null; then
      echo "Username \"$username\" exists."
      continue
    fi
    break
  done

  while true; do
    read -s -p "Please enter your password: " password
    echo
    if ! [[ ${#password} -ge 8 && "$password" =~ [0-9] && "$password" =~ [^a-zA-Z0-9] ]]; then
      echo "Password should be 8 or more characters and contain at least 1 number and 1 symbol"
      continue
    fi
    read -s -p "Please re-enter your password: " password2
    echo
    if [ "$password" != "$password2" ]; then
      echo "Passwords don't match"
      continue
    fi
    break
  done

  echo "$username,$password" >> user_credentials.csv
  echo "Registration successful. Please hit any key to continue"
  read -n 1
}

# Function for user login
login() {
  read -p "Username: " username
  read -s -p "Password: " password
  echo
  if ! grep -q "^$username,$password$" user_credentials.csv 2>/dev/null; then
    echo "Error: password doesn't match"
    return 1
  fi
  return 0
}

# Function to take the survey
take_survey() {
  answers_file="${username}_answers_file.csv"
  > "$answers_file"  # Truncate the file

  num_lines=$(wc -l < question_bank.csv)
  num_questions=$((num_lines / 5))

  for ((i=1; i<=num_questions; i++)); do
    head -n $(( (i-1)*5 + 5 )) question_bank.csv | tail -n 5 > temp_question.txt
    question=$(head -n 1 temp_question.txt)
    opta=$(sed -n 2p temp_question.txt)
    optb=$(sed -n 3p temp_question.txt)
    optc=$(sed -n 4p temp_question.txt)
    optd=$(sed -n 5p temp_question.txt)

    clear
    echo "Survey: $username's Survey"
    echo
    echo "$question"
    echo "1) ${opta#a. }"
    echo "2) ${optb#b. }"
    echo "3) ${optc#c. }"
    echo "4) ${optd#d. }"
    echo

    while true; do
      read -p "Please choose your option (1-4 or a-d): " choice
      case "${choice,,}" in
        1|a) no_append_a="$opta -> YOUR ANSWER"; no_append_b="$optb"; no_append_c="$optc"; no_append_d="$optd" ;;
        2|b) no_append_a="$opta"; no_append_b="$optb -> YOUR ANSWER"; no_append_c="$optc"; no_append_d="$optd" ;;
        3|c) no_append_a="$opta"; no_append_b="$optb"; no_append_c="$optc -> YOUR ANSWER"; no_append_d="$optd" ;;
        4|d) no_append_a="$opta"; no_append_b="$optb"; no_append_c="$optc"; no_append_d="$optd -> YOUR ANSWER" ;;
        *) echo "Invalid choice"; continue ;;
      esac
      break
    done

    cat <<EOF >> "$answers_file"
$question
$no_append_a
$no_append_b
$no_append_c
$no_append_d
EOF
  done

  rm temp_question.txt
  echo "Survey complete."
  echo "Please hit any key to continue"
  read -n 1
}

# Function to view the survey
view_survey() {
  answers_file="${username}_answers_file.csv"
  if [ ! -f "$answers_file" ]; then
    echo "No survey taken yet."
    echo "Please hit any key to continue"
    read -n 1
    return
  fi

  clear
  echo "Survey: $username's Survey"
  echo
  echo "Viewing your survey results:"
  echo
  sed 's/^a\. /1) /; s/^b\. /2) /; s/^c\. /3) /; s/^d\. /4) /' "$answers_file"
  echo
  echo "Please hit any key to continue"
  read -n 1
}

# Function for the survey menu after login
survey_menu() {
  while true; do
    clear
    echo "Survey: $username's Survey"
    echo
    echo "1. Take Survey"
    echo "2. View Survey"
    echo "3. Exit"
    echo
    read -p "Please choose your option: " option
    case "$option" in
      1) take_survey ;;
      2) view_survey ;;
      3) return ;;
      *) echo "Invalid option" ;;
    esac
  done
}

# Function for the main menu
main_menu() {
  while true; do
    clear
    echo "Survey: Main Menu"
    echo
    echo "1. Register"
    echo "2. Login"
    echo "3. Exit"
    echo
    read -p "Please choose your option: " option
    case "$option" in
      1) register ;;
      2) if login; then survey_menu; fi ;;
      3) exit 0 ;;
      *) echo "Invalid option" ;;
    esac
    echo "Please hit any key to continue"
    read -n 1
  done
}

# Main execution
create_question_bank
main_menu
