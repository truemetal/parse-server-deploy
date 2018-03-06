function bail_out {
	echo -e "\033[31;7mThis script supports only Ubuntu 16.04. Terminating.\e[0m"
	exit 1
}

if ! [ -x "$(command -v lsb_release)" ]; then
	bail_out
fi

if [ $(lsb_release -i -s) != "Ubuntu" ] || [ $(lsb_release -r -s) != "16.04" ]; then 
	bail_out
fi

export APP_ID=$(uuidgen)
export MASTER_KEY=$(uuidgen)
export DASHBOARD_LOGIN_USER="parse"
export DASHBOARD_LOGIN_PASSWORD=$(uuidgen)
export IP=$(curl -s api.ipify.org)

echo ""
echo "==========="
echo "Here're your credentials:"
echo "==========="
echo ""
echo "APP_ID: $APP_ID"
echo "MASTER_KEY: $MASTER_KEY"
echo "Dashboard login username: $DASHBOARD_LOGIN_USER"
echo "Dashboard login password: $DASHBOARD_LOGIN_PASSWORD"
echo "Parse server url: http://$IP:4040/parse"
echo "Parse Dashboard url: http://$IP:4040/db"
echo ""
echo -e "Press enter to continue...\n"; read


#===========
# update the system
#===========

apt-get update
apt-get -y upgrade
apt-get -y dist-upgrade

#===========
# install node
#===========

apt-get install -y nodejs
apt-get install -y npm

#===========
# update node if needed (min 4.3)
#===========

sudo npm install -g n
sudo n stable

#===========
# install mongodb
#===========

apt-get install -y mongodb

cat << EOF > /etc/systemd/system/mongodb.service
[Unit]
Description=High-performance, schema-free document-oriented database
After=network.target

[Service]
User=mongodb
ExecStart=/usr/bin/mongod --quiet --config /etc/mongodb.conf

[Install]
WantedBy=multi-user.target
EOF

systemctl enable mongodb

#===========
# deploy express app
#===========

mkdir ~/parse-server
mkdir ~/parse-server/cloud
mkdir ~/parse-server/public

# parse-server/cloud/main.js

cat << EOF > ~/parse-server/cloud/main.js
Parse.Cloud.define('hello', function(req, res) {
  res.success('Hi');
});
EOF

# parse-server/public/it-works.html

cat << EOF > ~/parse-server/public/it-works.html
<h1><center>It works!</center></h1>
EOF

# parse-server/package.json

cat << EOF > ~/parse-server/package.json
{
  "main": "index.js",
  "license": "MIT",
  "dependencies": {
    "express": "~4.11.x",
    "kerberos": "~0.0.x",
    "parse": "~1.8.0",
    "parse-server": "*",
    "parse-dashboard": "*"
  },
  "scripts": {
    "start": "node index.js"
  },
  "engines": {
    "node": ">=4.3"
  }
}
EOF

# parse-server/index.js

cat << EOF > ~/parse-server/index.js
var express = require('express');
var ParseServer = require('parse-server').ParseServer;
var ParseDashboard = require('parse-dashboard');
var path = require('path');

var appId = '$APP_ID';
var masterKey = '$MASTER_KEY';

var api = new ParseServer({
	databaseURI: 'mongodb://localhost:27017/parse',
	cloud: __dirname + '/cloud/main.js',
	appId: appId,
	masterKey: masterKey, //Add your master key here. Keep it secret!
	serverURL: 'http://localhost/parse',  // Don't forget to change to https if needed
	liveQuery: {
		classNames: ["Posts", "Comments"] // List of classes to support for query subscriptions
	}
});

var dashboard = new ParseDashboard({
	  "apps": [
		{
		  "serverURL": "http://$IP:4040/parse",
		  "appId": appId,
		  "masterKey": masterKey,
		  "appName": "Parse test app"
		}
	  ],
	  "users": [
		{
		  "user":"$DASHBOARD_LOGIN_USER",
		  "pass":"$DASHBOARD_LOGIN_PASSWORD"
		}
	  ],
	  "useEncryptedPasswords": false,
}, 
{ allowInsecureHTTP: true }
);

var app = express();

app.use('/parse', api);
app.use('/db', dashboard);
app.use('/public', express.static(path.join(__dirname, '/public')));

app.get('/', function(req, res) {
	res.sendFile(path.join(__dirname, '/public/it-works.html'));
});

var httpServer = require('http').createServer(app);
httpServer.listen(4040);
EOF

#===========
# install dependencies
#===========

cd ~/parse-server
npm install

#===========
# run parse as a service
#===========

npm install -g pm2
pm2 start ~/parse-server/index.js
pm2 startup systemd
