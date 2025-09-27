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
# mysql instal ....

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "install mysql"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "enable mysql"

systemctl start mysqld
VALIDATE $? "sart mysqld"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE
VALIDATE $? "set password"


END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $SATRT_TIME ))
echo -e "Script exicuted in $TOTAL_TIME $Y seconds $N"
