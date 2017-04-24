#!/bin/bash

CDB="current.db"
ADB="aggregation.db"

function help() {
    echo "Prints SQL commands (in SQLite3 slang) to aggregate current data" >&2
    echo "" >&2
    echo "Usage:" >&2
    echo "aggregate.sh <options> [day [...]]" >&2
    echo "  day ... the day we generate aggregations for (default is today)" >&2
    echo "          format od the day is YYYY-MM-DD" >&2
    echo "Options:" >&2
    echo "  -c|--current-db     ... current database datafile" >&2
    echo "                          The default is '${CDB}'" >&2
    echo "  -a|--aggregation-db ... database datafile with aggregated values" >&2
    echo "                          The default is '${ADB}'" >&2
    echo "  --create            ... [re-]create the DB containing aggregated values" >&2
    echo "                          This option destroys the aggregated DB if it exists" >&2
    echo "  -d|--daily          ... generate daily aggregations" >&2
    echo "  -w|--weekly         ... generate weekly aggregations" >&2
    echo "  -m|--monthly        ... generate monthly aggregations" >&2
    echo "  -y|-a|--annualy     ... generate annualy aggregations" >&2
    echo "  -h|--header         ... generate header only and exit" >&2
    echo "  -f|--footer         ... generate footer only and exit" >&2
    echo "  -H|--no-header      ... do not generate header" >&2
    echo "  -F|--no-footer      ... do not generate footer" >&2
    echo "  --help              ... print this help" >&2
    exit $1
}

function header() {
    echo "
    -- Attach databases    
    ATTACH '${ADB}' AS a;
    ATTACH '${CDB}' AS c;
    "
}

