#!/bin/bash
# Script file to automate initiialisation of a FOSSIL repository.
# Requires the name of the new checkout directory and optionally a path to a
# repository. Exit code 0 if the repository does not already exist
# and the checkout directory is either already present or is created.
#
# Will generate the checkout directory in the current directory and the new
# repository in /Users/Shared/FOSSIL. Will automatically add all the files from the
# checkout directory to the repository and perform an initial checkout.
#
# Also appends information about the repository to the user's .bugwarriorrc file
# to allow bugwarrior to scrape bug entries into Taskwarrior.
#
# NB Needs unsuported umonkey version of Bugwarrior.
# https://github.com/FvD/bugwarrior/commit/ac985163c4c699059897aa0fc98f372fea768fcf
#
# NB This script dumps a 'setup' file into the checkout with the repository detail
# and password. This is a major security risk but simplifies setting up in the single
# user scenario.


# Usage:
#       fossilize [-h] [-v] [-f] checkout_dir

# TODO Add option for alternative repository location.
#  Add option of alternative checkout directory) i.e not in current directory.
#  Default is to add all files in checkout directory and make an initial commit
#  change to fossilize [-h][-v] [-c] checkout_dir [-r] alternative_repository_path?
#  add option to exclude files in current directory
#
OPTIND=1

# Default repository path and version number
VERSION=0.1
DEFAULT_REPO=/Users/Shared/FOSSIL/

# Initialize our local variables:
checkout_dir=""
repopath=$DEFAULT_REPO
defaulticon=$DEFAULT_REPO/icon.png
icon=0

function usage () {
    cat << EOF
Usage:  fossilize [OPTION] [FILE...]
        -h  displays basic help
        -v  displays version
        -i  adds fossil icon to checkout folder (requires FileIconSet)
        -r  path to alternative repository (defaults if ommitted to /Users/Shared/FOSSIL)

EOF
  exit 0
}

while getopts ":hvi" opt; do
  case "$opt" in
    h)  usage
    ;;
    v)  version=$VERSION
      echo "fossilize3 version : $version"
      exit 0
    ;;
    i)  if hash SetFileIcon 2>/dev/null; then
        icon=yes
      else
        echo "Setting an icon requires SetFileIcon in your path" 1>&2
        exit 1
      fi
    ;;
    \?) echo "fossilize :  illegal option: $1" 1>&2
      echo "usage: fossilize [-hvi] checkout directory [-r] repository directory"
      exit 1
    ;;
  esac
done

shift $((OPTIND-1))


if [ ! $1 ]; then
  echo "Must specify a checkout directory. Aborting" 1>&2
  exit 1
fi

checkout_dir=$1

# echo "Looking for $DEFAULT_REPO$checkout_dir.fossil"

if [ -e "$repopath$checkout_dir.fossil" ]; then
  echo "A repository named $checkout_dir.fossil already exists" 1>&2
  exit 1
else
  # Check if proposed checkout directory already exists. Mkdir if necessary and cd into it.
  if [[ ! -d $checkout_dir ]]; then
    mkdir $checkout_dir
  fi
  if [ $icon = yes ]; then
    SetFileIcon -image $defaulticon -file $checkout_dir
  fi

  cd $checkout_dir

  fossil new $repopath$checkout_dir.fossil >> setup
  #Pass the output of this to 'setup' - to record username:password combos within repo. Suitable for 'no security' setup ONLY!
  cat setup
  username=$(grep -o 'admin-user.*' setup | cut -d ' ' -f 2)
  password=$(grep -o '".*"' setup | sed 's/"//g')
  #Edits your .bugwarriorrc file to add a further service to enable issue tracking by Bugwarrior/Taskwarrior"
  gsed -i.bkp  '/targets = */ s/$/, fossil_'$checkout_dir'/' ~/.bugwarriorrc
  echo "" >> ~/.bugwarriorrc
  echo "[fossil_$checkout_dir]" >> ~/.bugwarriorrc
  echo "service = fossil" >> bugwarriorrc
  echo "url = http://127.0.0.1:8888/$checkout_dir/" >> ~/.bugwarriorrc
  echo "username = $username" >> ~/.bugwarriorrc
  echo "password = $password" >> ~/.bugwarriorrc
  echo "report_id = 1" >> ~/.bugwarriorrc
  echo "project_name = $checkout_dir" >> ~/.bugwarriorrc
  echo "default_priority = M" >> ~/.bugwarriorrc

  fossil open $repopath$checkout_dir.fossil
  fossil add .
  fossil commit -m "$checkout_dir.fossil repository initialised by Fossilize"
  read -p "A web page will now open in the default browser. Check permissions required. Press return to continue" $9
  fossil ui &
  exit 0
fi
