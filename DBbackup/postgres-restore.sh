#!/bin/bash
echo hello, welcome to byos
postgres -V
#psql postgresql://"$creds"@"$host":"$port" --list
export PGPASSWORD=$dbpassword


psql -h  $host -p $port -d platformdb -U $pguser -W -f  /pgdump/platformdb.dump


psql -h  $host -p $port -d oesdb -U $pguser -W -f  /pgdump/oesdb.dump


psql -h  $host -p $port -d opsmx -U $pguser -W -f  /pgdump/opsmx.dump


psql -h  $host -p $port -d visibilitydb -U $pguser -W -f  /pgdump/visibilitydb.dump


psql -h  $host -p $port -d auditdb -U $pguser -W -f  /pgdump/auditdb.dump


psql -h  $host -p $port -d autopilotqueue -U $pguser -W -f  /pgdump/autopilotqueue.dump