function create() {
    echo "
    -- [Re-]create daily table
    DROP TABLE IF EXISTS a.daily;
    CREATE TABLE a.daily(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        day TEXT,
        temperature REAL,
        mintemperature REAL,
        maxtemperature REAL,
        sensor TEXT,
        daylight BOOLEAN,
        samples INTEGER);
    DROP INDEX IF EXISTS a.daily_day_idx;
    CREATE INDEX a.daily_day_idx ON daily(day);
    DROP INDEX IF EXISTS a.daily_sensor_idx;
    CREATE INDEX a.daily_sensor_idx ON daily(sensor);
    DROP INDEX IF EXISTS a.daily_daylight_idx;
    CREATE INDEX a.daily_daylight_idx ON daily(daylight);

    -- [Re-]create weekly table
    DROP TABLE IF EXISTS a.weekly;
    CREATE TABLE a.weekly(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        week TEXT,
        temperature REAL,
        mintemperature REAL,
        maxtemperature REAL,
        sensor TEXT,
        daylight BOOLEAN,
        samples INTEGER);
    DROP INDEX IF EXISTS a.weekly_week_idx;
    CREATE INDEX a.weekly_week_idx ON weekly(week);
    DROP INDEX IF EXISTS a.weekly_sensor_idx;
    CREATE INDEX a.weekly_sensor_idx ON weekly(sensor);
    DROP INDEX IF EXISTS a.weekly_daylight_idx;
    CREATE INDEX a.weekly_daylight_idx ON weekly(daylight);
    
    -- [Re-]create monthly table
    DROP TABLE IF EXISTS a.monthly;
    CREATE TABLE a.monthly(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        month TEXT,
        temperature REAL,
        mintemperature REAL,
        maxtemperature REAL,
        sensor TEXT,
        daylight BOOLEAN,
        samples INTEGER);
    DROP INDEX IF EXISTS a.monthly_month_idx;
    CREATE INDEX a.monthly_month_idx ON monthly(month);
    DROP INDEX IF EXISTS a.monthly_sensor_idx;
    CREATE INDEX a.monthly_sensor_idx ON monthly(sensor);
    DROP INDEX IF EXISTS a.monthly_daylight_idx;
    CREATE INDEX a.monthly_daylight_idx ON monthly(daylight);
    
    -- [Re-]create annualy table
    DROP TABLE IF EXISTS a.annualy;
    CREATE TABLE a.annualy(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        year TEXT,
        temperature REAL,
        mintemperature REAL,
        maxtemperature REAL,
        sensor TEXT,
        daylight BOOLEAN,
        samples INTEGER);
    DROP INDEX IF EXISTS a.annualy_year_idx;
    CREATE INDEX a.annualy_year_idx ON annualy(year);
    DROP INDEX IF EXISTS a.annualy_sensor_idx;
    CREATE INDEX a.annualy_sensor_idx ON annualy(sensor);
    DROP INDEX IF EXISTS a.annualy_daylight_idx;
    CREATE INDEX a.annualy_daylight_idx ON annualy(daylight);
    
    -- [Re-]create the sun{rise,set} data
    DROP TABLE IF EXISTS a.daylight;
    CREATE TABLE a.daylight(day TEXT primary key,
        sunriseutc text,
        sunsetutc text);
    INSERT INTO a.daylight VALUES('01-01','06:49:00','15:05:00');
    INSERT INTO a.daylight VALUES('01-02','06:48:00','15:06:00');
    INSERT INTO a.daylight VALUES('01-03','06:48:00','15:07:00');
    INSERT INTO a.daylight VALUES('01-04','06:48:00','15:08:00');
    INSERT INTO a.daylight VALUES('01-05','06:48:00','15:10:00');
    INSERT INTO a.daylight VALUES('01-06','06:48:00','15:11:00');
    INSERT INTO a.daylight VALUES('01-07','06:48:00','15:12:00');
    INSERT INTO a.daylight VALUES('01-08','06:47:00','15:13:00');
    INSERT INTO a.daylight VALUES('01-09','06:47:00','15:14:00');
    INSERT INTO a.daylight VALUES('01-10','06:46:00','15:16:00');
    INSERT INTO a.daylight VALUES('01-11','06:46:00','15:17:00');
    INSERT INTO a.daylight VALUES('01-12','06:45:00','15:18:00');
    INSERT INTO a.daylight VALUES('01-13','06:45:00','15:20:00');
    INSERT INTO a.daylight VALUES('01-14','06:44:00','15:21:00');
    INSERT INTO a.daylight VALUES('01-15','06:43:00','15:22:00');
    INSERT INTO a.daylight VALUES('01-16','06:43:00','15:24:00');
    INSERT INTO a.daylight VALUES('01-17','06:42:00','15:25:00');
    INSERT INTO a.daylight VALUES('01-18','06:41:00','15:27:00');
    INSERT INTO a.daylight VALUES('01-19','06:40:00','15:28:00');
    INSERT INTO a.daylight VALUES('01-20','06:39:00','15:30:00');
    INSERT INTO a.daylight VALUES('01-21','06:39:00','15:31:00');
    INSERT INTO a.daylight VALUES('01-22','06:38:00','15:33:00');
    INSERT INTO a.daylight VALUES('01-23','06:37:00','15:34:00');
    INSERT INTO a.daylight VALUES('01-24','06:35:00','15:36:00');
    INSERT INTO a.daylight VALUES('01-25','06:34:00','15:38:00');
    INSERT INTO a.daylight VALUES('01-26','06:33:00','15:39:00');
    INSERT INTO a.daylight VALUES('01-27','06:32:00','15:41:00');
    INSERT INTO a.daylight VALUES('01-28','06:31:00','15:42:00');
    INSERT INTO a.daylight VALUES('01-29','06:30:00','15:44:00');
    INSERT INTO a.daylight VALUES('01-30','06:28:00','15:46:00');
    INSERT INTO a.daylight VALUES('01-31','06:27:00','15:47:00');
    INSERT INTO a.daylight VALUES('02-01','06:26:00','15:49:00');
    INSERT INTO a.daylight VALUES('02-02','06:24:00','15:51:00');
    INSERT INTO a.daylight VALUES('02-03','06:23:00','15:52:00');
    INSERT INTO a.daylight VALUES('02-04','06:21:00','15:54:00');
    INSERT INTO a.daylight VALUES('02-05','06:20:00','15:56:00');
    INSERT INTO a.daylight VALUES('02-06','06:18:00','15:57:00');
    INSERT INTO a.daylight VALUES('02-07','06:17:00','15:59:00');
    INSERT INTO a.daylight VALUES('02-08','06:15:00','16:01:00');
    INSERT INTO a.daylight VALUES('02-09','06:14:00','16:02:00');
    INSERT INTO a.daylight VALUES('02-10','06:12:00','16:04:00');
    INSERT INTO a.daylight VALUES('02-11','06:10:00','16:06:00');
    INSERT INTO a.daylight VALUES('02-12','06:09:00','16:07:00');
    INSERT INTO a.daylight VALUES('02-13','06:07:00','16:09:00');
    INSERT INTO a.daylight VALUES('02-14','06:05:00','16:11:00');
    INSERT INTO a.daylight VALUES('02-15','06:04:00','16:13:00');
    INSERT INTO a.daylight VALUES('02-16','06:02:00','16:14:00');
    INSERT INTO a.daylight VALUES('02-17','06:00:00','16:16:00');
    INSERT INTO a.daylight VALUES('02-18','05:58:00','16:17:00');
    INSERT INTO a.daylight VALUES('02-19','05:56:00','16:19:00');
    INSERT INTO a.daylight VALUES('02-20','05:55:00','16:21:00');
    INSERT INTO a.daylight VALUES('02-21','05:53:00','16:22:00');
    INSERT INTO a.daylight VALUES('02-22','05:51:00','16:24:00');
    INSERT INTO a.daylight VALUES('02-23','05:49:00','16:26:00');
    INSERT INTO a.daylight VALUES('02-24','05:47:00','16:27:00');
    INSERT INTO a.daylight VALUES('02-25','05:45:00','16:29:00');
    INSERT INTO a.daylight VALUES('02-26','05:43:00','16:31:00');
    INSERT INTO a.daylight VALUES('02-27','05:41:00','16:32:00');
    INSERT INTO a.daylight VALUES('02-28','05:39:00','16:34:00');
    INSERT INTO a.daylight VALUES('02-29','05:37:00','16:35:00');
    INSERT INTO a.daylight VALUES('03-01','05:35:00','16:37:00');
    INSERT INTO a.daylight VALUES('03-02','05:33:00','16:39:00');
    INSERT INTO a.daylight VALUES('03-03','05:31:00','16:40:00');
    INSERT INTO a.daylight VALUES('03-04','05:29:00','16:42:00');
    INSERT INTO a.daylight VALUES('03-05','05:27:00','16:43:00');
    INSERT INTO a.daylight VALUES('03-06','05:25:00','16:45:00');
    INSERT INTO a.daylight VALUES('03-07','05:23:00','16:47:00');
    INSERT INTO a.daylight VALUES('03-08','05:21:00','16:48:00');
    INSERT INTO a.daylight VALUES('03-09','05:19:00','16:50:00');
    INSERT INTO a.daylight VALUES('03-10','05:17:00','16:51:00');
    INSERT INTO a.daylight VALUES('03-11','05:15:00','16:53:00');
    INSERT INTO a.daylight VALUES('03-12','05:13:00','16:55:00');
    INSERT INTO a.daylight VALUES('03-13','05:11:00','16:56:00');
    INSERT INTO a.daylight VALUES('03-14','05:09:00','16:58:00');
    INSERT INTO a.daylight VALUES('03-15','05:06:00','16:59:00');
    INSERT INTO a.daylight VALUES('03-16','05:04:00','17:01:00');
    INSERT INTO a.daylight VALUES('03-17','05:02:00','17:02:00');
    INSERT INTO a.daylight VALUES('03-18','05:00:00','17:04:00');
    INSERT INTO a.daylight VALUES('03-19','04:58:00','17:05:00');
    INSERT INTO a.daylight VALUES('03-20','04:56:00','17:07:00');
    INSERT INTO a.daylight VALUES('03-21','04:54:00','17:08:00');
    INSERT INTO a.daylight VALUES('03-22','04:52:00','17:10:00');
    INSERT INTO a.daylight VALUES('03-23','04:50:00','17:11:00');
    INSERT INTO a.daylight VALUES('03-24','04:47:00','17:13:00');
    INSERT INTO a.daylight VALUES('03-25','04:45:00','17:15:00');
    INSERT INTO a.daylight VALUES('03-26','04:43:00','17:16:00');
    INSERT INTO a.daylight VALUES('03-27','04:41:00','17:18:00');
    INSERT INTO a.daylight VALUES('03-28','04:39:00','17:19:00');
    INSERT INTO a.daylight VALUES('03-29','04:37:00','17:21:00');
    INSERT INTO a.daylight VALUES('03-30','04:35:00','17:22:00');
    INSERT INTO a.daylight VALUES('03-31','04:33:00','17:24:00');
    INSERT INTO a.daylight VALUES('04-01','04:30:00','17:25:00');
    INSERT INTO a.daylight VALUES('04-02','04:28:00','17:27:00');
    INSERT INTO a.daylight VALUES('04-03','04:26:00','17:28:00');
    INSERT INTO a.daylight VALUES('04-04','04:24:00','17:30:00');
    INSERT INTO a.daylight VALUES('04-05','04:22:00','17:31:00');
    INSERT INTO a.daylight VALUES('04-06','04:20:00','17:33:00');
    INSERT INTO a.daylight VALUES('04-07','04:18:00','17:34:00');
    INSERT INTO a.daylight VALUES('04-08','04:16:00','17:36:00');
    INSERT INTO a.daylight VALUES('04-09','04:14:00','17:37:00');
    INSERT INTO a.daylight VALUES('04-10','04:12:00','17:39:00');
    INSERT INTO a.daylight VALUES('04-11','04:10:00','17:40:00');
    INSERT INTO a.daylight VALUES('04-12','04:08:00','17:42:00');
    INSERT INTO a.daylight VALUES('04-13','04:06:00','17:43:00');
    INSERT INTO a.daylight VALUES('04-14','04:04:00','17:45:00');
    INSERT INTO a.daylight VALUES('04-15','04:02:00','17:46:00');
    INSERT INTO a.daylight VALUES('04-16','04:00:00','17:48:00');
    INSERT INTO a.daylight VALUES('04-17','03:58:00','17:49:00');
    INSERT INTO a.daylight VALUES('04-18','03:56:00','17:51:00');
    INSERT INTO a.daylight VALUES('04-19','03:54:00','17:52:00');
    INSERT INTO a.daylight VALUES('04-20','03:52:00','17:54:00');
    INSERT INTO a.daylight VALUES('04-21','03:50:00','17:55:00');
    INSERT INTO a.daylight VALUES('04-22','03:48:00','17:57:00');
    INSERT INTO a.daylight VALUES('04-23','03:46:00','17:58:00');
    INSERT INTO a.daylight VALUES('04-24','03:44:00','18:00:00');
    INSERT INTO a.daylight VALUES('04-25','03:42:00','18:01:00');
    INSERT INTO a.daylight VALUES('04-26','03:41:00','18:03:00');
    INSERT INTO a.daylight VALUES('04-27','03:39:00','18:04:00');
    INSERT INTO a.daylight VALUES('04-28','03:37:00','18:06:00');
    INSERT INTO a.daylight VALUES('04-29','03:35:00','18:07:00');
    INSERT INTO a.daylight VALUES('04-30','03:34:00','18:09:00');
    INSERT INTO a.daylight VALUES('05-01','03:32:00','18:10:00');
    INSERT INTO a.daylight VALUES('05-02','03:30:00','18:12:00');
    INSERT INTO a.daylight VALUES('05-03','03:28:00','18:13:00');
    INSERT INTO a.daylight VALUES('05-04','03:27:00','18:15:00');
    INSERT INTO a.daylight VALUES('05-05','03:25:00','18:16:00');
    INSERT INTO a.daylight VALUES('05-06','03:24:00','18:18:00');
    INSERT INTO a.daylight VALUES('05-07','03:22:00','18:19:00');
    INSERT INTO a.daylight VALUES('05-08','03:20:00','18:21:00');
    INSERT INTO a.daylight VALUES('05-09','03:19:00','18:22:00');
    INSERT INTO a.daylight VALUES('05-10','03:17:00','18:23:00');
    INSERT INTO a.daylight VALUES('05-11','03:16:00','18:25:00');
    INSERT INTO a.daylight VALUES('05-12','03:14:00','18:26:00');
    INSERT INTO a.daylight VALUES('05-13','03:13:00','18:28:00');
    INSERT INTO a.daylight VALUES('05-14','03:12:00','18:29:00');
    INSERT INTO a.daylight VALUES('05-15','03:10:00','18:30:00');
    INSERT INTO a.daylight VALUES('05-16','03:09:00','18:32:00');
    INSERT INTO a.daylight VALUES('05-17','03:08:00','18:33:00');
    INSERT INTO a.daylight VALUES('05-18','03:06:00','18:34:00');
    INSERT INTO a.daylight VALUES('05-19','03:05:00','18:36:00');
    INSERT INTO a.daylight VALUES('05-20','03:04:00','18:37:00');
    INSERT INTO a.daylight VALUES('05-21','03:03:00','18:38:00');
    INSERT INTO a.daylight VALUES('05-22','03:02:00','18:39:00');
    INSERT INTO a.daylight VALUES('05-23','03:01:00','18:41:00');
    INSERT INTO a.daylight VALUES('05-24','03:00:00','18:42:00');
    INSERT INTO a.daylight VALUES('05-25','02:59:00','18:43:00');
    INSERT INTO a.daylight VALUES('05-26','02:58:00','18:44:00');
    INSERT INTO a.daylight VALUES('05-27','02:57:00','18:45:00');
    INSERT INTO a.daylight VALUES('05-28','02:56:00','18:46:00');
    INSERT INTO a.daylight VALUES('05-29','02:55:00','18:47:00');
    INSERT INTO a.daylight VALUES('05-30','02:54:00','18:49:00');
    INSERT INTO a.daylight VALUES('05-31','02:54:00','18:50:00');
    INSERT INTO a.daylight VALUES('06-01','02:53:00','18:51:00');
    INSERT INTO a.daylight VALUES('06-02','02:52:00','18:51:00');
    INSERT INTO a.daylight VALUES('06-03','02:52:00','18:52:00');
    INSERT INTO a.daylight VALUES('06-04','02:51:00','18:53:00');
    INSERT INTO a.daylight VALUES('06-05','02:51:00','18:54:00');
    INSERT INTO a.daylight VALUES('06-06','02:50:00','18:55:00');
    INSERT INTO a.daylight VALUES('06-07','02:50:00','18:56:00');
    INSERT INTO a.daylight VALUES('06-08','02:49:00','18:56:00');
    INSERT INTO a.daylight VALUES('06-09','02:49:00','18:57:00');
    INSERT INTO a.daylight VALUES('06-10','02:49:00','18:58:00');
    INSERT INTO a.daylight VALUES('06-11','02:48:00','18:59:00');
    INSERT INTO a.daylight VALUES('06-12','02:48:00','18:59:00');
    INSERT INTO a.daylight VALUES('06-13','02:48:00','19:00:00');
    INSERT INTO a.daylight VALUES('06-14','02:48:00','19:00:00');
    INSERT INTO a.daylight VALUES('06-15','02:48:00','19:01:00');
    INSERT INTO a.daylight VALUES('06-16','02:48:00','19:01:00');
    INSERT INTO a.daylight VALUES('06-17','02:48:00','19:01:00');
    INSERT INTO a.daylight VALUES('06-18','02:48:00','19:02:00');
    INSERT INTO a.daylight VALUES('06-19','02:48:00','19:02:00');
    INSERT INTO a.daylight VALUES('06-20','02:48:00','19:02:00');
    INSERT INTO a.daylight VALUES('06-21','02:48:00','19:03:00');
    INSERT INTO a.daylight VALUES('06-22','02:49:00','19:03:00');
    INSERT INTO a.daylight VALUES('06-23','02:49:00','19:03:00');
    INSERT INTO a.daylight VALUES('06-24','02:49:00','19:03:00');
    INSERT INTO a.daylight VALUES('06-25','02:50:00','19:03:00');
    INSERT INTO a.daylight VALUES('06-26','02:50:00','19:03:00');
    INSERT INTO a.daylight VALUES('06-27','02:50:00','19:03:00');
    INSERT INTO a.daylight VALUES('06-28','02:51:00','19:03:00');
    INSERT INTO a.daylight VALUES('06-29','02:52:00','19:02:00');
    INSERT INTO a.daylight VALUES('06-30','02:52:00','19:02:00');
    INSERT INTO a.daylight VALUES('07-01','02:53:00','19:02:00');
    INSERT INTO a.daylight VALUES('07-02','02:53:00','19:02:00');
    INSERT INTO a.daylight VALUES('07-03','02:54:00','19:01:00');
    INSERT INTO a.daylight VALUES('07-04','02:55:00','19:01:00');
    INSERT INTO a.daylight VALUES('07-05','02:56:00','19:00:00');
    INSERT INTO a.daylight VALUES('07-06','02:56:00','19:00:00');
    INSERT INTO a.daylight VALUES('07-07','02:57:00','18:59:00');
    INSERT INTO a.daylight VALUES('07-08','02:58:00','18:59:00');
    INSERT INTO a.daylight VALUES('07-09','02:59:00','18:58:00');
    INSERT INTO a.daylight VALUES('07-10','03:00:00','18:58:00');
    INSERT INTO a.daylight VALUES('07-11','03:01:00','18:57:00');
    INSERT INTO a.daylight VALUES('07-12','03:02:00','18:56:00');
    INSERT INTO a.daylight VALUES('07-13','03:03:00','18:55:00');
    INSERT INTO a.daylight VALUES('07-14','03:04:00','18:54:00');
    INSERT INTO a.daylight VALUES('07-15','03:05:00','18:54:00');
    INSERT INTO a.daylight VALUES('07-16','03:06:00','18:53:00');
    INSERT INTO a.daylight VALUES('07-17','03:07:00','18:52:00');
    INSERT INTO a.daylight VALUES('07-18','03:08:00','18:51:00');
    INSERT INTO a.daylight VALUES('07-19','03:10:00','18:50:00');
    INSERT INTO a.daylight VALUES('07-20','03:11:00','18:48:00');
    INSERT INTO a.daylight VALUES('07-21','03:12:00','18:47:00');
    INSERT INTO a.daylight VALUES('07-22','03:13:00','18:46:00');
    INSERT INTO a.daylight VALUES('07-23','03:14:00','18:45:00');
    INSERT INTO a.daylight VALUES('07-24','03:16:00','18:44:00');
    INSERT INTO a.daylight VALUES('07-25','03:17:00','18:42:00');
    INSERT INTO a.daylight VALUES('07-26','03:18:00','18:41:00');
    INSERT INTO a.daylight VALUES('07-27','03:19:00','18:40:00');
    INSERT INTO a.daylight VALUES('07-28','03:21:00','18:38:00');
    INSERT INTO a.daylight VALUES('07-29','03:22:00','18:37:00');
    INSERT INTO a.daylight VALUES('07-30','03:23:00','18:36:00');
    INSERT INTO a.daylight VALUES('07-31','03:25:00','18:34:00');
    INSERT INTO a.daylight VALUES('08-01','03:26:00','18:33:00');
    INSERT INTO a.daylight VALUES('08-02','03:27:00','18:31:00');
    INSERT INTO a.daylight VALUES('08-03','03:29:00','18:30:00');
    INSERT INTO a.daylight VALUES('08-04','03:30:00','18:28:00');
    INSERT INTO a.daylight VALUES('08-05','03:32:00','18:27:00');
    INSERT INTO a.daylight VALUES('08-06','03:33:00','18:25:00');
    INSERT INTO a.daylight VALUES('08-07','03:34:00','18:23:00');
    INSERT INTO a.daylight VALUES('08-08','03:36:00','18:22:00');
    INSERT INTO a.daylight VALUES('08-09','03:37:00','18:20:00');
    INSERT INTO a.daylight VALUES('08-10','03:39:00','18:18:00');
    INSERT INTO a.daylight VALUES('08-11','03:40:00','18:16:00');
    INSERT INTO a.daylight VALUES('08-12','03:41:00','18:15:00');
    INSERT INTO a.daylight VALUES('08-13','03:43:00','18:13:00');
    INSERT INTO a.daylight VALUES('08-14','03:44:00','18:11:00');
    INSERT INTO a.daylight VALUES('08-15','03:46:00','18:09:00');
    INSERT INTO a.daylight VALUES('08-16','03:47:00','18:07:00');
    INSERT INTO a.daylight VALUES('08-17','03:49:00','18:05:00');
    INSERT INTO a.daylight VALUES('08-18','03:50:00','18:04:00');
    INSERT INTO a.daylight VALUES('08-19','03:51:00','18:02:00');
    INSERT INTO a.daylight VALUES('08-20','03:53:00','18:00:00');
    INSERT INTO a.daylight VALUES('08-21','03:54:00','17:58:00');
    INSERT INTO a.daylight VALUES('08-22','03:56:00','17:56:00');
    INSERT INTO a.daylight VALUES('08-23','03:57:00','17:54:00');
    INSERT INTO a.daylight VALUES('08-24','03:59:00','17:52:00');
    INSERT INTO a.daylight VALUES('08-25','04:00:00','17:50:00');
    INSERT INTO a.daylight VALUES('08-26','04:02:00','17:48:00');
    INSERT INTO a.daylight VALUES('08-27','04:03:00','17:46:00');
    INSERT INTO a.daylight VALUES('08-28','04:04:00','17:44:00');
    INSERT INTO a.daylight VALUES('08-29','04:06:00','17:42:00');
    INSERT INTO a.daylight VALUES('08-30','04:07:00','17:40:00');
    INSERT INTO a.daylight VALUES('08-31','04:09:00','17:38:00');
    INSERT INTO a.daylight VALUES('09-01','04:10:00','17:36:00');
    INSERT INTO a.daylight VALUES('09-02','04:12:00','17:34:00');
    INSERT INTO a.daylight VALUES('09-03','04:13:00','17:32:00');
    INSERT INTO a.daylight VALUES('09-04','04:14:00','17:29:00');
    INSERT INTO a.daylight VALUES('09-05','04:16:00','17:27:00');
    INSERT INTO a.daylight VALUES('09-06','04:17:00','17:25:00');
    INSERT INTO a.daylight VALUES('09-07','04:19:00','17:23:00');
    INSERT INTO a.daylight VALUES('09-08','04:20:00','17:21:00');
    INSERT INTO a.daylight VALUES('09-09','04:22:00','17:19:00');
    INSERT INTO a.daylight VALUES('09-10','04:23:00','17:17:00');
    INSERT INTO a.daylight VALUES('09-11','04:25:00','17:15:00');
    INSERT INTO a.daylight VALUES('09-12','04:26:00','17:12:00');
    INSERT INTO a.daylight VALUES('09-13','04:27:00','17:10:00');
    INSERT INTO a.daylight VALUES('09-14','04:29:00','17:08:00');
    INSERT INTO a.daylight VALUES('09-15','04:30:00','17:06:00');
    INSERT INTO a.daylight VALUES('09-16','04:32:00','17:04:00');
    INSERT INTO a.daylight VALUES('09-17','04:33:00','17:02:00');
    INSERT INTO a.daylight VALUES('09-18','04:35:00','17:00:00');
    INSERT INTO a.daylight VALUES('09-19','04:36:00','16:57:00');
    INSERT INTO a.daylight VALUES('09-20','04:38:00','16:55:00');
    INSERT INTO a.daylight VALUES('09-21','04:39:00','16:53:00');
    INSERT INTO a.daylight VALUES('09-22','04:40:00','16:51:00');
    INSERT INTO a.daylight VALUES('09-23','04:42:00','16:49:00');
    INSERT INTO a.daylight VALUES('09-24','04:43:00','16:47:00');
    INSERT INTO a.daylight VALUES('09-25','04:45:00','16:45:00');
    INSERT INTO a.daylight VALUES('09-26','04:46:00','16:42:00');
    INSERT INTO a.daylight VALUES('09-27','04:48:00','16:40:00');
    INSERT INTO a.daylight VALUES('09-28','04:49:00','16:38:00');
    INSERT INTO a.daylight VALUES('09-29','04:51:00','16:36:00');
    INSERT INTO a.daylight VALUES('09-30','04:52:00','16:34:00');
    INSERT INTO a.daylight VALUES('10-01','04:54:00','16:32:00');
    INSERT INTO a.daylight VALUES('10-02','04:55:00','16:30:00');
    INSERT INTO a.daylight VALUES('10-03','04:57:00','16:27:00');
    INSERT INTO a.daylight VALUES('10-04','04:58:00','16:25:00');
    INSERT INTO a.daylight VALUES('10-05','05:00:00','16:23:00');
    INSERT INTO a.daylight VALUES('10-06','05:01:00','16:21:00');
    INSERT INTO a.daylight VALUES('10-07','05:03:00','16:19:00');
    INSERT INTO a.daylight VALUES('10-08','05:04:00','16:17:00');
    INSERT INTO a.daylight VALUES('10-09','05:06:00','16:15:00');
    INSERT INTO a.daylight VALUES('10-10','05:07:00','16:13:00');
    INSERT INTO a.daylight VALUES('10-11','05:09:00','16:11:00');
    INSERT INTO a.daylight VALUES('10-12','05:10:00','16:09:00');
    INSERT INTO a.daylight VALUES('10-13','05:12:00','16:07:00');
    INSERT INTO a.daylight VALUES('10-14','05:13:00','16:05:00');
    INSERT INTO a.daylight VALUES('10-15','05:15:00','16:03:00');
    INSERT INTO a.daylight VALUES('10-16','05:16:00','16:01:00');
    INSERT INTO a.daylight VALUES('10-17','05:18:00','15:59:00');
    INSERT INTO a.daylight VALUES('10-18','05:19:00','15:57:00');
    INSERT INTO a.daylight VALUES('10-19','05:21:00','15:55:00');
    INSERT INTO a.daylight VALUES('10-20','05:23:00','15:53:00');
    INSERT INTO a.daylight VALUES('10-21','05:24:00','15:51:00');
    INSERT INTO a.daylight VALUES('10-22','05:26:00','15:49:00');
    INSERT INTO a.daylight VALUES('10-23','05:27:00','15:48:00');
    INSERT INTO a.daylight VALUES('10-24','05:29:00','15:46:00');
    INSERT INTO a.daylight VALUES('10-25','05:31:00','15:44:00');
    INSERT INTO a.daylight VALUES('10-26','05:32:00','15:42:00');
    INSERT INTO a.daylight VALUES('10-27','05:34:00','15:40:00');
    INSERT INTO a.daylight VALUES('10-28','05:35:00','15:39:00');
    INSERT INTO a.daylight VALUES('10-29','05:37:00','15:37:00');
    INSERT INTO a.daylight VALUES('10-30','05:39:00','15:35:00');
    INSERT INTO a.daylight VALUES('10-31','05:40:00','15:34:00');
    INSERT INTO a.daylight VALUES('11-01','05:42:00','15:32:00');
    INSERT INTO a.daylight VALUES('11-02','05:43:00','15:30:00');
    INSERT INTO a.daylight VALUES('11-03','05:45:00','15:29:00');
    INSERT INTO a.daylight VALUES('11-04','05:47:00','15:27:00');
    INSERT INTO a.daylight VALUES('11-05','05:48:00','15:26:00');
    INSERT INTO a.daylight VALUES('11-06','05:50:00','15:24:00');
    INSERT INTO a.daylight VALUES('11-07','05:51:00','15:23:00');
    INSERT INTO a.daylight VALUES('11-08','05:53:00','15:21:00');
    INSERT INTO a.daylight VALUES('11-09','05:55:00','15:20:00');
    INSERT INTO a.daylight VALUES('11-10','05:56:00','15:18:00');
    INSERT INTO a.daylight VALUES('11-11','05:58:00','15:17:00');
    INSERT INTO a.daylight VALUES('11-12','05:59:00','15:16:00');
    INSERT INTO a.daylight VALUES('11-13','06:01:00','15:14:00');
    INSERT INTO a.daylight VALUES('11-14','06:03:00','15:13:00');
    INSERT INTO a.daylight VALUES('11-15','06:04:00','15:12:00');
    INSERT INTO a.daylight VALUES('11-16','06:06:00','15:11:00');
    INSERT INTO a.daylight VALUES('11-17','06:07:00','15:09:00');
    INSERT INTO a.daylight VALUES('11-18','06:09:00','15:08:00');
    INSERT INTO a.daylight VALUES('11-19','06:10:00','15:07:00');
    INSERT INTO a.daylight VALUES('11-20','06:12:00','15:06:00');
    INSERT INTO a.daylight VALUES('11-21','06:13:00','15:05:00');
    INSERT INTO a.daylight VALUES('11-22','06:15:00','15:04:00');
    INSERT INTO a.daylight VALUES('11-23','06:16:00','15:03:00');
    INSERT INTO a.daylight VALUES('11-24','06:18:00','15:03:00');
    INSERT INTO a.daylight VALUES('11-25','06:19:00','15:02:00');
    INSERT INTO a.daylight VALUES('11-26','06:21:00','15:01:00');
    INSERT INTO a.daylight VALUES('11-27','06:22:00','15:00:00');
    INSERT INTO a.daylight VALUES('11-28','06:23:00','15:00:00');
    INSERT INTO a.daylight VALUES('11-29','06:25:00','14:59:00');
    INSERT INTO a.daylight VALUES('11-30','06:26:00','14:58:00');
    INSERT INTO a.daylight VALUES('12-01','06:27:00','14:58:00');
    INSERT INTO a.daylight VALUES('12-02','06:29:00','14:57:00');
    INSERT INTO a.daylight VALUES('12-03','06:30:00','14:57:00');
    INSERT INTO a.daylight VALUES('12-04','06:31:00','14:57:00');
    INSERT INTO a.daylight VALUES('12-05','06:32:00','14:56:00');
    INSERT INTO a.daylight VALUES('12-06','06:33:00','14:56:00');
    INSERT INTO a.daylight VALUES('12-07','06:35:00','14:56:00');
    INSERT INTO a.daylight VALUES('12-08','06:36:00','14:55:00');
    INSERT INTO a.daylight VALUES('12-09','06:37:00','14:55:00');
    INSERT INTO a.daylight VALUES('12-10','06:38:00','14:55:00');
    INSERT INTO a.daylight VALUES('12-11','06:39:00','14:55:00');
    INSERT INTO a.daylight VALUES('12-12','06:40:00','14:55:00');
    INSERT INTO a.daylight VALUES('12-13','06:40:00','14:55:00');
    INSERT INTO a.daylight VALUES('12-14','06:41:00','14:55:00');
    INSERT INTO a.daylight VALUES('12-15','06:42:00','14:56:00');
    INSERT INTO a.daylight VALUES('12-16','06:43:00','14:56:00');
    INSERT INTO a.daylight VALUES('12-17','06:44:00','14:56:00');
    INSERT INTO a.daylight VALUES('12-18','06:44:00','14:56:00');
    INSERT INTO a.daylight VALUES('12-19','06:45:00','14:57:00');
    INSERT INTO a.daylight VALUES('12-20','06:45:00','14:57:00');
    INSERT INTO a.daylight VALUES('12-21','06:46:00','14:58:00');
    INSERT INTO a.daylight VALUES('12-22','06:46:00','14:58:00');
    INSERT INTO a.daylight VALUES('12-23','06:47:00','14:59:00');
    INSERT INTO a.daylight VALUES('12-24','06:47:00','14:59:00');
    INSERT INTO a.daylight VALUES('12-25','06:48:00','15:00:00');
    INSERT INTO a.daylight VALUES('12-26','06:48:00','15:01:00');
    INSERT INTO a.daylight VALUES('12-27','06:48:00','15:02:00');
    INSERT INTO a.daylight VALUES('12-28','06:48:00','15:02:00');
    INSERT INTO a.daylight VALUES('12-29','06:48:00','15:03:00');
    INSERT INTO a.daylight VALUES('12-30','06:49:00','15:04:00');
    INSERT INTO a.daylight VALUES('12-31','06:49:00','15:05:00');
    
    DROP INDEX IF EXISTS a.daylight_day_idx;
    CREATE INDEX a.daylight_day_idx ON daylight(day);
    "
}

