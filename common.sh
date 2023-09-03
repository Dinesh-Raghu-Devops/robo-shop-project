log=${log}
func_nodeJS(){
  echo -e "\e[33e<<<<<<Configuring nodeJS repos>>>>>>\e[0m"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> ${log}
  echo -e "\e[33e<<<<<<Installing NodeJS>>>>>>\e[0m"
  yum install nodejs -y &>> ${log} &>> ${log}
  echo -e "\e[33e<<<<<<creating user roboshop>>>>>>\e[0m"
  useradd roboshop &>> ${log}
  echo -e "\e[33e<<<<<<Copying ${component} file to systemd>>>>>>\e[0m"
  cp ${component}.service /etc/systemd/system/ &>> ${log}
  echo -e "\e[33e<<<<<<Creating application directory>>>>>>\e[0m"
  mkdir /app &>> ${log}
  echo -e "\e[33e<<<<<<Insalling application>>>>>>\e[0m"
  curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>> ${log}
  cd /app &>> ${log}
  unzip /tmp/${component}.zip &>> ${log}
  cd /app &>> ${log}
  echo -e "\e[33e<<<<<<Installing npm modules>>>>>>\e[0m"
  npm install &>> ${log}
  echo -e "\e[33e<<<<<<restarting the services>>>>>>\e[0m" &>> ${log}
  systemctl daemon-reload &>> ${log}
  systemctl enable ${component} &>> ${log}
  systemctl start ${component} &>> ${log}
  echo -e "\e[33e<<<<<<Copying mongo repos to yum.repos.d>>>>>>\e[0m"
  cp mongo.repo /etc/yum.repos.d/ &>> ${log}
  echo -e "\e[33e<<<<<<Installing mongodb shell >>>>>>\e[0m"
  yum install mongodb-org-shell -y &>> ${log}
  echo -e "\e[33e<<<<<<Loading schema>>>>>>\e[0m"
  mongo --host 172.31.41.3 </app/schema/${component}.js &>> ${log}
}


