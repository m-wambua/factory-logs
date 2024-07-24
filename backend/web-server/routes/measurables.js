'use strict';

/**
 * @swagger
 * components:
 *   schemas:
 *     Measurable:
 *       type: object
 *       required:
 *         - quantity
 *         - unit
 *       properties:
 *         quantity:
 *           type: string
 *           description: The equipment-unique name of the quantity that can be measured
 *         unit:
 *           type: string
 *           description: The measurement unit of the parameter
 *       example:
 *         quantity: Temperature
 *         unit: Celcius
 *     MeasurableDetails:
 *       type: object
 *       required:
 *         - quantity
 *         - unit
 *         - equipment
 *       properties:
 *         quantity:
 *           type: string
 *           description: The equipment-unique name of the quantity that can be measured
 *         unit:
 *           type: string
 *           description: The measurement unit of the parameter
 *         equipment:
 *           type: object
 *           description: Details of the equipment that the measurable belongs
 *           properties:
 *             id:
 *               type: string
 *               description: The unique identifier of the equipment
 *             name:
 *               type: string
 *               description: The factory-unique name of the equipment
 *       example:
 *         quantity: Temperature
 *         unit: Celcius
 *         equipment:
 *           id: 669ae6a3aeb6ecf601e0881a
 *           name: F0P0.Eqpt1
 * tags:
 *   name: Measurables
 *   description: The measurables management API
 */

const express = require('express');
const { Measurable } = require('../models');
const { verifySession } = require('../controllers/auth');
const handleErr500 = require('../utils/senderr500');

const eqptMeasurablesRouter = express.Router();

/** Function to check whether a provided measurable name is already taken for a given equipment */
async function measurableNameTaken(equipment, name) {
  const takenNames = equipment.measurableIds.map((meas) => meas.quantity);
  return takenNames.includes(name);
}

/** To make sure all routes after this point require a login */
eqptMeasurablesRouter.use(verifySession);

/* Attaching the different shift routes */
const { measLogsRouter } = require('./logs');

eqptMeasurablesRouter.use('/:measurableNum/logs', measLogsRouter);

eqptMeasurablesRouter.param('measurableNum', async (req, res, next, measurableNum) => {
  if (measurableNum >= req.equipment.measurableIds.length) {
    return res.sendStatus(404);
  }
  req.measurableId = req.equipment.measurableIds[measurableNum]._id;
});

/**
 * @swagger
 * /api/equipments/{equipmentId}/measurables:
 *   delete:
 *     summary: Removes a measurable if it has no corresponding logs (Admins and operators only)
 *     security:
 *       - BearerAuth: []
 *     tags: [Measurables, Equipments]
 *     parameters:
 *       - in: path
 *         name: equipmentId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the equipment whose measurable is to be deleted
 *     requestBody:
 *       description: The details of the measurable to be deleted
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - quantity
 *             properties:
 *               quantity:
 *                 type: string
 *                 description: The equipment-unique name of the quantity to be deleted
 *             example:
 *               quantity: Temperature
 *     responses:
 *       204:
 *         description: The measurable has been deleted successfully
 *       400:
 *         description: Bad Request. quantity not provided.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Field "quantity" is missing in the body'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *       404:
 *         description: Not Found. The equipment or measurable does not exist
 *       406:
 *         description: Not Allowed. The measurable must have no correspondng logs
 *       500:
 *         description: Server Error. Could not delete the measurable.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error deleting measurable: ...'
 */
eqptMeasurablesRouter.delete('/', async (req, res) => {
  if (!['Admin', 'Operator'].includes(req.user?.role)) {
    return res.status(403).send('Only admins and operators can delete measurables');
  }
  const { quantity } = req.body;
  if (!quantity) {
    return res.status(400)
      .send('Field "quantity" is missing in the body');
  }
  let measurableIndex;
  const foundMeasurable = req.equipment.measurableIds.find((val, index) => {
    measurableIndex = index;
    return val.quantity === quantity;
  });
  if (!foundMeasurable) {
    return res.sendStatus(404);
  }
  const measurable = await Measurable.findById(foundMeasurable._id).select(['shiftIds']);
  if (measurable.shiftIds.length) {
    return res.status(406).send('The measurable already has logs and may not be deleted');
  }
  try {
    const session = await req.app.db.startSession();
    await session.withTransaction(async (session) => {
      await measurable.deleteOne({ session });
      req.equipment.measurableIds.splice(measurableIndex, 1);
      await req.equipment.save({ session });
    });
    return res.sendStatus(204);
  } catch (err) {
    return handleErr500(res, err, 'Error deleting measurable');
  }
});

/**
 * @swagger
 * /api/equipments/{equipmentId}/measurables:
 *   post:
 *     summary: Adds a new measurable to a given equipment (only admins & operators)
 *     security:
 *       - BearerAuth: []
 *     tags: [Measurables, Equipments]
 *     parameters:
 *       - in: path
 *         name: equipmentId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the equipment to which the measurable is to belong
 *     requestBody:
 *       description: The details of the new measurable
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *               $ref: '#/components/schemas/Measurable'
 *     responses:
 *       201:
 *         description: Successfully created the measurable
 *       400:
 *         description: Bad Request. quantity or unit not provided.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Field "quantity" is missing in the body'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *       404:
 *         description: The equipment does not exist or does not belong to the current user's factory
 *       500:
 *         description: Server Error. Could not create the measurable.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error creating measurable: ...'
 */
eqptMeasurablesRouter.post('/', async (req, res) => {
  if (!['Admin', 'Operator'].includes(req.user?.role)) {
    return res.status(403).send('Only admins and operators can add measurables');
  }
  for (const required of ["quantity", "unit"]) {
    if (!req.body[required]) {
      return res.status(400)
        .send(`Field "${required}" is missing in the body`);
    }
  }
  const { quantity, unit} = req.body;
  if (await measurableNameTaken(req.equipment, quantity)) {
    return res.status(400)
      .send('Provided quantity already exists for the given equipment');
  }
  try {
    const session = await req.app.db.startSession();
    await session.withTransaction(async (session) => {
      const measurables = await Measurable.create([{
        equipmentId: req.equipment._id, quantity, unit
      }], { session });
      req.equipment.measurableIds.push(measurables[0]._id);
      await req.equipment.save({ session });
    });
    return res.sendStatus(201);
  } catch (err) {
    return handleErr500(res, err, 'Error creating measurable');
  }
});

const measurablesRouter = express.Router();

/** To make sure all routes after this point require a login */
measurablesRouter.use(verifySession);

/**
 * @swagger
 * /api/measurables/{measurableId}:
 *   get:
 *     summary: Retrieves the details of a measurable given its id (from shift logs)
 *     security:
 *       - BearerAuth: []
 *     tags: [Measurables]
 *     parameters:
 *       - in: path
 *         name: measurableId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the measurable whose details are being requested
 *     responses:
 *       200:
 *         description: The details of the requested measurable
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/MeasurableDetails'
 *       404:
 *         description: The measurable does not exist
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 */
measurablesRouter.get('/:measurableId', async (req, res) => {
  req.measurable = await Measurable.findById(req.params.measurableId)
    .select(['quantity', 'unit', 'equipmentId'])
    .populate({ path: 'equipmentId', select: ['name', '_factoryId'] }).exec();
  if (!req.measurable) {
    return res.sendStatus(404);
  }
  if (!req.measurable.equipmentId._factoryId.equals(req.user.factoryId)) {
    return res.status(403).send('The measurable does not belong to the user\'s factory');
  }
  return res.json(req.measurable);
});

module.exports = { eqptMeasurablesRouter, measurablesRouter };