function footer() {
    echo "
    -- Cleanup
    -- VACUUM a;
    "
}

function daily {
    echo "
    -- Remove obsolete stats
    DELETE FROM a.daily WHERE a.daily.day = '%%DAY%%';
    -- Aggregate daily stats
    INSERT INTO a.daily SELECT
        NULL,
        '%%DAY%%',
        avg(c.temperature.temperature),
        min(c.temperature.temperature),
        max(c.temperature.temperature),
        c.temperature.sensor,
        (
            time(c.temperature.stamputc) > a.daylight.sunriseutc
            AND time(c.temperature.stamputc) < a.daylight.sunsetutc
        ) AS dl,
        count(c.temperature.temperature)
    FROM
        c.temperature,
        a.daylight
    WHERE
        strftime('%m-%d', c.temperature.stamputc) = a.daylight.day
        AND strftime('%Y-%m-%d', c.temperature.stamputc, 'localtime') = '%%DAY%%'
    GROUP BY
        c.temperature.sensor,
        dl;
    " | sed "s/%%DAY%%/$1/g"
}

function weekly {
    echo "
    -- Remove obsolete stats
    DELETE FROM a.weekly WHERE a.weekly.week = strftime('%Y-%W', '%%DAY%%');
    -- Aggregate weekly stats
    INSERT INTO a.weekly SELECT
        NULL,
        strftime('%Y-%W', a.daily.day),
        sum(a.daily.temperature * a.daily.samples) / sum(a.daily.samples),
        min(a.daily.mintemperature),
        max(a.daily.maxtemperature),
        a.daily.sensor,
        a.daily.daylight,
        sum(a.daily.samples)
    FROM
        a.daily
    WHERE
        a.daily.day <= date('%%DAY%%', '-' || strftime('%w', '%%DAY%%') || ' day', '+7 day')
        AND a.daily.day > date('%%DAY%%', '-' || strftime('%w', '%%DAY%%') || ' day')
    GROUP BY
        a.daily.sensor,
        a.daily.daylight;
    " | sed "s/%%DAY%%/$1/g"
}

