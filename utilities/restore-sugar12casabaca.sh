#!/bin/bash

# Enrico Simonetti
# enricosimonetti.com

if [ -z $1 ]
then
    echo Provide the backup suffix as script parameters
else
    # check if the stack is running
    running=`docker ps | grep sugar-mysql | wc -l`

    # check if rsync is installed
    if [ `command -v rsync | grep rsync | wc -l` -eq 0 ]
    then
        echo Please install \"rsync\" before running the restore command
        exit 1
    fi

    if [ $running -gt 0 ]
    then
        # running

        # enter the repo's root directory
        REPO="$( dirname ${BASH_SOURCE[0]} )/../"
        cd $REPO

        BACKUP_DIR="backups/backup_$1"
        # check if the backup name has been provided including the backup_ prefix
        if [ ! -d $BACKUP_DIR ] && [ -d "backups/$1" ]
        then
            BACKUP_DIR="backups/$1"
        fi

        echo Restoring sugar from \"$BACKUP_DIR\"

        # if it is our repo, and the source exists, and the destination does not
        if [ -f '.gitignore' ] && [ -d 'data' ] && [ -d $BACKUP_DIR ] && [ -d $BACKUP_DIR/sugar ] && ( [ -f $BACKUP_DIR/sugar.sql ] || [ -f $BACKUP_DIR/sugar.sql.tgz ] )
        then
            if [ -d 'data/app/sugar' ]
            then
                rm -rf data/app/sugar
            fi
            echo Restoring application files
            sudo rsync -a $BACKUP_DIR/sugar data/app/
            echo Application files restored

            echo Restoring database
            docker exec -it sugar-mysql mysqladmin -h localhost -f -u root -proot drop sugarcasabaca12 | grep -v "mysqladmin: \[Warning\]"
            docker exec -it sugar-mysql mysqladmin -h localhost -u root -proot create sugarcasabaca12 | grep -v "mysqladmin: \[Warning\]"
            docker exec -it sugar-mysql mysqladmin -h localhost -f -u root -proot drop base_intermedia_cb | grep -v "mysqladmin: \[Warning\]"
            docker exec -it sugar-mysql mysqladmin -h localhost -u root -proot create base_intermedia_cb | grep -v "mysqladmin: \[Warning\]"
    

            if [ -f $BACKUP_DIR/sugarcasabaca12.sql.tgz ]
            then
                if hash tar 2>/dev/null; then
                    tar -zxf $BACKUP_DIR/sugarcasabaca12.sql.tgz
                    echo Database uncompressed to $BACKUP_DIR/sugarcasabaca12.sql
                    tar -zxf $BACKUP_DIR/base_intermedia_cb.sql.tgz
                    echo Database uncompressed to $BACKUP_DIR/base_intermedia_cb.sql
                fi
            fi

            if [ -f $BACKUP_DIR/sugar.sql ]
            then
                cat $BACKUP_DIR/sugarcasabaca12.sql | docker exec -i sugar-mysql mysql -h localhost -u root -proot sugarcasabaca12
                echo Database restored
                cat $BACKUP_DIR/base_intermedia_cb.sql | docker exec -i sugar-mysql mysql -h localhost -u root -proot base_intermedia_cb
                echo Database restored
            else
                echo Database not found! The selected restore is corrupted
                exit 1
            fi

            if [ -f $BACKUP_DIR/sugarcasabaca12.sql.tgz ]
            then
                if [ -f $BACKUP_DIR/sugarcasabaca12.sql ]
                then
                    rm $BACKUP_DIR/sugarcasabaca12.sql
                fi
            fi
            if [ -f $BACKUP_DIR/base_intermedia_cb.sql.tgz ]
            then
                if [ -f $BACKUP_DIR/base_intermedia_cb.sql ]
                then
                    rm $BACKUP_DIR/base_intermedia_cb.sql
                fi
            fi

            # refresh all transient storages
            ./utilities/build/refreshsystem.sh

            echo Repairing system
            ./utilities/repair.sh
            echo System repaired

            echo Performing Elasticsearch re-index
            ./utilities/runcli.sh "./bin/sugarcrm search:silent_reindex"
            echo Restore completed!
        else
            if [ ! -d 'data' ]
            then
                echo \"data\" cannot be empty, the command needs to be executed from within the clone of the repository
            fi

            if [ ! -d $BACKUP_DIR/sugar ]
            then
                echo \"$BACKUP_DIR/sugar\" cannot be empty
            fi

            if [ ! -f $BACKUP_DIR/sugarcasabaca12.sql ]
            then
                echo \"$BACKUP_DIR/sugarcasabaca12.sql\" does not exist
            fi
            if [ ! -f $BACKUP_DIR/base_intermedia_cb.sql ]
            then
                echo \"$BACKUP_DIR/base_intermedia_cb.sql\" does not exist
            fi

            if [ ! -d $BACKUP_DIR ]
            then
                echo $BACKUP_DIR does not exist
            fi
        fi

    else
        echo The stack is not running, please start the stack first
    fi
fi
