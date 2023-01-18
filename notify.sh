curl --header 'Access-Token: $PUSHBULLET_TOKEN' \
     --header 'Content-Type: application/json' \
     --data-binary "{\"body\":\"FOUND $1 BEFORE $2\",\"title\":\"NEW APPT\",\"type\":\"note\"}" \
     --request POST \
     https://api.pushbullet.com/v2/pushes

