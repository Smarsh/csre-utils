#!/usr/local/bin/bash

CF='/usr/local/bin/cf'

usage () {
  echo "$0 <app>           # get all keys for <app>"
  echo "$0 (db|rmq) <app>  # get db or rmq keys for <app>"
}

do_cmd () {
  $CF env $1 | awk '/System-Provided:/{flag=1;next}/User-Provided:/{flag=0}flag'
}

if test -z $1; then
  echo "Provide an app or (db|rmq) at \$1"
  usage
  exit -1
fi

case $1 in 
  db)
    case $2 in
      cada|cada-flyway)
        do_cmd $2 | \
          sed 's/aws-rds-postgres/aws_rds_postgres/'| \
          sed 's/user-provided/user_provided/' | \
          jq '.VCAP_SERVICES | .user_provided[] | select(.instance_name=="cada-db")'
        ;;
      alca|fiqa|kymc|prva|shda)
        do_cmd $2 | \
          sed 's/aws-rds-postgres/aws_rds_postgres/'| \
          jq '.VCAP_SERVICES | .aws_rds_postgres[0] | .credentials'
        ;;
      expe|rtra|expe-migrate|rtra-migrate)
        do_cmd $2 | \
          sed 's/aws-rds-postgres/aws_rds_postgres/' | \
          sed 's/user-provided/user_provided/' | \
          jq '.VCAP_SERVICES | .user_provided[0] | select(.name=="document-db")' 
        ;;
      *)
        echo "No db config for $2"
    esac
    ;;
  rmq)
    case $2 in
      alca|tsfa|shda|rtra|prva|nots|ftch|fiqa|expe|evlsnr|evaggr)
        do_cmd $2 | \
          jq '.VCAP_SERVICES | ."p.rabbitmq"[0]'
        ;;
      *)
        echo "No RabbitMQ for $2."
        ;;
    esac
    ;;
  *)
    do_cmd $1 | jq
    ;;
esac
