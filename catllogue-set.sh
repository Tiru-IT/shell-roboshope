#!/bin/bash
set -e
trap 'echo "there is error in $LINENO, command is: $BASH_COMMAND"' ERR

USER_ID=$(id -u)
R="\e[31m"
G="\e[32m"
R="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshope"
SCRIPT_NAME=$(echo $0 | cut -d "-" -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD
mongodb_ip="mongodb.tirusatrapu.fun"

mkdir -p $LOGS_FOLDER

SATRT_TIME=$(date +%s)
echo "Scripet started and exicuted is: $(date)" | tee -a $LOG_FILE

if [ $USER_ID -ne 0 ]; then 
    echo "ERROR:: please run this script with root user"
    exit 1
fi 
# nodjs started


dnf module disable nodejs -y &>>$LOG_FILE
dnf module enable nodejs:20 -y &>>$LOG_FILE
dnf install nodejs -y &>>$LOG_FILE
echo -e "install nodjs $G success $N"


id roboshop &>>$LOG_FILE

if [ $? -ne 0 ]; then 
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
else
    echo -e "user already exicute $Y...SKIPPING $N"
fi

mkdir -p /app 
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE 
cd /app
rm -rf /app/* &>>$LOG_FILE 
unzip /tmp/catalogue.zip &>>$LOG_FILE
echo -e "appilication nodjs $G success $N"
 
npm install &>>$LOG_FILE

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service &>>$LOG_FILE
systemctl daemon-reload
systemctl enable catalogue &>>$LOG_FILE

#client mongosh installl

dnf install mongodb-mongosh -y &>>$LOG_FILE

INDEX=$(mongosh $mongodb_ip --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')") &>>$LOG_FILE
if [ $INDEX -ne 0 ]; then 
    mongosh --host $mongodb_ip </app/db/master-data.js &>>$LOG_FILE
else
    echo -e "User already exit $Y SKIPPING $N"
fi 

systemctl restart catalogue &>>$LOG_FILE


END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $SATRT_TIME ))
echo -e "Script exicuted in $TOTAL_TIME $Y seconds $N"