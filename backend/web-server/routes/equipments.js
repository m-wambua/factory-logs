'use strict';

/**
 * @swagger
 * components:
 *   schemas:
 *     Equipment:
 *       type: object
 *       required:
 *         - id
 *         - name
 *         - type
 *         - manufacturer
 *         - serialNum
 *         - location
 *       properties:
 *         id:
 *           type: string
 *           description: The unique identifier of the equipment
 *         name:
 *           type: string
 *           description: The factory-unique name of the equipment
 *         type:
 *           type: string
 *           description: The equipment class to which the equipment belongs
 *         manufacturer:
 *           type: string
 *           description: The original manufacturer of the equipment
 *         serialNum:
 *           type: string
 *           description: The unique serial number of the equipment
 *         rating:
 *           type: string
 *           description: The power consumption rating of the equipment
 *         decommissioned:
 *           type: boolean
 *           description: Whether the equipment has been removed from the process or is still active
 *         location:
 *           type: object
 *           required:
 *             - description
 *           description: The details of the physical location of the equipment in the plant
 *           properties:
 *             description:
 *               type: string
 *               description: The description of the location
 *             image:
 *               type: string
 *               description: A link to the image of where the equipment is located
 *         measurables:
 *           type: array
 *           description: The quantities of the equipment that can be measured and logged
 *           items:
 *             type: object
 *             properties:
 *               quantity:
 *                 type: string
 *                 description: The measurable quantity
 *               unit:
 *                 type: string
 *                 description: The unit of all logged measurements of the quantity
 *         createdAt:
 *           type: string
 *           format: date-time
 *           description: The time the equipment was added to the system
 *         updatedAt:
 *           type: string
 *           format: date-time
 *           description: The last time the equipment details were edited
 *       example:
 *         id: 6778f8whfj5894bbhr883bb3
 *         name: F0P0.Eqpt0
 *         type: Drive
 *         manufacturer: Man0
 *         serialNum: ABCD0123
 *         rating: 8W
 *         decommissioned: false
 *         location:
 *           description: 'Control Room top slot'
 *           image: '/Factory0/F0P0.Eqpt0.jpg'
 *         measurables:
 *           - quantity: Current
 *             unit: Amps
 *           - quantity: Temperature
 *             unit: Celcius
 *         createdAt: 2024-07-10T17:30:12.015Z
 *         updatedAt: 2024-07-10T17:30:12.015Z
 *     EquipmentCreateInfo:
 *       type: object
 *       required:
 *         - name
 *         - type
 *         - manufacturer
 *         - serialNum
 *         - location
 *       properties:
 *         name:
 *           type: string
 *           description: The factory-unique name of the new equipment
 *         type:
 *           type: string
 *           description: The equipment class to which the new equipment belongs
 *         manufacturer:
 *           type: string
 *           description: The original manufacturer of the new equipment
 *         serialNum:
 *           type: string
 *           description: The unique serial number of the new equipment
 *         rating:
 *           type: string
 *           description: The power consumption rating of the new equipment
 *         location:
 *           type: string
 *           description: The description of the physical location of the equipment in the plant
 *         image:
 *           type: string
 *           description: A link to the image of where the equipment is located
 *       example:
 *         name: F0P0.Eqpt5
 *         type: PLC
 *         manufacturer: Man3
 *         serialNum: UVWX0123
 *         rating: 20W
 *         location: 'Control Room bottom slot'
 * tags:
 *   name: Equipments
 *   description: The equipments management API
 */

const express = require('express');
const { Factory, Equipment } = require('../models');
const { verifySession } = require('../controllers/auth');
const handleErr500 = require('../utils/senderr500');

const equipmentsRouter = express.Router();

/** Function to check whether a provided equipment name is already taken for a given factory */
async function equipmentNameTaken(factoryId, name) {
  const factory = await Factory.findById(factoryId)
    .populate({
      path: 'processIds',
      select: 'equipmentIds',
      populate: { path: 'equipmentIds', select: 'name' }
    }).exec();
  const prcsTakenNames = factory.processIds.map((prcs) => prcs.equipmentIds.map((eqpt) => eqpt.name));
  const takenNames = prcsTakenNames.reduce((prev, cur) => prev.concat(cur), []);
  return takenNames.includes(name);
}

/** To make sure all routes after this point require a login */
equipmentsRouter.use(verifySession);

/* Attaching the different equipment routes */
const { eqptMeasurablesRouter } = require('./measurables');
const eqptManualsRouter = require('./manuals');
const eqptCodebasesRouter = require('./codebases');
const { eqptDowntimesRouter } = require('./downtimes');
const { eqptCableSchedsRouter } = require('./cable_scheds');

equipmentsRouter.use('/:equipmentId/measurables', eqptMeasurablesRouter);
equipmentsRouter.use('/:equipmentId/manuals', eqptManualsRouter);
equipmentsRouter.use('/:equipmentId/codebases', eqptCodebasesRouter);
equipmentsRouter.use('/:equipmentId/downtimes', eqptDowntimesRouter);
equipmentsRouter.use('/:equipmentId/cablescheds', eqptCableSchedsRouter);

/**
 * @swagger
 * /api/equipments/decommission/{equipmentId}:
 *   delete:
 *     summary: Marks an equipment as decommissioned to prevent adding of logs for it (Admins only)
 *     security:
 *       - BearerAuth: []
 *     tags: [Equipments]
 *     parameters:
 *       - in: path
 *         name: equipmentId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the equipment to be decommissioned
 *     responses:
 *       200:
 *         description: The details of the decommissioned equipment
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Equipment'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *       404:
 *         description: The equipment does not exist
 *       500:
 *         description: Server Error. Could not decommission the equipment.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error decommissioning equipment: ...'
 */
