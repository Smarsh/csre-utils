#!/usr/local/bin/bash

CF='/usr/local/bin/cf'
JQ='/usr/local/bin/jq'

usage () {
  echo "$0 <app>           # get all keys for <app>"
  echo "$0 (db|rmq) <app>  # get db or rmq keys for <app>"
  echo "Requires cf and jq commands"
}

if test -z $1; then
  echo "Provide app or [(db|rmq) app] args"
  usage
  exit -1
fi

do_cmd () {
  $CF env $1 | awk '/System-Provided:/{flag=1;next}/User-Provided:/{flag=0}flag'
}

case $1 in 
  db)
    case $2 in
      cada|cada-flyway)
        do_cmd $2 | \
          sed 's/aws-rds-postgres/aws_rds_postgres/'| \
          sed 's/user-provided/user_provided/' | \
          $JQ '.VCAP_SERVICES | .user_provided[] | select(.instance_name=="cada-db")'
        ;;
      alca|fiqa|kymc|prva|shda)
        do_cmd $2 | \
          sed 's/aws-rds-postgres/aws_rds_postgres/'| \
          $JQ '.VCAP_SERVICES | .aws_rds_postgres[0] | .credentials'
        ;;
      expe|rtra|expe-migrate|rtra-migrate)
        do_cmd $2 | \
          sed 's/aws-rds-postgres/aws_rds_postgres/' | \
          sed 's/user-provided/user_provided/' | \
          $JQ '.VCAP_SERVICES | .user_provided[0] | select(.name=="document-db")' 
        ;;
      *)
        echo "No db config for $2"
    esac
    ;;
  rmq)
    case $2 in
      alca|tsfa|shda|rtra|prva|nots|ftch|fiqa|expe|evlsnr|evaggr)
        do_cmd $2 | \
          $JQ '.VCAP_SERVICES | ."p.rabbitmq"[0]'
        ;;
      *)
        echo "No RabbitMQ for $2."
        ;;
    esac
    ;;
  *)
    do_cmd $1 | $JQ
    ;;
esac