function monthly {
    echo "
    -- Remove obsolete stats
    DELETE FROM a.monthly WHERE a.monthly.month = strftime('%Y-%m', '%%DAY%%');
    --Aggregate monthly stats
    INSERT INTO a.monthly SELECT
        NULL,
        strftime('%Y-%m', a.daily.day),
        sum(a.daily.temperature * a.daily.samples) / sum(a.daily.samples),
        min(a.daily.mintemperature),
        max(a.daily.maxtemperature),
        a.daily.sensor,
        a.daily.daylight,
        sum(a.daily.samples)
    FROM
        a.daily
    WHERE
        a.daily.day <= date('%%DAY%%', '+1 month', 'start of month', '-1 day')
        AND a.daily.day > date('%%DAY%%', 'start of month', '-1 day')
    GROUP BY
        a.daily.sensor,
        a.daily.daylight;
    " | sed "s/%%DAY%%/$1/g"
}

function annualy {
    echo "
    -- Remove obsolete stats
    DELETE FROM a.annualy WHERE a.annualy.year = strftime('%Y', '%%DAY%%');
    --Aggregate annualy stats
    INSERT INTO a.annualy SELECT
        NULL,
        strftime('%Y', a.daily.day),
        sum(a.daily.temperature * a.daily.samples) / sum(a.daily.samples),
        min(a.daily.mintemperature),
        max(a.daily.maxtemperature),
        a.daily.sensor,
        a.daily.daylight,
        sum(a.daily.samples)
    FROM
        a.daily
    WHERE
        a.daily.day <= date('%%DAY%%', '+1 year', 'start of year', '-1 day')
        AND a.daily.day > date('%%DAY%%', 'start of year', '-1 day')
    GROUP BY
        a.daily.sensor,
        a.daily.daylight;
    " | sed "s/%%DAY%%/$1/g"
}


