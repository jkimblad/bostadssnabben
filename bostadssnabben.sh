#! /bin/bash

#https://pushover.net/
#Pushover key used to send push notification to cellphone
USER_KEY=
#Application token for the script to be allowed API requests to Pushover
APP_TOKEN=


# Send push notification to user when the bash script is up and running!
curl -s                                                     \
  --form-string "token="$APP_TOKEN                          \
  --form-string "user="$USER_KEY                            \
  --form-string "message=Bostadssnabben up and running!"    \
  https://api.pushover.net/1/messages.json


# Send push notification to user when the bash script is being killed and notifications wont be delivered!
exit_script() {
    curl -s                                                                         \
      --form-string "token="$APP_TOKEN                                              \
      --form-string "user="$USER_KEY                                                \
      --form-string "message=Bostadssnabben going down, no more notifications!"     \
      https://api.pushover.net/1/messages.json

}
trap exit_script SIGINT SIGTERM


# Loop forever once a minute
while true
do

    #Get search results through CURL and grep interesting lines
    RESULT="$(curl -s https://bostad.stockholm.se/Lista/AllaAnnonser | python -m json.tool | grep Bostadssnabben)"

    while read -r line 
    do
        #If the line contains true, its bostadssnabben
        if [[ $line == *"true"* ]]; then
            # Send push notification using Pushover Application
            curl -s                                     \
              --form-string "token="$APP_TOKEN          \
              --form-string "user="$USER_KEY            \
              --form-string "message=Bostadssnabben, new apartment available!"   \
              https://api.pushover.net/1/messages.json

        fi
    done <<< "$RESULT"


    # Sleep 1 minute before running script again
    sleep 60
done