equipmentsRouter.delete('/decommission/:equipmentId', async (req, res) => {
  if (req.user?.role !== 'Admin') {
    return res.status(403).send('Only admins can decommission equipment');
  }
  try {
    const session = await req.app.db.startSession();
    await session.withTransaction(async (session) => {
      req.equipment.decommissioned = true;
      await req.equipment.save({ session });
    });
    return res.json(req.equipment);
  } catch (err) {
    return handleErr500(res, err, 'Error decommissioning equipment');
  }
});

/**
 * @swagger
 * /api/equipments/process/{processId}:
 *   post:
 *     summary: Adds a new equipment to a given process (only admins & operators)
 *     security:
 *       - BearerAuth: []
 *     tags: [Equipments]
 *     parameters:
 *       - in: path
 *         name: processId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the process that the equipment belongs
 *     requestBody:
 *       description: The details of the new equipment
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *               $ref: '#/components/schemas/EquipmentCreateInfo'
 *     responses:
 *       200:
 *         description: The details of the created equipment
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Equipment'
 *       400:
 *         description: Bad Request. name or type or manufacturer or serialNum or location not provided.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Field "name" is missing in the body'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *       404:
 *         description: The process does not exist or does not belong to the current user's factory
 *       500:
 *         description: Server Error. Could not create the equipment.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error creating equipment: ...'
 */
equipmentsRouter.post('/process/:processId', async (req, res) => {
  if (!['Admin', 'Operator'].includes(req.user?.role)) {
    return res.status(403).send('Only admins and operators can add equipment');
  }
  for (const required of ["name", "type", "manufacturer", "serialNum", "location"]) {
    if (!req.body[required]) {
      return res.status(400)
        .send(`Field "${required}" is missing in the body`);
    }
  }
  const { name, type, manufacturer, serialNum, rating, location, image } = req.body;
  if (await equipmentNameTaken(req.user.factoryId, name)) {
    return res.status(400)
      .send('Provided name is already taken, name needs to be unique');
  }
  try {
    const session = await req.app.db.startSession();
    const equipment = await session.withTransaction(async (session) => {
      const equipments = await Equipment.create([{
        _factoryId: req.user.factoryId,
        name, type, manufacturer, serialNum, rating,
        location: { description: location, image }
      }], { session });
      req.process.equipmentIds.push(equipments[0]._id);
      await req.process.save({ session });
      return equipments[0];
    });
    equipment.manuals = undefined;
    equipment.downtimeIds = undefined;
    equipment.cableSchedIds = undefined;
    equipment.codebases = undefined;
    return res.json(equipment);
  } catch (err) {
    return handleErr500(res, err, 'Error creating equipment');
  }
});

/**
 * @swagger
 * /api/equipments/{equipmentId}:
 *   put:
 *     summary: Edits the details of an equipment (only admins & operators)
 *     security:
 *       - BearerAuth: []
 *     tags: [Equipments]
 *     parameters:
 *       - in: path
 *         name: equipmentId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the equipment to be edited
 *     requestBody:
 *       description: The new details of the equipment
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *               $ref: '#/components/schemas/EquipmentCreateInfo'
 *     responses:
 *       200:
 *         description: The details of the edited equipment
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Equipment'
 *       400:
 *         description: Bad Request. name, type, manufacturer, serialNum, rating, location and image not provided. At least one is required.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'No supported field has been provided for edit'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *       404:
 *         description: The equipment does not exist
 *       500:
 *         description: Server Error. Could not edit the equipment.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error updating equipment: ...'
 */
equipmentsRouter.put('/:equipmentId', async (req, res) => {
  if (!['Admin', 'Operator'].includes(req.user?.role)) {
    return res.status(403).send('Only admins and operators can edit an equipment');
  }
  const { name, type, manufacturer, serialNum, rating, location, image } = req.body;
  if ((!name) && (!type) && (!manufacturer) && (!serialNum) && (!rating) && (!location) && (!image)) {
    return res.status(400)
      .send('No supported field has been provided for edit');
  }
  try {
    if (name) {
      if (await equipmentNameTaken(req.user.factoryId, name)) {
        return res.status(400)
          .send('Provided name is already taken, name needs to be unique');
      }
      req.equipment.name = name;
    }
    if (type) {
      req.equipment.type = type;
    }
    if (manufacturer) {
      req.equipment.manufacturer = manufacturer;
    }
    if (serialNum) {
      req.equipment.serialNum = serialNum;
    }
    if (rating) {
      req.equipment.rating = rating;
    }
    if (location) {
      req.equipment.location.description = location;
    }
    if (image) {
      req.equipment.location.image = image;
    }
    await req.equipment.save();
    return res.json(req.equipment);
  } catch (err) {
    return handleErr500(res, err, 'Error updating equipment');
  }
});

/**
 * @swagger
 * /api/equipments/{equipmentId}:
 *   get:
 *     summary: Returns the details of a specific equipment
 *     security:
 *       - BearerAuth: []
 *     tags: [Equipments]
 *     parameters:
 *       - in: path
 *         name: equipmentId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the equipment being requested
 *     responses:
 *       200:
 *         description: The details of the requested equipment
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Equipment'
 *       404:
 *         description: The equipment does not exist
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 */
equipmentsRouter.get('/:equipmentId', async (req, res) => {
  return res.json(req.equipment);
});

module.exports = equipmentsRouter;
