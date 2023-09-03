log=/tmp/logfile
mongo_schema=true
func_service(){
  echo -e "\e[33m<<<<<<restarting the services>>>>>>\e[0m" &>>${log}
  systemctl daemon-reload &>>${log}
  systemctl enable ${component} &>>${log}
  systemctl start ${component} &>>${log}
  if [ $? -eq 0 ];then
    echo "SUCCESS"
  else
    echo "FAILED"
  fi
}
func_appconfig(){
  echo -e "\e[33m<<<<<<Creating application directory>>>>>>\e[0m"
  mkdir /app &>>${log}
    if [ $? -eq 0 ]; then
      echo "SUCCESS"
     else
        echo "FAILED"
    fi
  echo -e "\e[33m<<<<<<Insalling application>>>>>>\e[0m"
  curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log}
  cd /app &>>${log}
    if [ $? -eq 0 ]; then
      echo "SUCCESS"
     else
        echo "FAILED"
    fi
  unzip /tmp/${component}.zip &>>${log}
  cd /app &>>${log}
  echo -e "\e[33m<<<<<<Installing npm modules>>>>>>\e[0m"
  npm install &>>${log}
    if [ $? -eq 0 ]; then
      echo "SUCCESS"
     else
        echo "FAILED"
    fi
  if [ "{mongo_schema}" == "true" ]; then
    echo -e "\e[33m<<<<<<Installing mongodb shell >>>>>>\e[0m"
    yum install mongodb-org-shell -y &>>${log}
    echo -e "\e[33m<<<<<<Loading schema>>>>>>\e[0m"
    mongo --host mongodb.dineshdevops.com < /app/schema/${component}.js &>>${log}
  fi
  echo $?
}
func_nodeJS(){
  echo -e "\e[33m<<<<<<Copying mongo repos to yum.repos.d>>>>>>\e[0m"
  cp mongo.repo /etc/yum.repos.d/mongo.repo &>>${log}
  if [ $? -eq 0 ]; then
    echo "SUCCESS"
   else
      echo "FAILED"
  fi
  echo -e "\e[33m<<<<<<Copying ${component} file to systemd>>>>>>\e[0m"
  cp ${component}.service /etc/systemd/system/ &>>${log}
  if [ $? -eq 0 ]; then
      echo "SUCCESS"
     else
      echo "FAILED"
  fi
  echo -e "\e[33m<<<<<<Configuring nodeJS repos>>>>>>\e[0m"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log}
  if [ $? -eq 0 ]; then
      echo "SUCCESS"
     else
      echo "FAILED"
  fi
  echo -e "\e[33m<<<<<<Installing NodeJS>>>>>>\e[0m"
  yum install nodejs -y &>>${log}
  if [ $? -eq 0 ]; then
        echo "SUCCESS"
       else
        echo "FAILED"
  fi
  echo -e "\e[33m<<<<<<creating user roboshop>>>>>>\e[0m"
  useradd roboshop &>>${log}
  if [ $? -eq 0 ]; then
        echo "SUCCESS"
       else
        echo "FAILED"
  fi
  echo -e "\e[33m<<<<<<Removing if app directory exists>>>>>>\e[0m"
  rm -rf /app
  if [ $? -eq 0 ]; then
        echo "SUCCESS"
       else
        echo "FAILED"
  fi

  func_appconfig

  func_service
}



