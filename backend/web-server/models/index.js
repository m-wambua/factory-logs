'use strict';

const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');
const process = require('process');
const basename = path.basename(__filename);
const env = process.env.NODE_ENV || 'development';
const config = require(path.join(__dirname, '/../config/config.json'))[env];
const db = {};

db.mongoConnect = async function () {
  mongoose.connection.once('open', () => console.log('MongoDB connection successful'));
  mongoose.connection.on('error', (err) => console.log(`MongoDB connection error: ${err}`));
  return mongoose.connect(config.connectString, config.options);
}

const neededFiles = fs
  .readdirSync(__dirname)
  .filter(file => {
    return (
      file.indexOf('.') !== 0 &&
      file !== basename &&
      file.slice(-3) === '.js' &&
      file.indexOf('.test.js') === -1
    );
  });
neededFiles.forEach(file => {
  const model = require(path.join(__dirname, file))(mongoose);
  db[model.modelName] = model;
});

db.mongoose = mongoose;

module.exports = db;
