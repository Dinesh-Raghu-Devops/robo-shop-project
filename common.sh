log=/tmp/logfile
func_nodeJS(){
  echo -e "\e[33m<<<<<<Configuring nodeJS repos>>>>>>\e[0m"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log}
  echo $?
  echo -e "\e[33m<<<<<<Installing NodeJS>>>>>>\e[0m"
  yum install nodejs -y &>>${log}
  echo $?
  echo -e "\e[33m<<<<<<creating user roboshop>>>>>>\e[0m"
  useradd roboshop &>>${log}
  echo $?
  echo -e "\e[33m<<<<<<Copying ${component} file to systemd>>>>>>\e[0m"
  cp ${component}.service /etc/systemd/system/ &>>${log}
  echo $?
  echo -e "\e[33m<<<<<<Creating application directory>>>>>>\e[0m"
  mkdir /app &>>${log}
  echo $?
  echo -e "\e[33m<<<<<<Insalling application>>>>>>\e[0m"
  curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log}
  echo $?
  cd /app &>>${log}
  echo $?
  unzip /tmp/${component}.zip &>>${log}
  echo $?
  cd /app &>>${log}
  echo $?
  echo -e "\e[33m<<<<<<Installing npm modules>>>>>>\e[0m"
  npm install &>>${log}
  echo $?
  echo -e "\e[33m<<<<<<restarting the services>>>>>>\e[0m" &>>${log}
  systemctl daemon-reload &>>${log}
  systemctl enable ${component} &>>${log}
  echo $?
  systemctl start ${component} &>>${log}
  echo $?
  echo -e "\e[33m<<<<<<Copying mongo repos to yum.repos.d>>>>>>\e[0m"
  cp mongo.repo /etc/yum.repos.d/ &>>${log}
  echo $?
  echo -e "\e[33m<<<<<<Installing mongodb shell >>>>>>\e[0m"
  yum install mongodb-org-shell -y &>>${log}
  echo $?
  echo -e "\e[33m<<<<<<Loading schema>>>>>>\e[0m"
  mongo --host 172.31.41.3 < /app/schema/${component}.js &>>${log}
  echo $?
}


