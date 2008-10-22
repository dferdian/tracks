#!/bin/sh
NOW=$(date +"%Y%m%d")
mysqldump -uroot -p'19&@lemans' tracksdev_production > /home/mtessar/tracks-database-backups/tracksdev_db_$NOW.sql
