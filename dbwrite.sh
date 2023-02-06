log() {
    echo "goes-db log: $*"
}

die() {
    echo "goes-db error: $*" >&2
    exit 1
}

if [[ $# -ne 1 ]]
then die "syntax: $0 <db path>"
fi

DB_PATH="$1"
NOW="$(date +%s)"

sqlite3 "$DB_PATH" "CREATE TABLE IF NOT EXISTS finds (time INTEGER, location INTEGER, seen INTEGER)"

while IFS=$'\n' read -r seen
do echo "INSERT INTO FINDS VALUES ($NOW, $(tr ' ' ',' <<< "$seen"));"
done | sqlite3 "$DB_PATH"
