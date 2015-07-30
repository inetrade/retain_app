#!/bin/bash

# -----------------------------------------------------------------------------
# retain_app.sh - command line tool for retain administrators

# -----------------------------------------------------------------------------
# Copyright 2014, Philipp Metzler pm@inetra.de
# License: Beerware
#
# "THE BEER-WARE LICENSE" (Revision 42):
# <phk@FreeBSD.ORG> wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return Poul-Henning Kamp

# -----------------------------------------------------------------------------
# Usage: retain_app.sh

# -----------------------------------------------------------------------------

# version
version=0.9.93

# CONFIGURATION
###############################################################################

asconfig=/opt/beginfinite/retain/RetainServer/WEB-INF/cfg/ASConfig.cfg
retain_log_dir=/var/log/retain-tomcat7

# temp data
tmpdir=/tmp
tmp_file_installed_schema=$tmpdir/ra_installed_schema.tmp
tmp_file_fresh_schema=$tmpdir/ra_fresh_schema.tmp
schema_download_url=http://www.inetra.de/download/schema_3301ga1

# indexer monitor files
indexer_monitor_init_timestamp=$tmpdir/indexer_monitor_init_timestamp
indexer_monitor_absolute_data=$tmpdir/indexer_monitor_absolute_data
indexer_monitor_tmp_file=$tmpdir/indexer_monitor_tmp_file
indexer_monitor_data_file=$tmpdir/indexer_monitor_data
indexer_status_file=/srv/www/htdocs/indexer_status.txt
cronjob='-* * * * *       root    /root/retain_app.sh -m'


# ENVIRONMENT
###############################################################################

app_url='https://raw.githubusercontent.com/inetrade/csv_mysql_importer/master/retain_app.sh'
latest_file=$(curl "$app_url" 2>/dev/null)
current_version=$(grep -m1 'version=' $0)
latest_version=$(grep -m1 'version=' <<<"$latest_file")


# get a timestamp
timestamp=$(date)


# formatting
retain_app_head="retain_app ($version) - "\
"command line utility for retain administrators"
topic_wrapper="#########################################"\
"######################################"


# program messages
msg_new_version_available="NOTE: New version available!"
msg_offer_update="An update for this script is available. "\
"Use latest version? [y/n]: "
msg_processing_request="Processing request..."
msg_configured_jobs="Configured jobs:"
msg_run_jobs="Jobs run at least once:"
msg_up_to_date="You have the latest version. Nothing to do."
msg_known_users="Users known by the system (logged in at least once):"
error_no_filter="No Filter specified. Aborting."
error_no_job_id="No Job-ID specified. Aborting."
error_no_query="No query specified. Aborting."
error_no_log_dir="Log directory does not exist, "\
"please check your configuration. Aborting."
error_no_db_access="No database connection."
error_offline="You need online access to do that, check internet connetcion / proxy."
error_tmp_not_writable="TMP directory not writable."

# commands
cronrestart="/etc/init.d/cron restart"

# retain log keywords
str_job_start="registering Job with name:"
str_job_end="unregistering Job with name:"


# filters
declare -a log_filters_default

log_filters_default+=('LOGGING IN AS')
log_filters_default+=('- reportError: ArchiveEmail')
log_filters_default+=('Total mails archived for this ')
#log_filters_default+=('Exceeded maximum errors')
#log_filters_default+=('- ESE')
#log_filters_default+=('Code: ')
#log_filters_default+=('Total mails archived for this job: ')
#log_filters_default+=('RetainDredger - Job ended gracefully.')
#log_filters_default+=('DateFlagManager')
#log_filters_default+=('MailboxArchivingStats')
#log_filters_default+=('registering Job with')
#log_filters_default+=('Exceeded maximum errors')
#log_filters_default+=('Total mails archived for this ')
#log_filters_default+=('RetainDredger - Job ended gracefully.')

grep_arg_default="$(for i in "${log_filters_default[@]}"; do echo -n \
"${i}\\|"; done | rev | cut -c 4- | rev)"


# SQL queries
###############################################################################

query_show_tables='
SHOW TABLES;
'

query_get_users='
SELECT
    f_first,
    f_last,
    f_mailbox
FROM
    t_abook;
'

query_configured_jobs='
SELECT DISTINCT
    a.f_name AS JOB_ID,
    b.f_propertyvalue AS JOB_NAME
FROM
    t_jobs a,
    t_joboptions b
WHERE
    a.job_id = b.job_id
