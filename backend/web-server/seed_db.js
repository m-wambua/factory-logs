#!/usr/bin/node

/**
 * Author: AlvyneZ
 * 
 * Details: This file contains code for seeding the database with
 *  initial data for testing purposes
 */

'use strict';

const process = require('process');
require('dotenv').config();
const bcrypt = require('bcrypt');

const db = require('./models');

async function main () {
  await db.mongoConnect()
    .catch((err) => {
      console.error('Error connecting to database: ', err);
      process.exit();
    });

  let factory0Id;

  try {
    const session = await db.mongoose.startSession();
    await session.withTransaction(async (session) => {
      const factories = await db.Factory.create([{
        companyName: 'Factory0',
        location: 'City0'
      }], { session });
      const users = await db.User.create([
        {
          userName: 'Fct0.Admn0',
          role: 'Admin',
          hashedPassword: await bcrypt.hash('password0A0', 10),
          factoryId: factories[0]._id
        },
        {
          userName: 'Fct0.Oprt0',
          role: 'Operator',
          hashedPassword: await bcrypt.hash('password0P0', 10),
          factoryId: factories[0]._id
        },
        {
          userName: 'Fct0.Oprt1',
          role: 'Operator',
          hashedPassword: await bcrypt.hash('password0P1', 10),
          factoryId: factories[0]._id
        },
        {
          userName: 'Fct0.Tech0',
          role: 'Technician',
          hashedPassword: await bcrypt.hash('password0T0', 10),
          factoryId: factories[0]._id
        },
        {
          userName: 'Fct0.Tech1',
          role: 'Technician',
          hashedPassword: await bcrypt.hash('password0T1', 10),
          factoryId: factories[0]._id
        },
        {
          userName: 'Fct0.Tech2',
          role: 'Technician',
          hashedPassword: await bcrypt.hash('password0T2', 10),
          factoryId: factories[0]._id
        }
      ], { session });
      factory0Id = factories[0]._id;
      console.log('Successfully created factory:', factories[0].companyName);
      console.log('And successfully created users:', users.map((user)=>user.userName));
    });
  } catch(err) {
    console.error('Error creating first factory and its users: ', err);
    process.exit();
  }

  try {
    const session = await db.mongoose.startSession();
    await session.withTransaction(async (session) => {
      const factories = await db.Factory.create([{
        companyName: 'Factory1',
        location: 'City1'
      }], { session });
      const users = await db.User.create([
        {
          userName: 'Fct1.Admn0',
          role: 'Admin',
          hashedPassword: await bcrypt.hash('password1A0', 10),
          factoryId: factories[0]._id
        },
        {
          userName: 'Fct1.Oprt0',
          role: 'Operator',
          hashedPassword: await bcrypt.hash('password1P0', 10),
          factoryId: factories[0]._id
        },
        {
          userName: 'Fct1.Oprt1',
          role: 'Operator',
          hashedPassword: await bcrypt.hash('password1P1', 10),
          factoryId: factories[0]._id
        },
        {
          userName: 'Fct1.Tech0',
          role: 'Technician',
          hashedPassword: await bcrypt.hash('password1T0', 10),
          factoryId: factories[0]._id
        },
        {
          userName: 'Fct1.Tech1',
          role: 'Technician',
          hashedPassword: await bcrypt.hash('password1T1', 10),
          factoryId: factories[0]._id
        },
        {
          userName: 'Fct1.Tech2',
          role: 'Technician',
          hashedPassword: await bcrypt.hash('password1T2', 10),
          factoryId: factories[0]._id
        }
      ], { session });
      console.log('Successfully created factory:', factories[0].companyName);
      console.log('And successfully created users:', users.map((user)=>user.userName));
    });
  } catch(err) {
    console.error('Error creating second factory and its users: ', err);
    process.exit();
  }

  try {
    const session = await db.mongoose.startSession();
    await session.withTransaction(async (session) => {
      const startupPrcds = await db.StartupPrcd.create([
        {
          _factoryId: factory0Id,
          authorId: (await db.User.findOne({userName: 'Fct0.Admn0'}).select('_id').exec())._id,
          changeLog: 'First startup Procedure for Process0',
          steps: [
            'Step1: apple boy cat dog',
            'Step2: elephant frog goat house',
            'Step3: ivory jug kettle lion'
          ]
        },
        {
          _factoryId: factory0Id,
          authorId: (await db.User.findOne({userName: 'Fct0.Oprt0'}).select('_id').exec())._id,
          changeLog: 'First startup Procedure for Process1',
          steps: [
            'Step1: man night oval potato',
            'Step2: quarry rain snake thumb'
          ]
        }
      ], { session });
      const processes = await db.Process.create([
        { _factoryId: factory0Id, name: 'Fct0.Prcs0', startupId: startupPrcds[0]._id },
        { _factoryId: factory0Id, name: 'Fct0.Prcs1', startupId: startupPrcds[1]._id },
        { _factoryId: factory0Id, name: 'Fct0.Prcs2' }
      ], { session });
      const factory = await db.Factory.findById(factory0Id).exec();
      factory.processIds.push(...(processes.map((process)=>process._id)));
      await factory.save({ session });
      console.log('Successfully created processes for Factory0:', processes.map((process)=>process.name));
    });
  } catch(err) {
    console.error('Error creating processes and their startup Procedures: ', err);
    process.exit();
  }

  try {
    const session = await db.mongoose.startSession();
    await session.withTransaction(async (session) => {
      const equipments = await db.Equipment.create([
        {
          _factoryId: factory0Id,
          name: 'F0P0.Eqpt0',
          type: 'Drive',
          manufacturer: 'Man0',
          serialNum: 'ABCD0123',
          rating: '8W',
          location: {
            description: 'Control Room top slot',
            image: '/Factory0/F0P0.Eqpt0.jpg'
          }
        },
        {
          _factoryId: factory0Id,
          name: 'F0P0.Eqpt1',
          type: 'Drive',
          manufacturer: 'Man0',
          serialNum: 'EFGH4567',
          rating: '10W',
          location: {
            description: 'Control Room second slot',
            image: '/Factory0/F0P0.Eqpt1.jpg'
          }
        },
        {
          _factoryId: factory0Id,
          name: 'F0P0.Eqpt2',
          type: 'Motor',
          manufacturer: 'Man1',
          serialNum: 'IJKL8901',
          rating: '200kVA',
          location: {
            description: 'First Motor of Process'
          }
        },
        {
          _factoryId: factory0Id,
          name: 'F0P0.Eqpt3',
          type: 'Motor',
          manufacturer: 'Man2',
          serialNum: 'MNOP2345',
          rating: '210kVA',
          location: {
            description: 'Second Motor of Process'
          }
        },
        {
          _factoryId: factory0Id,
          name: 'F0P0.Eqpt4',
          type: 'PLC',
          manufacturer: 'Man1',
          serialNum: 'QRST6789',
          rating: '30W',
          location: {
            description: 'Next to process HMI'
          }
        }
      ], { session });
      await equipments.forEach(async (equipment) => {
        const measurables = await db.Measurable.create([{
          equipmentId: equipment._id,
          quantity: 'Current',
          unit: 'Amps'
        }], { session });
        equipment.measurableIds.push(measurables[0]._id);
        await equipment.save({ session });
      });
      const process = await db.Process.findOne({ name: 'Fct0.Prcs0' }).exec();
      process.equipmentIds.push(...(equipments.map((equipment)=>equipment._id)));
      await process.save({ session });
      console.log('Successfully created equipments for Fct0.Prcs0:', equipments.map((equipment)=>equipment.name));
    });
  } catch(err) {
    console.error('Error creating equipments: ', err);
    process.exit();
  }

  try {
    const session = await db.mongoose.startSession();
    await session.withTransaction(async (session) => {
      const userIds = (await db.User.find({ factoryId: factory0Id })
        .limit(5).exec()).map((user) => user._id);
      const measurables = (await db.Measurable.find()
        .limit(5).exec());

      const logs = [[], []];
      for (let i in measurables) {
        logs[0].push({
          measurableId: measurables[i]._id,
          time: new Date(Date.now() + ((i + 1) * 60 * 60 * 1000)),
          value: 10 + i
        });
        if (i < 2) {
          logs[1].push({
            measurableId: measurables[i]._id,
            time: new Date(Date.now() + 60000 + ((i + 1) * 60 * 60 * 1000)),
            value: 20 + i
          });
        }
      }
      const shifts = await db.Shift.create([
        {
          _factoryId: factory0Id,
          leadId: userIds[0],
          teammateIds: [...userIds.slice(1)],
          type: 'Morning',
          date: new Date(),
          start: new Date(),
          end: new Date(Date.now() + (6 * 60 * 60 * 1000)),
          logs: logs[0]
        },
        {
          _factoryId: factory0Id,
          leadId: userIds[1],
          teammateIds: [...userIds.splice(1,1)],
          type: 'Afternoon',
          date: new Date(),
          start: new Date(),
          end: new Date(Date.now() + (5 * 60 * 60 * 1000)),
          logs: logs[1]
        }
      ], { session });
      for (let i in measurables) {
        measurables[i].shiftIds.push(shifts[0]._id);
        if (i < 2) {
          measurables[i].shiftIds.push(shifts[1]._id);
        }
        await measurables[i].save({ session });
      }
      console.log('Successfully created shifts and logs for Fct0.Prcs0');
    });
  } catch(err) {
    console.error('Error creating shifts: ', err);
    process.exit();
  }
  process.exit();
}

main();
