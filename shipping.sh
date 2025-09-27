#!/bin/bash
set -e
trap "thre is an ERROR in $lINENO ,command is: $BASH_COMMAND" ERR

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
MONGODB_HOST="mysql.tirusatrapu.fun"
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

#shipping install

dnf install maven -y &>>$LOG_FILE
id roboshop &>>$LOG_FILE
if [ $? -ne ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
else
    echo -e "user already exit $Y SKIPPING $N"
fi

mkdir /app &>>$LOG_FILE
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
cd /app 
rm -rf /app/* &>>$LOG_FILE
unzip /tmp/shipping.zip &>>$LOG_FILE

mvn clean package &>>$LOG_FILE
mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$LOG_FILE
systemctl daemon-reload
systemctl enable shipping &>>$LOG_FILE

dnf install mysql -y &>>$LOG_FILE
mysql -h $MONGODB_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
mysql -h $MONGODB_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOG_FILE
mysql -h $MONGODB_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE

systemctl restart shipping
echo -e "Install $G SUCCESS $N"






END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $SATRT_TIME ))
echo -e "Script exicuted in $TOTAL_TIME $Y seconds $N"
