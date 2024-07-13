# Factory Logs Database
### Sys Eng: AlvyneZ
Note: All shell commands listed in this file are run from the same
 working directory as this README.md file, ie *"backend/mongodb/"*.

## Local Database Instance Setup
A Makefile is included to automate the setup and has "clean", "setup"
 and "refresh" targets. To setup the database:
```
$   make clean
$   make setup
```
The following explains what is needed for the data base setup (and
 accomplished by the Makefile).


### Docker Volumes
For persistence of data, docker's volume mounting feature will be used
 for the following folders: **"./cfg", "./data" and "./logs"**. These
 folders need to be created and given full permissions as follows:
```
$   mkdir ./cfg ./data ./logs
$   chmod 777 ./cfg ./data ./logs
```

### Mongo Conf
The configuration file **"./cfg/mongod.conf"** should contain the
 following configurations:
```
storage:
  dbPath: /data/db

systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

net:
  port: 27017
  bindIp: 0.0.0.0

setParameter:
  enableLocalhostAuthBypass: false

processManagement:
  timeZoneInfo: /usr/share/zoneinfo

security:
  keyFile: /etc/mongo/rs0.key

replication:
  replSetName: rs0
```

### Mongo Key File (ReplSet) 
In order to use mongodb's advanced features such as transactions, the
 database needs to be run as a replica set. For development purposes,
 the database will be run as a single-node replica set.  

Authorization using a key file is required to run a mongodb instance
 in a replica set. For this, the following commands were used to
 create the key file:
```
$   openssl rand -base64 756 > ./cfg/rs0.key
$   chmod 400 ./cfg/rs0.key
$   sudo chown 999:999 ./cfg/rs0.key
```

### Docker Container
For the creation of the container a "docker-compose.yml" file is
 provided with the full configuration required to create the container
 after all the above steps are fulfilled.  
The following command was used to create the docker container of the
 mongodb instance used in the development of the backend:
```
$   docker compose up -d
```
If any errors come up or the container is unable to start up, the following
 command may be used to check the container's logs (StackOverflow is a
 friend):
```
$   docker logs mongo-factory-log
```

## Mongosh Access to Database
The following sequences of commands can be used to access the container's
 terminal and then open mongosh:
```
$   docker exec -it mongo-factory-log bash
#   mongosh --port 27017 \
        -u mongoadmin \
        -p secret \
        --authenticationDatabase admin
```

Alternatively a temporary container may be created to access the database.
 The following command may be used to achieve this:
```
$   docker run -it --rm --network factory-net mongo:8.0-rc \
        mongosh --host rs0/mongo-factory-log:27017 \
        -u mongoadmin -p secret \
        --authenticationDatabase admin
```

## Connection String
When connecting to the MongoDB instance of the container, the following
 connection string may be used:  
**"mongodb://mongoadmin:secret@172.17.0.1:27017/?replicaSet=rs0"**

Note: The connect string and dockercompose file both assume that the
 **docker network interface** has IP address **172.17.0.1**. To confirm
 the IP address, run ```ip address```, and look for "docker0". Then
 replace the IP address appropriately.
