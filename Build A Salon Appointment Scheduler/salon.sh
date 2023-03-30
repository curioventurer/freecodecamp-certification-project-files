#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -A -t -c"

echo -e "\n~~~~~ Salon ~~~~~\n"

MAIN_MENU() {
  REPEAT=0
  PROMPT=""
  while (( $REPEAT == 0 ))
  do
    if [[ -n $PROMPT ]]
    then
      echo -e "\n$PROMPT"
    fi

    echo -e "Which service would you like to book an appointment for?" 
    
    AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
    echo "$AVAILABLE_SERVICES" | while IFS="|" read SERVICE_ID NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
    
    read SERVICE_ID_SELECTED

    # if input is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      # repeat
      PROMPT="That is not a valid service number."
    else
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

      #if service not found
      if [[ -z $SERVICE_NAME ]]
      then
        # repeat
        PROMPT="The selected service is not available."
      else
        REPEAT=1
      fi
    fi
  done

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  #if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    #get new customer name
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    #insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  
  echo -e "\nAt what time would you like to make an appointment?"
  read SERVICE_TIME

  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU
