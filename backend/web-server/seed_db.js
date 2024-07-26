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
          username: 'Fct0.Admn0',
          role: 'Admin',
          hashedPassword: await bcrypt.hash('password0A0', 10),
          factoryId: factories[0]._id
        },
        {
          username: 'Fct0.Oprt0',
          role: 'Operator',
          hashedPassword: await bcrypt.hash('password0P0', 10),
          factoryId: factories[0]._id
        },
        {
          username: 'Fct0.Oprt1',
          role: 'Operator',
          hashedPassword: await bcrypt.hash('password0P1', 10),
          factoryId: factories[0]._id
        },
        {
          username: 'Fct0.Tech0',
          role: 'Technician',
          hashedPassword: await bcrypt.hash('password0T0', 10),
          factoryId: factories[0]._id
        },
        {
          username: 'Fct0.Tech1',
          role: 'Technician',
          hashedPassword: await bcrypt.hash('password0T1', 10),
          factoryId: factories[0]._id
        },
        {
          username: 'Fct0.Tech2',
          role: 'Technician',
          hashedPassword: await bcrypt.hash('password0T2', 10),
          factoryId: factories[0]._id
        }
      ], { session });
      factory0Id = factories[0]._id;
      console.log('Successfully created factory:', factories[0].companyName);
      console.log('And successfully created users:', users.map((user)=>user.username));
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
          username: 'Fct1.Admn0',
          role: 'Admin',
          hashedPassword: await bcrypt.hash('password1A0', 10),
          factoryId: factories[0]._id
        },
        {
          username: 'Fct1.Oprt0',
          role: 'Operator',
          hashedPassword: await bcrypt.hash('password1P0', 10),
          factoryId: factories[0]._id
        },
        {
          username: 'Fct1.Oprt1',
          role: 'Operator',
          hashedPassword: await bcrypt.hash('password1P1', 10),
          factoryId: factories[0]._id
        },
        {
          username: 'Fct1.Tech0',
          role: 'Technician',
          hashedPassword: await bcrypt.hash('password1T0', 10),
          factoryId: factories[0]._id
        },
        {
          username: 'Fct1.Tech1',
          role: 'Technician',
          hashedPassword: await bcrypt.hash('password1T1', 10),
          factoryId: factories[0]._id
        },
        {
          username: 'Fct1.Tech2',
          role: 'Technician',
          hashedPassword: await bcrypt.hash('password1T2', 10),
          factoryId: factories[0]._id
        }
      ], { session });
      console.log('Successfully created factory:', factories[0].companyName);
      console.log('And successfully created users:', users.map((user)=>user.username));
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
          authorId: (await db.User.findOne({username: 'Fct0.Admn0'}).select('_id').exec())._id,
          changeLog: 'First startup Procedure for Process0',
          steps: [
            'Step1: apple boy cat dog',
            'Step2: elephant frog goat house',
            'Step3: ivory jug kettle lion'
          ]
        },
        {
          _factoryId: factory0Id,
          authorId: (await db.User.findOne({username: 'Fct0.Oprt0'}).select('_id').exec())._id,
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
            image: `/${factory0Id}/F0P0.Eqpt0/location.jpg`
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
            image: `/${factory0Id}/F0P0.Eqpt1/location.jpg`
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
            time: new Date(Date.now() + ((i + 7) * 60 * 60 * 1000)),
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
          start: new Date(),
          end: new Date(Date.now() + (6 * 60 * 60 * 1000)),
          logs: logs[0]
        },
        {
          _factoryId: factory0Id,
          leadId: userIds[1],
          teammateIds: [...userIds.slice(2)],
          type: 'Afternoon',
          start: new Date(Date.now() + (6 * 60 * 60 * 1000)),
          end: new Date(Date.now() + (12 * 60 * 60 * 1000)),
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

  try {
    const session = await db.mongoose.startSession();
    await session.withTransaction(async (session) => {
      const shifts = (await db.Shift.find({ factoryId: factory0Id })
        .limit(2).select(['start', 'downtimeIds']).sort({ start: -1 }).exec());
      const equipments = (await db.Equipment.find({ _factoryId: factory0Id })
        .limit(4).select(['downtimeIds']).exec());

      for (let i in shifts) {
        const downtimes = await db.Downtime.create([
          {
            shiftId: shifts[i]._id,
            equipmentId: equipments[(i * 2)],
            type: 'Failure',
            downAt: new Date(Date.parse(shifts[i].start) + (2.5 * 60 * 60 * 1000)),
            resumedAt: new Date(Date.parse(shifts[i].start) + (2.75 * 60 * 60 * 1000)),
            remark: 'Overheating after fan stopped working'
          },
          {
            shiftId: shifts[i]._id,
            equipmentId: equipments[(i * 2) + 1],
            type: 'Maintenance',
            downAt: new Date(Date.parse(shifts[i].start) + (4.25 * 60 * 60 * 1000)),
            resumedAt: new Date(Date.parse(shifts[i].start) + (4.5 * 60 * 60 * 1000)),
            remark: 'Moving equipment to another location to allow more air flow'
          }
        ], { session });
        equipments[(i * 2)].downtimeIds.push(downtimes[0]._id);
        equipments[(i * 2) + 1].downtimeIds.push(downtimes[1]._id);
        shifts[i].downtimeIds.push(downtimes[0]._id);
        shifts[i].downtimeIds.push(downtimes[1]._id);
        await equipments[(i * 2)].save({ session });
        await equipments[(i * 2) + 1].save({ session });
        await shifts[i].save({ session });
      }
      console.log('Successfully created downtimes');
    });
  } catch(err) {
    console.error('Error creating downtimes: ', err);
    process.exit();
  }

  try {
    const session = await db.mongoose.startSession();
    await session.withTransaction(async (session) => {
      const users = (await db.User.find({ factoryId: factory0Id })
        .limit(2).select(['username']).exec());
      const equipments = (await db.Equipment.find({ _factoryId: factory0Id })
        .limit(2).select(['name', 'cableSchedIds']).exec());

      const descs = [undefined, undefined];
      for (let i in equipments) {
        const scheds = await db.CableSched.create([
          {
            equipmentId: equipments[i]._id,
            panel: 'Rear right panel',
            image: `/${factory0Id}/${equipments[i].name}/rear_right_panel.jpg`
          },
          {
            equipmentId: equipments[i]._id,
            panel: 'Rear left panel',
            image: `/${factory0Id}/${equipments[i].name}/rear_left_panel.jpg`
          }
        ], { session });
        equipments[i].cableSchedIds.push(scheds[0]._id);
        equipments[i].cableSchedIds.push(scheds[1]._id);
        await equipments[i].save({ session });

        descs[i] = await db.CableDesc.create([
          {
            parentSchedId: scheds[0]._id,
            authorId: users[i]._id,
            labelDets: 'first cable from right',
            purpose: 'Power'
          },
          {
            parentSchedId: scheds[0]._id,
            authorId: users[i]._id,
            labelDets: 'second cable from right',
            purpose: 'Ground'
          },
          {
            parentSchedId: scheds[1]._id,
            authorId: users[i]._id,
            labelDets: 'first cable from left',
            purpose: 'Control'
          }
        ], { session });
        scheds[0].cableIds.push(descs[i][0]);
        scheds[0].cableIds.push(descs[i][1]);
        scheds[1].cableIds.push(descs[i][2]);
        await scheds[0].save({ session });
        await scheds[1].save({ session });
      }
      for (let i in descs[0]) {
        descs[0][i].termDescId = descs[1][i]._id;
        descs[1][i].termDescId = descs[0][i]._id;
        await descs[0][i].save({ session });
        await descs[1][i].save({ session });
      }
      console.log('Successfully created cable schedules and descriptors');
    });
  } catch(err) {
    console.error('Error creating cable schedules and descriptors: ', err);
    process.exit();
  }
  process.exit();
}

main();