DAY=( )
DAILY=""
WEEKLY=""
MONTHLY=""
ANNUALY=""
HEADER="1"
FOOTER="1"
CREATE=""

while [[ $# -ne 0 ]]; do
    case "$1" in
        "-c"|"--current-db")
            shift
            CDB="${1}"
            ;;
        "-a"|"--aggregation-db")
            shift
            ADB="${1}"
            ;;
        "-d"|"--daily")
            DAILY="1"
            ;;
        "-w"|"--weekly")
            WEEKLY="1"
            ;;
        "-m"|"--monthly")
            MONTHLY="1"
            ;;
        "-a"|"-y"|"--annualy")
            ANNUALY="1"
            ;;
        "-h"|"--header")
            header
            exit 0
            ;;
        "-f"|"--footer")
            footer
            exit 0
            ;;
        "-H"|"--no-header")
            HEADER=""
            ;;
        "-F"|"--no-footer")
            FOOTER=""
            ;;
        "--create")
            CREATE="1"
            ;;
        "--help")
            help 0
            ;;
        [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])
            DAY=( ${DAY[@]} "${1}" )
            ;;
        *)
            echo "Invalid argument: $1" >&2
            help 1
            ;;
    esac
    shift
done

# Default day is today
[[ -z "${DAY}" ]] && DAY=( $(date +'%Y-%m-%d') )

# Print the common parts
[[ -n "${HEADER}" ]] && header
[[ -n "${CREATE}" ]] && create

# Print the day-releated parts
for d in ${DAY[@]}; do
    [[ -n "${DAILY}" ]] && daily "${d}"
    [[ -n "${WEEKLY}" ]] && weekly "${d}"
    [[ -n "${MONTHLY}" ]] && monthly "${d}"
    [[ -n "${ANNUALY}" ]] && annualy "${d}"
done

# Print the common parts
[[ -n "${FOOTER}" ]] && footer

exit 0
# EOF
