#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon -t -c"

echo -e "\n~~~~~ MR MUSTACHIOS SALON ~~~~~\n"

SERVICE_MENU() {

if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

echo -e "\nWhich service would you like to use?\n"

DISPLAY_SERVICES=$($PSQL "SELECT * FROM services")

echo "$DISPLAY_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

read SERVICE_ID_SELECTED

if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SERVICE_MENU "Please choose an available service."
  else
    SERVICE_AVAILABILITY=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
    if [[ -z $SERVICE_AVAILABILITY ]]
      then
        SERVICE_MENU "Please choose an available service."
      else
        echo -e "\nPlease enter a phone number:\n"
        read CUSTOMER_PHONE
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_NAME ]]
          then
            echo -e "\nPlease enter your name:\n"
            read CUSTOMER_NAME
            INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
          fi
          echo -e "\nPlease enter a time:"
          read SERVICE_TIME
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
          INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
          if [[ $INSERT_APPOINTMENT ]]
            then
              echo -e "\nI have put you down for a$NAME$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'") at $SERVICE_TIME, $CUSTOMER_NAME."
            fi
      fi
  fi
}

SERVICE_MENU
