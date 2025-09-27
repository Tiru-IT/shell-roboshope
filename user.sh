#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USER_ID=$(id -u)

if [ $USER_ID -ne 0 ]; then
    echo "ERROR:: please run this command root user"
    exit 1
fi

SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.tirusatrapu.fun
SATRT_TIME=$(date +%s)

LOGS_FOLDER="/var/log/shell-roboshope"
SCRIOT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" #/var/log/shell-roboshop/catalogue.log

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ...$R FAILER $N" | tee -a $LOG_FILE
    else
        echo -e "$2 ...$G SUCCESS $N" | tee -a $LOG_FILE 
    fi
}

#user install....

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $1 "disable nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $1 "enable nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $1 "install nodejs"

id roboshope &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
else
    echo -e "User already exit $Y SKIPPING.. $N"
fi

mkdir -p /app 
VALIDATE $? "create directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOG_FILE
VALIDATE $? "download apilication code"

cd /app 
VALIDATE $? "change directary"

rm -rf /app/*
VALIDATE $? "remove the ecitued code"

unzip /tmp/user.zip &>>$LOG_FILE
VALIDATE $? "unzip the code"

npm install &>>$LOG_FILE
VALIDATE $? "npm install"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $?  "start system user"

systemctl daemon-reload 

systemctl enable user &>>$LOG_FILE
VALIDATE $? "enable user"

systemctl start user
VALIDATE $? "start user"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $SATRT_TIME ))
echo -e "Script exicuted in $TOTAL_TIME $Y seconds $N"
