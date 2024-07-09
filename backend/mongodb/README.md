# Factory Logs Database
### Sys Eng: AlvyneZ

The following command was used to create the docker container of the
 mongodb instance used in the development of the backend (executing
 from within the "/backend" folder):
```
$   chmod 777 ./mongodb/cfg ./mongodb/data ./mongodb/logs
$   docker network create factory-net
$   docker run -d --network factory-net \
        --name mongo-factory-log \
        -v "$(pwd)/mongodb/cfg":/etc/mongo \
        -v "$(pwd)/mongodb/logs":/var/log/mongodb \
        -v "$(pwd)/mongodb/data":/data/db \
	    -e MONGO_INITDB_ROOT_USERNAME=mongoadmin \
	    -e MONGO_INITDB_ROOT_PASSWORD=secret \
        -p 27017:27017 \
	    mongo:8.0-rc --config /etc/mongo/mongod.conf
```
*Note: The mounted volumes should have all permissions (chmod 777)*


The following sequences of commands can be used to access the container's
 terminal and then open mongosh:
```
$   docker exec -it mongo-factory-log bash
#   mongosh --host 127.0.0.1 \
        -u mongoadmin \
        -p secret \
        --authenticationDatabase admin
```

Alternatively a temporary container may be created to access the database.
 The following command may be used to achieve this:
```
$   docker run -it --rm --network factory-net mongo:8.0-rc \
        mongosh --host mongo-factory-log \
        -u mongoadmin -p secret \
        --authenticationDatabase admin
```

When connecting to the MongoDB instance of the container, the following
 connection string may be used:  
**"mongodb://mongoadmin:secret@127.0.0.1:27017/"**
