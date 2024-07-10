#!/usr/bin/node

'use strict';

const process = require('process');
require('dotenv').config();
const bcrypt = require('bcrypt');

const { Factory, User, mongoConnect, mongoose } = require('./models');

async function main () {
  const args = process.argv;
  if ((args.length < 3) || (args[2] == '--help')) {
    printUsage(args);
    process.exit();
  }

  await mongoConnect()
    .catch((err) => {
      console.error('Error connecting to database: ', err);
      process.exit();
    });

  if (args[2] === 'ls') {
    await listFactories();
  } else if (args[2] === 'add') {
    if (args.length !== 7) {
      printUsage(args);
      process.exit();
    }
    await addFactoryAndAdmin(args);
  } else if (args[2] === 'rm') {
    if (args.length !== 4) {
      printUsage(args);
      process.exit();
    }
    await removeFactory(args);
  }
  process.exit();
}

function printUsage(args) {
  console.log(`Usage: ${args[0]} ${args[1]} <command> [<args>]`);
  console.log('\nThese are common factory management commands and their arguments list:\n');
  console.log('\tadd <factory_name> <factory_location> <admin_userName> <admin_password>');
  console.log('\trm <factory_name>');
  console.log('\tls');
}

async function addFactoryAndAdmin(args) {
  try {
    const session = await mongoose.startSession();
    await session.withTransaction(async (session) => {
      const factories = await Factory.create([{
        companyName: args[3],
        location: args[4]
      }], { session });
      const admins = await User.create([{
        userName: args[5],
        role: 'Admin',
        hashedPassword: await bcrypt.hash(args[6], 10),
        factoryId: factories[0]._id
      }], { session });
      console.log('Successfully created factory:', factories[0].toJSON());
      console.log('And successfully created admin:', admins[0].toJSON());
    });
  } catch(err) {
    console.error('Error creating factory and admin: ', err);
  }
}

async function removeFactory(args) {
  try {
    const factory = await Factory.findOne({ companyName: args[3] }).exec();
    if (!factory) {
      console.log('No factory found with the given name');
      return;
    }
    const users = await User.find({ factoryId: factory._id }).exec();
    if (users.length > 1) {
      console.log('Multiple users are already linked to the factory. Thus this tool may not be used.');
      return;
    } else {
      const session = await mongoose.startSession();
      await session.withTransaction(async (session) => {
        if (users.length === 1) {
          console.log('Deleting user: ', users[0].toJSON());
          await users[0].deleteOne({ session }).exec();
        }
        console.log('Deleting factory: ', factory.toJSON());
        await factory.deleteOne({ session }).exec();
      });
    }
  }catch(err) {
    console.error('Error deleting factory and admin: ', err);
  }
}

async function listFactories() {
  const admins = await User.find({ role: 'Admin' })
    .populate('factoryId').exec();
    const factories = admins.map((adm) => {
      const json = adm.toJSON();
      const ret = {
        adminId: json.id,
        ...json,
        ...json.factoryId
      };
      delete ret.factoryId;
      return ret;
    });
  console.log(factories);
}

main();
