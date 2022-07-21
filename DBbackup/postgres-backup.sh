#!/bin/bash
echo hello, welcome to byos
postgres -V
#psql postgresql://"$creds"@"$host":"$port" --list

export PGPASSWORD=$dbpassword

pg_dump -U $pguser -h $host -p $port oesdb > /pgdump/oesdb.dump

pg_dump -U $pguser -h $host -p $port auditdb > /pgdump/auditdb.dump

pg_dump -U $pguser -h $host -p $port autopilotqueue > /pgdump/autopilotqueue.dump

pg_dump -U $pguser -h $host -p $port opsmx > /pgdump/opsmx.dump

pg_dump -U $pguser -h $host -p $port visibilitydb > /pgdump/visibilitydb.dump

pg_dump -U $pguser -h $host -p $port platformdb > /pgdump/platformdb.dump


ls -ltra /pgdump/*.dump
