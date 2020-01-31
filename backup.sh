#!/usr/bin/env bash

#LVM Backups

YELLOW="\e[33m"
GREEN="\e[32m"
RED="\e[31m"
NORMAL="\e[39m"

VG_NAME="vg0" 
LV_NAME="/dev/vg0/usr"
S_NAME="backup"
TARGET_FOLDER="/test"
S_FOLDER="/backup"
DATE=`date +%m-%d-%y`
BACKUP_FOLDER="/md-1"
BACKUP_PATH="$BACKUP_FOLDER/$S_NAME\_$DATE.tar"


backup(){
        echo -e "$YELLOW Create snapshot $NORMAL"
        lvcreate -L 512M -s -p r -n $S_NAME $LV_NAME 2>&1 1>/dev/null
                            
        if [ $? == 0 ]
        then
		echo -e "$GREEN Snapshot successfully created $NORMAL"
                                    
                if [ -d "/backup" ]
                then
                        echo -e "$YELLOW Mount snapshot into $S_FOLDER folder $NORMAL"
		        mount /dev/$VG_NAME/$S_NAME $S_FOLDER 2>&1 1>/dev/null
		        if [ $? == 0 ]
		        then
                                echo -e "$GREEN Snapshot is mounted sucessfully $NORMAL"
		        fi
                        echo -e "$YELLOW Create .tar archive $NORMAL"
                        tar -cvf $BACKUP_PATH $S_FOLDER 2>&1 1>/dev/null
                                            
                                if [ $? == 0 ]
                                then
                                        echo -e "$GREEN Backup successfully created $NORMAL"
                                        umount $S_FOLDER
                                        lvremove -y /dev/$VG_NAME/$S_NAME
                                else
                                        echo -e "$RED Error making backup $NORMAL"
                                        umount $S_FOLDER
                                        lvremove -y /dev/$VG_NAME/$S_NAME
                                fi
                else
                        echo -e "$YELLOW Create backup folder $NORMAL"
                        mkdir $S_FOLDER
                        echo -e "$YELLOW Mount snapshot into $S_FOLDER folder $NORMAL"
		        mount /dev/$VG_NAME/$S_NAME $S_FOLDER 2>&1 1>/dev/null
		        if [ $? == 0 ]
		        then
                                echo -e "$GREEN Snapshot is mounted sucessfully $NORMAL"
		        fi                                        
                        echo -e "$YELLOW Create .tar archive $NORMAL"
                        tar -cvf $BACKUP_PATH $S_FOLDER 2>&1 1>/dev/null
                                            
                                if [ $? == 0 ]
                                then
                                        echo -e "$GREEN Backup successfully created $NORMAL"
                                        umount $S_FOLDER
                                        lvremove -y /dev/$VG_NAME/$S_NAME 
                                else
                                        echo -e "$RED Error making backup $NORMAL"
                                        umount $S_FOLDER
                                        lvremove -y /dev/$VG_NAME/$S_NAME
                                            
                                fi
                                    
                fi
        else
                echo -e "$RED Error creating snapshot $NORMAL"
                            
        fi
}

main(){
if [ `vgs | awk '{if (NR==2) print $1}'` = $VG_NAME ]
then
    
    if [ `lvs | grep $S_NAME 2>&1 1>/dev/null; echo $?` -eq 1 ] && [ -d $TARGET_FOLDER ]
    then
        
            if [ `vgs | awk '{if (NR==2) print $7}' | awk -F "" '{print $5}'` = "g" ]
            then
                    VG_SIZE=`vgs | awk '{if (NR==2) print $7}' | awk -F "" '{print $1}'`
                    
                    if [ $VG_SIZE -ge 1 ];
                    then
                         backup  
                    else
                            echo -e "$RED No space left on VG, aborting! $NORMAL"
                    
                    fi
            elif [`vgs | awk '{if (NR==2) print $7}' | awk -F "" '{print $5}'` == "m"]
            then
                    VG_SIZE=`vgs | awk '{if (NR==2) print $7}' | awk -F "" '{print $1$2$3$4}'`
                    
                    if [ $VG_SIZE -ge 1024 ];
                    then
                            backup
                    else
                            echo -e "$RED No space left on VG, aborting! $NORMAL"
                    fi
            else
                    echo -e "$RED Unexpected Vg's size, aborting! $NORMAL"
            fi

    else
            echo -e "$RED lv $S_NAME is present or $TARGET_FOLDER folder not exist, aborting! $NORMAL"
    fi
else
    echo -e "$RED VG does not exist, aborting! $NORMAL" 
fi
}

main
