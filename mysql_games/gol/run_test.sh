#!/bin/bash

USER=$1
PASSWORD=$2
DATABASE=$3

mysql -u$USER -p$PASSWORD $DATABASE < gol.sql

for file in tests/*.sql
do
  echo $file
  mysql -u$USER -p$PASSWORD --disable-pager --batch --raw --skip-column-names --unbuffered --database $DATABASE < $file
done
