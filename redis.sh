#!/bin/bash

set -e
trap 'echo "there is error in lineno $LINENO, command is: $BASH_COMMAND "' ERR

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then 
    echo -e "ERROR:: please run this command with  $R root user $N "
fi

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
SATRT_TIME=$(date +$s)
echo -e "Script started and exicuted is: $(date)" | tee -a $LOG_FILE

#redis installl....
dnf module disable redis -y &>>$LOG_FILE
dnf module enable redis:7 -y &>>$LOG_FILE
dnf install redis -y &>>$LOG_FILE
echo -e "redis install $G SUCCESS $N"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf &>>$LOG_FILE
#sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
systemctl enable redis 
systemctl start redis 
echo -e "redis start $G SUCCESS $N"



END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $SATRT_TIME ))
#TOTAL_TIME=$(( $END_TIME - $SATRT_TIME ))
echo -e "Script exicuted in $TOTAL_TIME, $Y secoends $N"