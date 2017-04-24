#!/bin/bash

W1_BUS='/sys/bus/w1/devices'
SQLITE="/usr/bin/sqlite3"
DB=""
CREATE=""

function help {
    echo "Measure tempereture and store it in a database file" >&2
    echo "" >&2
    echo "Usage:" >&2
    echo "$0 [options] <database>" >&2
    echo "Options:" >&2
    echo "   -c|--create ... Create the DB if it is not already created" >&2
    echo "Parameters:" >&2
    echo "   database    ... the database file to insert the measured values into" >&2
    exit $1
}

function createdb {
    cat << EOL
CREATE TABLE IF NOT EXISTS temperature(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    stamputc TEXT DEFAULT CURRENT_TIMESTAMP,
    temperature REAL,
    sensor TEXT);
CREATE INDEX IF NOT EXISTS stamputc_idx on temperature (stamputc);
CREATE INDEX IF NOT EXISTS sensor_idx on temperature (sensor);
EOL
}

function measure {
    local sensor
    local measurement
    local stat
    local temperature

    # Exits immediatelly if no sensor is available
    ls ${W1_BUS}/*/w1_slave >& /dev/null || return 1

    # Read data from all the available sensors
    for sensor in ${W1_BUS}/*/w1_slave; do
        measurement=$(cat "${sensor}")
        stat=$(echo "${measurement}"|head -1|cut -d ' ' -f 12)
        if [[ "${stat}" = "YES" ]]; then
            sensor=$(echo "${sensor}" | cut -d '/' -f 6)
            temperature=$(echo "${measurement}"|tail -1|cut -d '=' -f 2)
            echo ${sensor} ${temperature}
        fi
    done
    return 0
}

function printsql {
    measure | while read sensor temperature; do
        echo -n "INSERT INTO temperature(stamputc, temperature, sensor) VALUES('"
        echo -n $(date -u +'%Y-%m-%d %H:%M:%S')
        echo "',${temperature},'${sensor}');"
    done
}

# Parse command line
while [[ $# -ne 0 ]]; do
    case "$1" in
        -c|--create)
            CREATE="yes"
            ;;
        *)
            DB="${1}"
    esac
    shift
done

[[ -z "${DB}" ]] && { echo "Missing database parametr." >&2; help 1; }

# Create DB if required
if [[ -n "${CREATE}" ]]; then
    createdb | "${SQLITE}" "${DB}"
    ERR=$?
    [[ ${ERR} -ne 0 ]] && exit ${ERR}
fi

# Do the measurement and save the results in DB
printsql | "${SQLITE}" "${DB}"
ERR=$?
[[ ${ERR} -ne 0 ]] && exit ${ERR}

exit 0
#EOF
