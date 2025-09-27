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
MYSQL_HOST="mysql.tirusatrapu.fun"
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
VALIDATE $? "install maven"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
else
    echo -e "user already exit $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "create directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "download code"

cd /app 
VALIDATE $? "move to app directory"

rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "remove the code"

unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "unzip the code"


mvn clean package &>>$LOG_FILE
VALIDATE $? "clean the package"

mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
VALIDATE $? "target the file"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$LOG_FILE
VALIDATE $? "system shipping service"

systemctl daemon-reload
systemctl enable shipping &>>$LOG_FILE
VALIDATE $? " enable shipping"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "install mysql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
else
    echo -e "Shipping data is already loaded ... $Y SKIPPING $N"
fi
systemctl restart shipping
echo -e "Install $G SUCCESS $N"






END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $SATRT_TIME ))
echo -e "Script exicuted in $TOTAL_TIME $Y seconds $N"
