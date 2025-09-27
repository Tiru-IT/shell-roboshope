#!/bin/bash
#set -e
#trap "thre is an ERROR in $LINENO ,command is: $BASH_COMMAND" ERR

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

#rabbitmq install...
cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "copy the systemctl service"

dnf install rabbitmq-server -y &>>$LOG_FILE

systemctl enable rabbitmq-server &>>$LOG_FILE
systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "install rabbitmq server"
echo -e "install $G SUCCESS $N"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
else
    echo -e "user already exit $Y SKIPPING $N"
fi 

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
echo -e "rabbit mq $G success $N"


END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $SATRT_TIME ))
echo -e "Script exicuted in $TOTAL_TIME $Y seconds $N"