AND
    b.f_propertyname = '"'"'friendlyname'"'"';
'

query_indexed_items_count='
SELECT
    COUNT(*)
FROM
    t_message
WHERE
    f_indexed = 1
'

query_message_count='
SELECT
    COUNT(message_id)
FROM t_message'

query_avg_file_size='
SELECT
    AVG(f_size)
FROM
    t_dsref
'

query_file_count='
SELECT
    COUNT(ds_reference_id)
FROM
    t_dsref
'

query_items_count='
SELECT
    COUNT(*)
FROM
    t_message;
'

query_db_schema_version='
SELECT
    value
FROM
    t_dbinfo
WHERE
    name = '"'"'DBSchemaVer'"'"';
'

query_db_mig_version='
SELECT
    value
FROM
    t_dbinfo
WHERE
    name = '"'"'DBMigrateVer'"'"';
'

query_stored_mime_count='
SELECT
    COUNT(*)
FROM
    t_message_attachments
WHERE f_name = '"'"'Mime.822'"'"' AND f_size > 0;
'

query_attachments_all='
SELECT
    COUNT(DISTINCT document_id)
FROM
    t_message_attachments;
'

query_attachments_size='
SELECT
    COUNT(DISTINCT document_id)
FROM
    t_message_attachments
WHERE
    f_size > GT_SIZE
AND f_size < LT_SIZE;
'


# INITIALISATION
###############################################################################

initialize () {


  # check if tmp directory is writable

  tmp_is_writable=false

  if [[ -w $tmpdir ]]; then

    tmp_is_writable=true

  fi


  # check if we are online

  online_access=false

  wget -O /dev/null -q --tries=5 --timeout=10 http://google.com

  if [[ $? -eq 0 ]]; then

    online_access=true

  else

    online_access=false

  fi


  # check if log directory exists

  log_dir_exists=false

  if [ -d "$retain_log_dir" ]; then

    log_dir_exists=true

  fi


  # check if ASConfig exists

  asconfig_exists=false

  if [ -f "$asconfig" ]; then

    asconfig_exists=true

  fi



  # system status variables
  system_memory=""
  java_memory=""


  # Retain variables
  server_id=""
  archive_path=""
  index_path=""


  # DB variables
  db_server_type=""
  db_url=""
  db_user=""
  db_password=""



  # get database type
  db_server_type=$(parse_asconfig '<DBDriver>')
  #jdbc:mysql://localhost/retain
  #jdbc:oracle:thin:@gerslesora.ger.int.seele.com:1521/ORCL_SERVICE.ger.int.seele.com


  # DB credentials
  db_url=$(parse_asconfig '<DBURL>')
  db_host=$(parse_asconfig '<DBURL>' | cut -d \/ -f 3 )
  db_name=retain
  db_user=$(parse_asconfig '<DBUser>')
  db_password=$(parse_asconfig '<DBPass>')



  # check if DB connection can be established

  case $db_server_type in

    com.mysql.jdbc.Driver )

      sql_command="mysql --raw \
                        --silent \
                        --skip-column-names \
                        --host=$db_host \
                        --user=$db_user \
                        --password=$db_password $db_name \
                        --execute "


      sql_command_formatted="mysql --host=$db_host \
                                  --user=$db_user \
                                  --password=$db_password \
                                  --table $db_name \
                                  --execute "

      check_db_conn

    ;;

    oracle.jdbc.OracleDriver )

     check_db_conn

    ;;

    * )

      db_access=false

  esac


}


# SELF UPDATE
###############################################################################

update_retain_app () {

  if [[ $online_access = true ]]; then

    if [[ "$current_version" != "$latest_version" && "$online_access" = true ]]; then
      offer_update
    else
      echo $msg_up_to_date
    fi

  else

    echo $error_offline

  fi

}


do_update() {

  new_tmp=$(mktemp)

  chmod +x "$new_tmp"

  cat <<<"$latest_file" > "$new_tmp"

  ( mv "$new_tmp" "$0" )

  exit 0

}


offer_update() {

  while IFS= read -n1 -r -p 'An update for this script is available. Use latest version? [y/n]: '; do


    case $REPLY in

      [Yy] )

        printf '\n%s\n' 'Updating now.'
        do_update
        break

      ;;


      [Nn] )

        printf '\n%s\n' 'Update was refused.'
        break

      ;;

      * )

      printf '\r'

    esac

  done

}


# HELPER FUNCTIONS
###############################################################################

