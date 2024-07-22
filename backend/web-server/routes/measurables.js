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
 */

const express = require('express');
const { Measurable } = require('../models');
const { verifySession } = require('../controllers/auth');
const handleErr500 = require('../utils/senderr500');

const measurablesRouter = express.Router();

/** Function to check whether a provided measurable name is already taken for a given equipment */
async function measurableNameTaken(equipment, name) {
  const takenNames = equipment.measurableIds.map((meas) => meas.quantity);
  return takenNames.includes(name);
}

/** To make sure all routes after this point require a login */
measurablesRouter.use(verifySession);

/**
 * @swagger
 * /api/equipments/{equipmentId}/measurables/{measurableNum}/logs:
 *   get:
 *     summary: Returns a list of the logs that the measurable has 
 *     security:
 *       - BearerAuth: []
 *     tags: [Equipments]
 *     parameters:
 *       - in: path
 *         name: equipmentId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the equipment to which the measurable belongs
 *       - in: path
 *         name: measurableNum
 *         schema:
 *           type: string
 *         required: true
 *         description: the index of the measurable whose logs are being requested
 *     responses:
 *       200:
 *         description: The list of the requested measurable logs
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Log'
 *       404:
 *         description: The equipment does not exist
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 */
measurablesRouter.get('/:measurableNum/logs', async (req, res) => {
  if (req.params.measurableNum >= req.equipment.measurableIds.length) {
    return res.sendStatus(404);
  }
  const measurableId = req.equipment.measurableIds[req.params.measurableNum]._id;
  const measurable = await Measurable.findById(measurableId)
    .select(['shiftIds'])
    .populate({
      path: 'shiftIds',
      select: ['_id', 'logs'],
      match: { 'logs.measurableId': measurableId },
      sort: { start: -1 }
    });
  const logs = [];
  measurable.shiftIds.forEach((shift) => {
    shift.logs.forEach((log) => {
      logs.push({ ...log.toJSON(), shiftId: shift._id, measurableId: undefined });
    });
  });
  return res.json(logs);
});

/**
 * @swagger
 * /api/equipments/{equipmentId}/measurables:
 *   delete:
 *     summary: Removes a measurable if it has no corresponding logs (Admins and operators only)
 *     security:
 *       - BearerAuth: []
 *     tags: [Equipments]
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
measurablesRouter.delete('/', async (req, res) => {
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
 *     tags: [Equipments]
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
measurablesRouter.post('/', async (req, res) => {
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

module.exports = measurablesRouter;
