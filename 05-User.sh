curl -sL https://rpm.nodesource.com/setup_lts.x | bash
yum install nodejs -y
useradd roboshop
cp user.service /etc/systemd/system/
mkdir /app
curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user.zip
cd /app
unzip /tmp/user.zip
cd /app
npm install
systemctl daemon-reload
cp mongo.repo /etc/yum.repos.d/
yum install mongodb-org-shell -y
systemctl enable user
systemctl start user
mongo --host 172.31.41.3 </app/schema/user.js
