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
MONGODB_HOST=
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
dnf module disable nginx -y
dnf module enable nginx:1.24 -y
dnf install nginx -y
VALIDATE $? "install nginx"
systemctl enable nginx 
systemctl start nginx 
VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/* 
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "download frontend code"
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
VALIDATE $? "unzip the code"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
systemctl restart nginx 
VALIDATE $? "restart nginx"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $SATRT_TIME ))
echo -e "Script exicuted in $TOTAL_TIME $Y seconds $N"