job_filter () {

  if  [ "$job_id" == "" ]; then

    tee
    return 0

  else

    sed -n "/ $str_job_start $job_id/, /$str_job_end $job_id/p" $1

  fi

}


get_log_files () {


    find $retain_log_dir/ -maxdepth 1 -name "RetainWorker*" -type f |
    grep "$filter" |
    sort

}


parse_asconfig () {

  if [[  $asconfig_exists = true ]]; then

    grep $1 $asconfig | sed -e 's/<[^>]*>//g' | sed 's/ *//g'

  fi

}


check_db_conn () {

  $sql_command "$query_show_tables" >/dev/null 2>&1

  if [ $? -eq 0 ]; then
    db_access=true
  else
    db_access=false
  fi

}


get_install_keys () {

  installdump=$(mysqldump --no-data -u $db_user \
                          -p${db_password} \
                          --ignore-table=retain.attachment \
                          --ignore-table=retain.Document \
                          --ignore-table=retain.t_msg_properties \
                          --ignore-table=retain.t_recp_properties \
                          --ignore-table=retain.t_recipients \
                          --ignore-table=retain.Email \
                          --ignore-table=retain.Node \
                          $db_name)

  echo "$installdump" | grep '  KEY\|CREATE TABLE'  |
  sed 's/,$//g' | sort  > $tmpdir/$tmp_file_installed_schema

}


get_fresh_keys () {

  curl --silent "$schema_download_url" |
  grep '  KEY\|CREATE TABLE'  |
  sed 's/,$//g' | sort  > $tmpdir/$tmp_file_fresh_schema

}


# FUNCTIONS
###############################################################################

print_system_info () {

  # OS info

  system_memory=$(cat /proc/meminfo | grep MemTotal |
                  awk '{MB=$2/1024; print MB}')


  # retain info

  server_id=$(parse_asconfig '<serverID>')
  archive_path=$(parse_asconfig '<archivePath>')
  index_path=$(parse_asconfig '<indexPath>')

  echo "System memory: $system_memory"


}

print_users () {


  if [[ $db_access = true ]]; then

    echo $msg_known_users
    echo "$topic_wrapper"
    $sql_command_formatted "$query_get_users"
    echo

  else

    echo $error_no_db_access

  fi

}


print_jobs () {


  if [[ "$db_access" = true ]]; then

    echo $msg_configured_jobs
    echo "$topic_wrapper"
    $sql_command "$query_configured_jobs"
    echo

  else

    echo $error_no_db_access

  fi

}


print_jobs_from_worker_log () {

  echo $msg_run_jobs
  echo "$topic_wrapper"

  zgrep 'RUNNING' $retain_log_dir/RetainWorker* |
    sed -n 's/^.*RetainArchiveJob - Job \(.*\) is in a RUNNING state$/\1/p' |
    sed 's/[()]//g' |
    sort |
    uniq

  echo

}

indexer_monitor () {

  if [[ "$db_access" = true ]]; then

    local timestamp=$(date +%s)
    local indexed_items_count=$($sql_command "$query_indexed_items_count")

    # if init timestamp file does not exist create it and install cronjob
    if [ ! -f $indexer_monitor_init_timestamp ]; then

      echo ${timestamp};${indexed_items_count} > $indexer_monitor_init_file
      echo "$cronjob" >> /etc/crontab
      echo "not enough data, come back in a minute." > $indexer_status_file
      $cronrestart
    fi

    # if we already collected data ...
    if [ -f "$indexer_monitor_init_file" ]; then

      # write timestamp and absolute number of indexed messages
      echo ${timestamp};${indexed_items_count} >> $indexer_monitor_absolute_data

      init_indexed_items_count=$(cat $indexer_monitor_init_timestamp | cut -f2 -d\;)
      init_timestamp=$(cat $indexer_monitor_init_timestamp | cut -f1 -d\;)
      let absolute_diff=$indexed_items_count-$init_indexed_items_count
      let time_diff=$timestamp-$init_timestamp

      items_per_second=$(echo "scale=0; $absolute_diff/$time_diff" | bc)

      items_per_minute=$(echo "scale=0; $items_per_second*60" | bc)
      items_per_hour=$(echo "scale=0; $items_per_minute*60" | bc)
      items_per_day=$(echo "scale=0; $items_per_hour*24" | bc)

      init_timestamp_human=$(date -d @${init_timestamp})

      # write values to status file
      echo  "indexer monitor started at: " $init_timestamp_human
      echo "initial indexed items count: " $init_indexed_items_count
      echo "=========================================" >> $indexer_status_file
      echo "$indexed_items_count" indexed so far > $indexer_status_file
      echo "$items_per_minute" per minute >> $indexer_status_file
      echo "$items_per_hour" per hour >> $indexer_status_file
      echo "$items_per_day" per day >> $indexer_status_file


      # check if we are still indexing stuff
      last_value_1=$(tail -n1 $indexer_monitor_absolute_data | cut -f2 -d\;)
      last_value_2=$(tail -n1 $indexer_monitor_absolute_data | cut -f2 -d\;)

      if [ $last_value_1 -eq $last_value_2 ]; then

        # disable cronjob
        sed -i '/retain_app/d' /etc/crontab
        $cronrestart

        # create directory to store collected performance data
        indexer_monitor_dir=/root/indexer_$timestamp
        mkdir $indexer_monitor_dir
        mv /tmp/indexer_* $indexer_monitor_dir
        cp $indexer_status_file $indexer_monitor_dir

      else

        echo "indexer is active"

      fi

    else

      # write initial number of indexed messages
      indexed_items_initial=$($sql_command "$query_indexed_items_count")
      echo $indexed_items_initial > $indexer_monitor_tmp_file

    fi

  else

    echo $error_no_db_access

  fi

}


