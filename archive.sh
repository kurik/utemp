#!/bin/bash

#
# TODO:
# SELECT strftime('%Y-%m', stamputc, 'localtime') AS quantum, count(*) FROM temperature WHERE stamputc <= '2017-03-05' GROUP BY quantum;


function help() {
    echo "archive.sh <options> [day]" >&2
    echo "  day ... archive check point day" >&2
    echo "          format od the day is YYYY-MM-DD" >&2
    echo "          The default is the last day of the previous month" >&2
    echo "Options:" >&2
    echo "  -c|--current <database>  ... the database with current data" >&2
    echo "  -a|--archive <prefix>    ... file prefix to store archives" >&2
    echo "                               The default is './archive'" >&2
    echo "  -g <day|week|month|year> ... granularity of the archive files" >&2
    echo "                               The default is 'month'" >&2
    echo "  -f|--format <csv|db|sql> ... format of the archive files" >&2
    echo "                               The default is 'sql'" >&2
    echo "  -r|--remove              ... Remove archived records from the current database" >&2
    exit $1
}

# Parse command line
DATABASE=""
PREFIX="./archive"
GRANULARITY="month"
FORMAT="sql"
REMOVE=""
DAY=$(date +'%Y-%m-%d' -d "-$(date +%d) days")
while [[ $# -ne 0 ]]; do
    case "$1" in
        "-c"|"--current")
            shift
            DATABASE="$1"
            ;;
        "-a"|"--archive")
            shift
            PREFIX="$1"
            ;;
        "-g")
            shift
            case "$1" in
                "day"|"week"|"month"|"year")
                    GRANULARITY="$1"
                    ;;
                *)
                    echo "Invalid granularity"
                    help 1
                    ;;
            esac
            ;;
        "-f"|"--format")
            shift
            case "$1" in
                "csv"|"db"|"sql")
                    FORMAT="$1"
                    ;;
                *)
                    echo "Invalid archive format"
                    help 1
                    ;;
            esac
            ;;
        "-r"|"--remove")
            REMOVE="1"
            ;;
        "--help")
            help 0
            ;;
        [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])
            DAY="$1"
            ;;
        *)
            echo "Invalid parameter '$1'" >&2
            help 1
            ;;
    esac
    shift
done

# Check mandatory parameters
[[ -z "${DATABASE}" ]] && { echo "Missing mandatory database parameter '-d'" >&2; help 1; }


# Debug info
echo "Database:" $DATABASE
echo "Prefix:" $PREFIX
echo "Granularity:" $GRANULARITY
echo "Format:" $FORMAT
echo "Day:" $DAY

#
# Returns list of time quantas
#
function get_time_quantas() {
    local qstr

    case "${GRANULARITY}" in
        "day")
            qstr="%Y-%m-%d"
            ;;
        "week")
            qstr="%Y-%W"
            ;;
        "month")
            qstr="%Y-%m"
            ;;
        "year")
            qstr="%Y"
            ;;
        *)
            echo "Invalid granularity in get_time_quantas(): ${GRANULARITY}" >&2
            exit 1
            ;;
    esac
    echo "SELECT strftime('${qstr}', stamputc, 'utc') AS stamp
        FROM temperature
        WHERE stamputc <= datetime('${DAY} 23:59:59', 'localtime')
        GROUP BY stamp
        ORDER BY stamp;" | sqlite3 "${DATABASE}" && return 0

    echo "Unknown error when querying database ${DATABASE}" >&2
    return 1
}

#
# Returns list of archive files needed to store all the values
# Parameters: list of time quantas
#
function get_list_of_archives() {
    local arch_list
    local suffix

    case "${GRANULARITY}" in
        "week")
            suffix="w.${FORMAT}"
            ;;
        "month")
            suffix="m.${FORMAT}"
            ;;
        *)
            suffix=".${FORMAT}"
            ;;
    esac
    for f in ${*}; do
        echo "${PREFIX}${f}${suffix}"
    done

    return 0
}

#
# Print sqlite3 commands (including SQL) to archive a time quantum
# Works as an wrapper for different output formats
# Parameter #1: The file to archive to
# Parameter #2: Time quantum to archive
#
function archive_quantum() {
    local g

    case "${GRANULARITY}" in
        "day")
            g="%Y-%m-%d"
            ;;
        "week")
            g="%Y-%W"
            ;;
        "month")
            g="%Y-%m"
            ;;
        "year")
            g="%Y"
            ;;
    esac

    case "${FORMAT}" in
        "db")
            archive_quantum_db "${g}" $* || return $?
            ;;
        "sql")
            archive_quantum_sql "${g}" $* || return $?
            ;;
        "csv")
            archive_quantum_csv "${g}" $* || return $?
            ;;
    esac
    return 0
}

function archive_quantum_csv() {
    {
    echo ".mode csv"
    echo "SELECT * FROM temperature
        WHERE strftime('${1}', stamputc, 'localtime') = '${3}';"
    [[ -n "${REMOVE}" ]] && \
        echo "DELETE FROM temperature WHERE strftime('${1}', stamputc, 'localtime') = '${3}';"
    } | sqlite3 "${DATABASE}" >> "${2}"

    return $?
}

function archive_quantum_sql() {
    {
    echo ".mode insert"
    echo "SELECT * FROM temperature
        WHERE strftime('${1}', stamputc, 'localtime') = '${3}';"
    [[ -n "${REMOVE}" ]] && \
        echo "DELETE FROM temperature WHERE strftime('${1}', stamputc, 'localtime') = '${3}';"
    } | sqlite3 "${DATABASE}" >> "${2}"

    return $?
}

function archive_quantum_db() {
    {
    echo "ATTACH '${DATABASE}' AS db;"

    echo "CREATE TABLE IF NOT EXISTS temperature(
        id INTEGER,
        stamputc TEXT,
        temperature REAL,
        sensor TEXT);"

    echo "INSERT INTO temperature
        SELECT * FROM db.temperature
        WHERE strftime('${1}', stamputc, 'localtime') = '${3}';"

    [[ -n "${REMOVE}" ]] && \
        echo "DELETE FROM db.temperature WHERE strftime('${1}', stamputc, 'localtime') = '${3}';"

    echo "DETACH db;"
    } | sqlite3 "${2}"

    return $?
}

TIME_QUANTAS=$(get_time_quantas)

for q in ${TIME_QUANTAS}; do
    archive_quantum "$(get_list_of_archives ${q})" "${q}"
done

exit 0
#EOF
