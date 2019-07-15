#!/bin/sh
#File: deploy.sh
#Author: Vamsi
#Params: deploy|start|stop

user="ubuntu"
hostip="3.83.48.60"
APP_DIR="/home/lekkala/Documents/Deployment_Automation_with_ShellScripting/Leadapp"
APP_NAME="leadapp"
TABLE_NAME="lead"
TOMCAT_HOME="/home/ubuntu/apache-tomcat-8.5.41"
mysql_user="user"
mysql_pass="pass"


echo "Started task at:" `date`
deployDB()
{
    echo "---started deploying DB"
    scp $APP_DIR/src/database/schema.sql $user@$hostip:DB
    ssh $user@$hostip "mysql -u$mysql_user -p$mysql_pass $APP_DIR $TABLE_NAME < ~/DB/schema.sql"
}
backupDB()
{
    echo "---started backuping DB"
}
deployApp()
{
    echo "---started deploying app"
    scp $APP_DIR/dist/lib/$APP_NAME.war $user@$hostip:$TOMCAT_HOME/webapps/
}
backupApp()
{
    echo "---started backuping app"
    ssh $user@$hostip "mv $APP_DIR/webapps/$APP_NAME* ~/DB/"
}
stopTomcat()
{
    echo "---stopping tomcat"
    ssh $user@$hostip "sh $TOMCAT_HOME/bin/shutdown.sh"
}
startTomcat()
{
    echo "---starting tomcat"
    ssh $user@$hostip "sh $TOMCAT_HOME/bin/startup.sh"
}
if [ $# -eq 1 ]
then
case $1 in
deploy) stopTomcat
        backupApp
        deployApp
        backupDB
        deployDB
        startTomcat ;;
stop)   stopTomcat;;
start)  startTomcat;;
restart)stopTomcat
        startTomcat;;
*)      echo "USECASE: sh deploy.sh start|stop|restart|deploy";;
esac
else
echo "USECASE: sh deploy.sh start|stop|restart|deploy"
fi
echo "Completed task at:" `date`