db_info () {

  if [[ "$db_access" = true ]]; then

    indexed_items_count=$($sql_command "$query_indexed_items_count")
    items_count=$($sql_command "$query_items_count")
    db_schema_version=$($sql_command "$query_db_schema_version")
    db_mig_version=$($sql_command "$query_db_mig_version")
    index_space_used="$(du -sch $index_path | grep total | cut -f1)"
    stored_mime_count=$($sql_command "$query_stored_mime_count")


    attachments_all=$($sql_command "$query_attachments_all")
    #attachments_gt_size=$($sql_command "$query_attachments_size")


    echo "Version:"
    echo "$topic_wrapper"
    echo "db schema version: $db_schema_version"
    echo "db migrate version: $db_mig_version"
    echo

    echo "Messages:"
    echo "$topic_wrapper"
    echo "total messages: $items_count"
    echo "count of stored Mime.822: $stored_mime_count"
    echo

    echo "Index:"
    echo "$topic_wrapper"
    echo "indexed items (messages): $indexed_items_count"
    echo "Index Size: $index_space_used"
    echo

    echo "Attachments:"
    echo "$topic_wrapper"
    echo "All: $attachments_all"

  else

    echo $error_no_db_access

  fi

}


key_check () {

  if [[ $online_access = false ]]; then

    echo $error_offline

  else

    if [[ $tmp_is_writable = false ]]; then

      echo $error_tmp_not_writable

    else

      if [[ "$db_access" = true ]]; then

        valid_key_data=""
        current_key_data=""


        get_install_keys
        get_fresh_keys


        schema_diff=$(comm -3 $tmpdir/$tmp_file_installed_schema \
        $tmpdir/$tmp_file_fresh_schema)


        if [[ $schema_diff != "" ]]; then

          echo "first column: only in local DB"
          echo "second column: missing in local DB"

          echo "$schema_diff"

        else

          echo "seems OK."

        fi

        # clean up
        rm $tmpdir/$tmp_file_installed_schema $tmpdir/$tmp_file_fresh_schema

      else

        echo $error_no_db_access

      fi

    fi

  fi

}


get_errors () {

  if [[ $log_dir_exists = false ]]; then

    echo $error_no_log_dir

  else

    for i in $(get_log_files); do

        echo "$topic_wrapper"
        echo "$i"
        echo ""
        zcat -f $i | job_filter | egrep -o 'Code: [a-zA-Z0-9]{4}' | sort | uniq
        echo ""

    done

  fi

}


get_summary () {

  for i in $(get_log_files); do

    output=$(zcat -f $i | job_filter | grep "$grep_arg_default" | uniq)
    if [ -n "$output" ]; then
      echo "$topic_wrapper"
      echo "$i"
      echo "${output}"
      echo ""
    fi

  done

}


