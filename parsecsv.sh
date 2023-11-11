#!/bin/bash

tempkey=2199       # set this to something unique to your scripts
tmps=1             # number of tmp files needed
DEBUG=

############ don't mess with these ###########
#
program=${0##*/}   # similar to using basename
confdir=$(dirname "$0")
[ $workdir ] || workdir=$confdir
[ -d $workdir ] || workdir=$confdir
[ $(which babfunc.sh) ] && source $(which babfunc.sh) || die "babfunc.sh not found" 11
mktmps
#
###############################################



#defaults
INFILE=current.csv
basepregenurl='[NAK ModManager](https://107.174.250.132/mods/?'
boldpregenurl='[**NAK ModManager**](https://107.174.250.132/mods/?'
basecollectionurl='[Collection](https://steamcommunity.com/sharedfiles/filedetails/?id='

while [[ $# -gt 0 ]] && [[ "$1" == "--"* ]] ;
do
  opt=${1}
  case "${opt}" in
    "--" )
      break 2;;
    "--debug" ) DEBUG=1 ;;
    "--break" ) BREAKPOINT=1;;
    "--infile="* ) INFILE="${opt#*=}";;
#    "--config="* ) CONFIGFILE="${opt#*=}";;
    *)
    #   erm.  nothing here.
    ;;
  esac
  shift
done

#[ -f $confdir/${configfile} ] && source $confdir/${configfile} || die "No config file found in default location $confdir/${configfile}" 10

#main
#debug "tmps=$tmps"
#debug "tmp()=${tmp[@]}"
#debug "tmp[0]=${tmp[0]}"
#debug "tmp[1]=${tmp[1]}"
[ $BREAKPOINT ] && die "DEBUG BREAKPOINT" 99

#mkdir -p ${WEBROOT}

#reads the CSV file
#for each line parse collections
#add base urls to collections and pregen
#ensure that any special characters or spaces are handled

[ $DEBUG ] && echo "Reading $INFILE"

echo When,Event,\"Required Mods\",\"Required Event Mods\",\"Optional Mods\",\"HTML Link\",\"Last Updated\" > ${tmp[1]}

while IFS=, read -r when event required_mods event_mods optional_mods pregen_name last_updated
do
# replace spaces with dashes in name
#  name="$(tr ' ' \\- <<< "$namex")"
    # statics    when, event, last_updated
  if [ "$when" == "When" ]; then
    DONOTHING=
  else
    required_mod_collection="${basecollectionurl}${required_mods})"
    [ $event_mods ] && event_mod_collection="${basecollectionurl}${event_mods})" || event_mod_collection="None"
    [ $optional_mod_collection ] && optional_mod_collection="${basecollectionurl}${optional_mods})" || optional_mod_collection="None"
    case "$when" in
      *Current*) prepregen_url="${boldpregenurl}${pregen_name}" ;;
      *)         prepregen_url="${basepregenurl}${pregen_name}" ;;
    esac
    pregen_url="${prepregen_url}=${required_mods},${event_mods},${optional_mods}*)"
    echo \"$when\",\"$event\",\"$required_mod_collection\",\"$event_mod_collection\",\"$optional_mod_collection\",\"$pregen_url\",\"$last_updated\"
  fi

    [ $DEBUG ] && echo $when
    [ $DEBUG ] && echo $event
    [ $DEBUG ] && echo $required_mod_collection
    [ $DEBUG ] && echo $event_mod_collection
    [ $DEBUG ] && echo $optional_mod_collection
    [ $DEBUG ] && echo $pregen_url
    [ $DEBUG ] && echo $last_updated
done < $INFILE >> ${tmp[1]}

[ $DEBUG ] && echo "Done reading $INFILE"

csvlook ${tmp[1]}

cleanup
