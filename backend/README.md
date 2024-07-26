# Factory Logs Backend
### Author: AlvyneZ
This repository contains the code for a web-based application designed for
 managing the processes, logs and shifts of a factory.  
The application is aimed mainly at providing a centralised data store for all
 catalogs of a factory.  

## Technologies Used
- NodeJS 14.21.3 is used. The packages used can be found in the packages.json.
- Express is the web framework used.
- Bcrypt is used for hashing passwords.
- JSON Web Tokens are used for session tokens.
- Mongoose is the Database ORM used.
- local mongoDB (dockerised) instance is used for development purposes.

## Environment Variables
Environment variables may be provided via a .env file in the root of the
 project or directly in the terminal using:
```
$ export VARIABLE_NAME=VARIABLE_VALUE
```

The following Variables are used by the program:
```
ACCESS_TOKEN_SECRET     /* Required */
REFRESH_TOKEN_SECRET    /* Required */
/* 
 *The TOKEN SECRETs may be generated from node in the terminal using:
 * $ node
 * > require('crypto').randomBytes(64).toString('hex')
 */

NODE_ENV                /* Defaults to 'development' */
NODE_PORT               /* Defaults to 3000 */
```

## HTTPS Key generation
The HTTPS is not yet configured (for simplicity) but should it be needed, a
 self-signed certificate may be used for the development and generated in
 the "sslcert" folder with the following commands:
```
$   openssl genrsa -out key.pem
$   openssl req -new -key key.pem -out csr.pem
$   openssl x509 -req -days 9999 -in csr.pem -signkey key.pem -out cert.pem
```

## Database Setup
A README.md file exists in the ./mongodb folder to guide in the setup of
 a docker container for the local MongoDB server for testing.  

For enhanced security, the Web application will not provide an endpoint for
 adding factories and their admins. A console application is provided for
 this (**"factory_management.js"**). The following command can be run to
 view its usage:
```
$   node ./factory_management.js --help
```

Once at least one factory and admin are available in the system, the admin
 has the ability to edit the factory and to add new users associated with
 their same factory.
