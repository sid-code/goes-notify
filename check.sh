log() {
    echo "goes-notify log: $*"
}

die() {
    echo "goes-notify error: $*" >&2
    exit 1
}

goes_url() {
    echo "https://ttp.cbp.dhs.gov/schedulerapi/slots?orderBy=soonest&limit=10&locationId=$1&minimum=1"
}


if [[ $# -ne 1 ]]
then die "syntax: $0 <enrollment location ID>"
fi

LOCATION_ID="$1"

curl -s "$(goes_url "$LOCATION_ID")" \
    | jq -r .[].startTimestamp \
    | while read -r d; do date +%s --date="$d"; done
