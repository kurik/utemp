#!/bin/bash

UDB="unin.db"
CDB="current.db"
DAY=( )

function help {
    echo "Converts the old DB format to the current one" >&2
    echo "Usage:" >&2
    echo "$0 <options> [[day [...]]" >&2
    echo "  day ... the day we generate aggregations for (default is today)" >&2
    echo "          format od the day is YYYY-MM-DD" >&2
    echo "Options:" >&2
    echo "  -c|--current-db     ... current database datafile" >&2
    echo "                          The default is 'current.db'" >&2
    echo "  -u|--unin-db        ... unin database datafile" >&2
    echo "                          The default is 'unin.db'" >&2
    exit $1
}

function get_sql {
    echo -n "
    -- Attach databases
    ATTACH '${UDB}' AS u;
    ATTACH '${CDB}' AS c;

    INSERT INTO c.temperature(stamputc,temperature,sensor) 
        SELECT
            datetime(u.temperature.stamp, 'utc'),
            u.temperature.temperature,
            u.sensor.sensorid
        FROM u.sensor, u.temperature
        WHERE 
            u.sensor.oid = u.temperature.sensor
            AND date(u.temperature.stamp, 'utc') IN ("
    for d in ${DAY[@]}; do
        echo -n "'${d}',"
    done
    echo "''); "
}

while [[ $# -ne 0 ]]; do
    case "$1" in
        "-c"|"--current-db")
            shift
            CDB="${1}"
            ;;
        "-u"|"--unin-db")
            shift
            UDB="${1}"
            ;;
        [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])
            DAY=( ${DAY[@]} "${1}")
            ;;
        *)
            echo "Invalid argument: $1" >&2
            help 1
            ;;
    esac
    shift
done

[[ -z "${DAY}" ]] && DAY=( $(date +'%Y-%m-%d') )

get_sql
