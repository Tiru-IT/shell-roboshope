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
SATRT_TIME=$(date +%s)
echo -e "Script started and exicuted is: $(date)" | tee -a $LOG_FILE

#user 

dnf module disable nodejs -y &>>$LOG_FILE
dnf module enable nodejs:20 -y &>>$LOG_FILE
dnf install nodejs -y &>>$LOG_FILE
echo -e "user install $G SUCCESS $N" 

#id roboshop &>>$LOG_FILE
#id roboshop &>>$LOG_FILE
#if [ $? -ne 0 ]; then
 #   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
#else
 #   echo -e "user already exicuted $Y SKIPPING $N"
#fi

id roboshope &>>$LOG_FILE 
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
else
    echo -e "User already exit $Y SKIPPING $N"
fi

mkdir -p /app 

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOG_FILE
cd /app 
rm -rf /app/*
unzip /tmp/user.zip &>>$LOG_FILE
npm install &>>$LOG_FILE

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service &>>$LOG_FILE
systemctl daemon-reload
systemctl enable user &>>$LOG_FILE
systemctl start user


END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $SATRT_TIME ))
#TOTAL_TIME=$(( $END_TIME - $SATRT_TIME ))
echo -e "Script exicuted in $TOTAL_TIME, $Y secoends $N"