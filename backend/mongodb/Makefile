.PHONY: no_default clean setup start stop mongosh enter_container

MONGO_CFG_FOLDER=./cfg
MONGO_DATA_FOLDER=./data
MONGO_LOGS_FOLDER=./logs
MONGO_PERSISTENT=${MONGO_CFG_FOLDER} ${MONGO_DATA_FOLDER} ${MONGO_LOGS_FOLDER}

MONGO_CONF_FILE=${MONGO_CFG_FOLDER}/mongod.conf
MONGO_KEY_FILE=${MONGO_CFG_FOLDER}/rs0.key

DOCKER_BUILD_CMD=docker compose up -d
DOCKER_RM_CMD=docker rm -f
DOCKER_NET_RM_CMD=docker network rm -f
DOCKER_START_CMD=docker start
DOCKER_STOP_CMD=docker stop
DOCKER_STATUS_CMD=docker ps -a
DOCKER_EXEC_CMD=docker exec -it
DOCKER_CONTAINER_NAME=mongo-factory-log
DOCKER_NETWORK_NAME=factory-net

MONGODB_CRED=-u mongoadmin -p secret --authenticationDatabase admin

define MONGO_CONF_DATA
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
endef
export MONGO_CONF_DATA

no_default:
	@echo "No default make target configured. Please proceed as per acommpanying documentation."

clean:
	@echo ">>>>>>>>>>>> Removing the mongo-factory-log Docker Container <<<<<<<<<"
	${DOCKER_RM_CMD} ${DOCKER_CONTAINER_NAME}
	@echo ">>>>>>>>>>>> Removing the factory-net Docker Network <<<<<<<<<"
	${DOCKER_NET_RM_CMD} ${DOCKER_NETWORK_NAME}
	@echo ">>>>>>>>>>>> Removing the Docker persistent folders <<<<<<<<<"
	sudo rm -r ${MONGO_PERSISTENT}

setup:
	@echo ">>>>>>>>>>>> Creating the Docker persistent folders <<<<<<<<<"
	mkdir ${MONGO_PERSISTENT}
	chmod 777 ${MONGO_PERSISTENT}
	@echo ">>>>>>>>>>>> Creating Mongo configuration file <<<<<<<<<"
	@echo "$$MONGO_CONF_DATA" > ${MONGO_CONF_FILE}
	@echo ">>>>>>>>>>>> Creating Mongo security key file <<<<<<<<<"
	openssl rand -base64 756 > ${MONGO_KEY_FILE}
	chmod 400 ${MONGO_KEY_FILE}
	sudo chown 999:999 ${MONGO_KEY_FILE}
	@echo ">>>>>>>>>>>> Spinning up docker container <<<<<<<<<"
	${DOCKER_BUILD_CMD}
	@echo ">>>>>>>>>>>> Waiting 2 seconds to check status <<<<<<<<<"
	@sleep 2
	@${DOCKER_STATUS_CMD}

refresh: clean setup

start:
	@${DOCKER_START_CMD} ${DOCKER_CONTAINER_NAME}

stop:
	@${DOCKER_STOP_CMD} ${DOCKER_CONTAINER_NAME}

enter_container:
	@${DOCKER_EXEC_CMD} ${DOCKER_CONTAINER_NAME} bash

mongosh:
	@docker run -it --rm --network ${DOCKER_NETWORK_NAME} mongo:8.0-rc \
        mongosh --host rs0/mongo-factory-log:27017 ${MONGODB_CRED}
