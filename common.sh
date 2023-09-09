log=/tmp/logfile
func_exitstatus(){
   if [ $? -eq 0 ];then
      echo "SUCCESS"
    else
      echo "FAILED"
    fi
}
func_service(){
  echo -e "\e[33m<<<<<<Restarting the services>>>>>>\e[0m"
  systemctl daemon-reload &>>${log}
  systemctl enable ${component} &>>${log}
  systemctl start ${component} &>>${log}

  func_exitstatus
 }
func_appconfig(){
  echo -e "\e[33m<<<<<<creating user roboshop>>>>>>\e[0m"
  useradd roboshop &>>${log}
  func_exitstatus
  echo -e "\e[33m<<<<<<Removing if app directory exists>>>>>>\e[0m"
  rm -rf /app
  func_exitstatus
  echo -e "\e[33m<<<<<<Creating application directory>>>>>>\e[0m"
  mkdir /app &>>${log}
  func_exitstatus
  echo -e "\e[33m<<<<<<Insalling application>>>>>>\e[0m"
  curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log}
  cd /app &>>${log}
  func_exitstatus
  unzip /tmp/${component}.zip &>>${log}
  cd /app &>>${log}
}
func_copyservicefile(){
    echo -e "\e[33m<<<<<<Copying ${component} file to systemd>>>>>>\e[0m"
    cp ${component}.service /etc/systemd/system/ &>>${log}
    func_exitstatus
}
func_nodeJS(){
  func_copyservicefile
  echo -e "\e[33m<<<<<<Configuring nodeJS repos>>>>>>\e[0m"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log}
  func_exitstatus
  echo -e "\e[33m<<<<<<Installing NodeJS>>>>>>\e[0m"
  yum install nodejs -y &>>${log}
  func_exitstatus
  func_appconfig
  echo -e "\e[33m<<<<<<Installing npm modules>>>>>>\e[0m"
  npm install &>>${log}
  func_exitstatus
  func_schema
  func_service
}
func_java(){
  func_copyservicefile
  yum install maven -y &>>${log}
  func_exitstatus
  func_appconfig
  mvn clean package &>>${log}
  mv target/${component}-1.0.jar ${component}.jar &>>${log}
  func_exitstatus
  func_schema
  func_service

}

func_python(){
  func_copyservicefile
  echo -e "\e[33m<<<<<<Installing Python packages>>>>>>\e[0m"
  yum install python36 gcc python3-devel -y &>>${log}
  func_exitstatus
  func_appconfig
  echo -e "\e[33m<<<<<<Installing pip3>>>>>>\e[0m"
  pip3.6 install -r requirements.txt &>>${log}
  func_exitstatus
  func_service

}
func_golang(){
   func_copyservicefile
   echo -e "\e[33m<<<<<<Installing GoLang packages>>>>>>\e[0m"
   yum install golang -y &>>${log}
   func_exitstatus
   func_appconfig
   go mod init dispatch &>>${log}
   go get &>>${log}
   go build &>>${log}
   func_service

}
func_schema(){
    if [ "${schema_type}" == "mongodb" ]; then
          echo -e "\e[33m<<<<<<Copying mongo repos to yum.repos.d>>>>>>\e[0m"
          cd ~/robo-shop-project
          cp mongo.repo /etc/yum.repos.d/mongo.repo &>>${log}
          func_exitstatus
          echo -e "\e[33m<<<<<<Installing mongodb shell >>>>>>\e[0m"
          yum install mongodb-org-shell -y &>>${log}
          func_exitstatus
          echo -e "\e[33m<<<<<<Loading schema>>>>>>\e[0m"
          mongo --host mongodb.dineshdevops.com </app/schema/${component}.js &>>${log}
          func_exitstatus
    fi
    if [ "${sql_schema}" == "true" ]; then
       echo -e "\e[33m<<<<<<Installing Mysql >>>>>>\e[0m"
       yum install mysql -y  &>>${log}
       echo -e "\e[33m<<<<<<Loading schema>>>>>>\e[0m"
       mysql -h mysql.dineshdevops.com -uroot -pRoboShop@1 < /app/schema/shipping.sql &>>${log}
    fi
    func_exitstatus
}

