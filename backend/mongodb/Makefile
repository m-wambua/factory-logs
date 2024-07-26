.PHONY: no_default clean setup start stop mongosh enter_container

MONGO_CFG_FOLDER=./cfg
MONGO_DATA_FOLDER=./data
MONGO_LOGS_FOLDER=./logs
MONGO_PERSISTENT=${MONGO_CFG_FOLDER} ${MONGO_DATA_FOLDER} ${MONGO_LOGS_FOLDER}

MONGO_CONF_FILE=${MONGO_CFG_FOLDER}/mongod.conf
MONGO_KEY_FILE=${MONGO_CFG_FOLDER}/rs0.key

DOCKER_BUILD_CMD=docker compose up -d
DOCKER_RM_CMD=docker compose down --volumes
DOCKER_START_CMD=docker compose start
DOCKER_STOP_CMD=docker compose stop
DOCKER_STATUS_CMD=docker compose ps -a
DOCKER_EXEC_CMD=docker exec -it
DOCKER_CONTAINER_NAME=factory-db
DOCKER_NETWORK_NAME=factory-net

DOCKER_GET_HOST_IP_CMD=export DOCKER_HOST_IP=$(shell \
 ip addr show docker0 | grep -oE "inet [.0-9]+\/" | grep -oE "[.0-9]+")

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
	@echo ">>>>>>>>>>>> Removing the Docker Compose services <<<<<<<<<"
	${DOCKER_GET_HOST_IP_CMD} && ${DOCKER_RM_CMD}
	@echo ">>>>>>>>>>>> Removing the Docker persistent folders <<<<<<<<<"
	-sudo rm -r ${MONGO_PERSISTENT}

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
	@echo ">>>>>>>>>>>> Spinning up docker compose services <<<<<<<<<"
	${DOCKER_GET_HOST_IP_CMD} && ${DOCKER_BUILD_CMD}
	@echo ">>>>>>>>>>>> Checking compose services status <<<<<<<<<"
	@#sleep 2
	@${DOCKER_STATUS_CMD}
	@echo "\n.................................................................."
	@echo ">>>>>>>>>>>>>>>>>>>>          Done!           <<<<<<<<<<<<<<<<<<<<"
	@echo ">>>>>>>>>>>>>>>>>>>>  Connect String to use:  <<<<<<<<<<<<<<<<<<<<"
	@${DOCKER_GET_HOST_IP_CMD} && echo ">>\033[0;32m mongodb://mongoadmin:secret@$${DOCKER_HOST_IP}:27017/?replicaSet=rs0 \033[0m<<"
	@echo "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\n"

refresh: clean setup

start:
	@${DOCKER_START_CMD}

stop:
	@${DOCKER_STOP_CMD}

enter_container:
	@${DOCKER_EXEC_CMD} ${DOCKER_CONTAINER_NAME} bash

mongosh:
	@docker run -it --rm --network ${DOCKER_NETWORK_NAME} mongo:8.0-rc \
        mongosh --host rs0/mongo-factory-log:27017 ${MONGODB_CRED}
