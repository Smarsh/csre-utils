#!/usr/local/bin/bash

# Add to your ~/.profile, ~/.bashrc or preferred RC file.
# Assumes you have a ~/bosh subfolder per environment

setbosh () {
  declare -a boshes
  parent_dir=${HOME}/bosh
  for d in $(find ${parent_dir} -type d -depth 1 | tr '\n' ' '); do
    myname=`basename ${d}`
    boshes+=(${myname})
  done

  for i in ${!boshes[@]}; do
    echo -n "($i) "
    echo "${boshes[$i]} "
  done
  echo -n "select an environment: "
  read which_env
  if test ${boshes[which_env]} != ''; then
    echo "${boshes[which_env]} chosen"
    myrc=${parent_dir}/${boshes[which_env]}/.envrc
    if test -e $myrc; then
      source ${HOME}/bosh/${boshes[which_env]}/.envrc
    else
      echo "No RC found for ${boshes[which_env]}"
    fi
  else
    echo "Invalid selection $which_env.  Try again."
  fi
}