show_help () {
  echo
  echo "Usage: retain_app.sh [ filters ] [ options ]"
  echo
  echo "  -f | --filter <pattern> : filter files to process with grep-like " \
  "expression, e.g. '-04-\\ | -05-'"
  echo "  -I | --id <Job-ID>      : filters job ID"
  echo
  echo "  -J | --runjobs  : shows jobs IDs that did run at least once jobs"
  echo "  -d | --dbstats  : shows statistics of retain db"
  echo "  -m | --monitor  : monitor indexer performance"
  echo "  -K | --keycheck : checks retain db for missing keys / indexes"
  echo "  -e | --errors   : shows all GW error codes"
  echo "  -j | --jobs     : shows CONFIGURED retain jobs"
  echo "  -s | --summary  : show archive job summary WITH errors"
  echo "  -i | --info     : print system information"
  echo "  -u | --users    : shows known retain users"
  echo
  echo "  -q | -query <option>: execute query, options:"
  echo "                        show_tables"
  echo "                        get_users"
  echo "                        configured_jobs"
  echo "                        indexed_items_count"
  echo "                        items_count"
  echo "                        db_schema_version"
  echo "                        db_mig_version"
  echo "                        stored_mime_count"
  echo "                        attachments_all"
  echo "                        attachments_size"
  echo "                        get_users"
  echo
  echo "  -U | --update : update retain_app.sh"
  echo "  -h | --help   : prints this help"
  echo

  exit 0
}

show_queries () {
  echo
  echo 'Use one of the following queries:'
  echo
  echo '    1: query_show_tables'
  echo '    2: query_get_users'
  echo '    3: query_configured_jobs'
  echo '    4: query_indexed_items_count'
  echo '    5: query_message_count'
  echo '    6: query_avg_file_size'
  echo '    7: query_file_count'
  echo '    8: query_items_count'
  echo '    9: query_db_schema_version'
  echo '   10: query_db_mig_version'
  echo '   11: query_stored_mime_count'
  echo '   12: query_attachments_all'
  echo '   13: query_attachments_size'
  echo

  exit 0
}

# PROGRAMM
###############################################################################

# if no argument is given, show help

if [[ $# -eq 0 ]] ; then

  echo -e $retain_app_head
  show_help
  exit 0

fi


# initialize retain_app.sh

initialize

# print application header

echo -e $retain_app_head

while :
do
  case $1 in

    -h | --help | -\?)
      show_help
      exit 0
    ;;


    -f | --filter)
      if [ ! $2 ]; then
        echo $error_no_filter
        exit 1
      fi
      filter=$2
      shift 2
    ;;


    -I | --id)
      if [ ! $2 ]; then
        echo $error_no_job_id
        exit 1
      fi
      job_id=$2
      shift 2
    ;;


    -q | --query)
      if [ ! $2 ]; then
        show_queries
        exit 1
      fi
      case $2 in

        1)
          $sql_command_formatted "$query_show_tables"
          ;;
        2)
          $sql_command_formatted "$query_get_users"
          ;;
        3)
          $sql_command_formatted "$query_configured_jobs"
          ;;
        4)
          $sql_command_formatted "$query_indexed_items_count"
          ;;
        5)
          $sql_command_formatted "$query_message_count"
          ;;
        6)
          $sql_command_formatted "$query_avg_file_size"
          ;;
        7)
          $sql_command_formatted "$query_file_count"
          ;;
        8)
          $sql_command_formatted "$query_items_count"
          ;;
        9)
          $sql_command_formatted "$query_db_schema_version"
          ;;
        10)
          $sql_command_formatted "$query_db_mig_version"
          ;;
        11)
          $sql_command_formatted "$query_stored_mime_count"
          ;;
        12)
          $sql_command_formatted "$query_attachments_all"
          ;;
        13)
          $sql_command_formatted "$query_attachments_size"
          ;;
      esac


      shift 2
    ;;


    -m | --monitor)
      indexer_monitor
      shift 1
    ;;


    -d | --dbstats)
      db_info
      shift 1
    ;;

    -K | --keycheck)
      key_check
      shift 1
    ;;


    -u | --users)
      print_users
      shift 1
    ;;


    -j | --jobs)
      print_jobs
      shift 1
    ;;


    -J | --runjobs)
      print_jobs_from_worker_log
      shift 1
    ;;


    -s|--summary)
      get_summary
      shift 1
    ;;


    -e | --errors)
      get_errors
      shift 1
    ;;

    -i | --info)
      print_system_info
      shift 1
    ;;

    -U | --update)
      update_retain_app
      exit 0
    ;;


    -D | --debug)
      initialize
      (set -o posix; set)
      exit 0
    ;;


    --) # End of all options
      shift
      break
    ;;


    -*)
      printf >&2 'WARN: Unknown option (ignored): %s\n' "$1"
      shift
    ;;


    *)  # no more options. Stop while loop
      shift
      break
    ;;


  esac

done


exit 0
