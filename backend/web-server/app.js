'use strict';

const process = require('process');
require('dotenv').config();

const http = require('http');
//const https = require('https');
const express = require('express');
const cookieParser = require('cookie-parser');
const morgan = require('morgan');
const cors = require('cors');

const swaggerUI = require('swagger-ui-express');
const swaggerJsDoc = require('swagger-jsdoc');

const { mongoose, mongoConnect } = require('./models');

const PORT = process.env.NODE_PORT || 3000;
//const PORT_SEC = process.env.NODE_PORT_SEC || 3001;

const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Factory Log API',
      version: '1.0.0',
      description: 'A factory management API'
    },
    servers: [
      { url: '/' },
      { url: 'http://localhost:3000' },
      { url: 'https://localhost:3001' }
    ]
  },
  apis: ['./routes/*.js']
};
const swaggerSpecs = swaggerJsDoc(swaggerOptions);

const app = express();

app.use('/api-docs', swaggerUI.serve, swaggerUI.setup(swaggerSpecs));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(morgan('dev'));

// CORS middleware (for web interface)
const allowCrossDomain = (req, res, next) => {
  res.header('Access-Control-Allow-Methods', 'OPTIONS,GET,PUT,POST,DELETE');
  res.header('Access-Control-Allow-Headers', ['authorization']);
  next();
};

app.use(cors({
  origin: ['http://localhost:53530', 'http://127.0.0.1:53530'],
  credentials: true
}));
app.use(allowCrossDomain);

app.db = mongoose;

/* Attaching the api routes */
const apiRouter = require('./routes');
app.use('/api', apiRouter);

// Remaining unhandled routes
app.get('*', (req, res) => {
  return res.status(404).send('Page Not Found');
});

mongoConnect()
  .catch((err) => {
    console.error(err);
  });

const httpServer = http.createServer(app);
httpServer.listen(PORT, () => {
  console.log(`Server is listening on port ${PORT}`);
});

/*
const fs = require('fs');
const credentials = {
  key: fs.readFileSync('sslcert/key.pem'),
  cert: fs.readFileSync('sslcert/cert.pem')
};
const httpsServer = https.createServer(credentials, app);
httpsServer.listen(PORT_SEC, () => {
  console.log(`Server is listening on port ${PORT_SEC}`);
});
*/

module.exports = app;
