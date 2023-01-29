#!/bin/bash

########### EDIT ############
# directory we will break down into smaller chunks
TARGET_DIR='./2023/01/'

# will echo objects being moved.
VERBOSE="yes"

########### EDIT WITH CAUTION ############

# Controls the number of child processes when moving individual files. can be set much higher than this usually
LIMIT_JOBS=10

# how long to sleep if job limit is exceeded
SLEEP_FOR=5

# 10 digits, 26x2 letters (upper and lower), TARGET_DIR files will be broken into 62 subdirectories
SUBSTRUCTURE_LIST=("$(echo {0..9})" "$(echo {a..z})" "$(echo {A..Z})")

########### DON'T EDIT BELOW HERE ############

limit_jobs() {
  # if [[ $VERBOSE == "yes" ]]; then echo "checking jobs..."; jobs | wc -l; fi
  while [ `jobs | wc -l` -ge $LIMIT_JOBS ]
  do
    if [[ $VERBOSE == "yes" ]]; then local current_limit=$(jobs | wc -l); echo "Job limit hit! ${current_limit// /} Giving your poor computer a break..."; fi
    sleep $SLEEP_FOR
  done
}

migrate_to_subdirs() {
  if [[ $VERBOSE == "yes" ]]; then echo "mv $1 $2"; fi
  mv $1 $2
}

IS_SLASH="${TARGET_DIR:0-1}"

if [[ $IS_SLASH =~ "/" ]]; then TARGET_DIR="${TARGET_DIR%\/*}"; fi # something # TARGET_DIR="${TARGET_DIR}/"; fi # if we wanted to add and negate this if
for char in ${SUBSTRUCTURE_LIST[@]};
do
  current_dir="$TARGET_DIR/$char"
  [ ! -d $current_dir ] && mkdir -p $current_dir
  find "${TARGET_DIR}" -name "$char*" -type f | while read file;
  do
    limit_jobs; migrate_to_subdirs ${file} ${current_dir} &
  done
done

wait

echo "all done!"


