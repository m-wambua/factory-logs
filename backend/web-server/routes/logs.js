'use strict';

/**
 * @swagger
 * components:
 *   schemas:
 *     ShiftLog:
 *       type: object
 *       required:
 *         - measurableId
 *         - time
 *         - value
 *       properties:
 *         measurableId:
 *           type: string
 *           description: The unique identifier of the quantity that was measured in the log
 *         time:
 *           type: string
 *           description: The time the measurement was taken
 *         value:
 *           type: string
 *           description: The value of the measured quantity
 *         remark:
 *           type: string
 *           description: An optional explanation for a discrepancy
 *       example:
 *         measurableId: 6778f8acfd5894bbfe883bb3
 *         time: 2024-07-19T22:20:19.276Z
 *         value: 20
 *         remark: Power surge caused lower current draw
 *     MeasurableLog:
 *       type: object
 *       required:
 *         - shiftId
 *         - time
 *         - value
 *       properties:
 *         shiftId:
 *           type: string
 *           description: The unique identifier of the shift to which the log belongs
 *         time:
 *           type: string
 *           description: The time the measurement was taken
 *         value:
 *           type: string
 *           description: The value of the measured quantity
 *         remark:
 *           type: string
 *           description: An optional explanation for a discrepancy
 *       example:
 *         shiftId: 669ae6a3aeb6ecf601e0881a
 *         time: 2024-07-19T22:20:19.276Z
 *         value: 20
 *         remark: Power surge caused lower current draw
 * tags:
 *   name: Logs
 *   description: The logs management API
 */

const express = require('express');
const { Shift, Measurable } = require('../models');
const { verifySession } = require('../controllers/auth');
const handleErr500 = require('../utils/senderr500');

const measLogsRouter = express.Router();

/** To make sure all routes after this point require a login */
measLogsRouter.use(verifySession);

/**
 * @swagger
 * /api/equipments/{equipmentId}/measurables/{measurableNum}/logs:
 *   get:
 *     summary: Returns a list of the logs that the measurable has 
 *     security:
 *       - BearerAuth: []
 *     tags: [Measurables, Logs]
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
 *                 $ref: '#/components/schemas/MeasurableLog'
 *       404:
 *         description: The equipment does not exist
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 */
measLogsRouter.get('/', async (req, res) => {
  const measurable = await Measurable.findById(req.measurableId)
    .select(['shiftIds'])
    .populate({
      path: 'shiftIds',
      select: ['_id', 'logs'],
      match: { 'logs.measurableId': req.measurableId },
      sort: { start: -1, 'logs.time': -1 }
    });
  const logs = [];
  measurable.shiftIds.forEach((shift) => {
    shift.logs.forEach((log) => {
      logs.push({ ...log.toJSON(), shiftId: shift._id, measurableId: undefined });
    });
  });
  return res.json(logs);
});

const shftLogsRouter = express.Router();

/** To make sure all routes after this point require a login */
shftLogsRouter.use(verifySession);

/**
 * @swagger
 * /api/shifts/{shiftId}/logs:
 *   post:
 *     summary: Records a new dmeasurement log for a shift (team-members or lead only)
 *     security:
 *       - BearerAuth: []
 *     tags: [Logs, Shifts]
 *     parameters:
 *       - in: path
 *         name: shiftId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the shift to which the log belongs
 *     requestBody:
 *       description: The details of the new log
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/ShiftLog'
 *     responses:
 *       201:
 *         description: Successfully created the shift log
 *       400:
 *         description: Bad Request. measurableId and value not provided.
 *       404:
 *         description: The shift does not exist
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *       500:
 *         description: Server Error. Could not add the log.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error creating log: ...'
 */
shftLogsRouter.post('/', async (req, res) => {
  if (!req.isShiftMember()) {
    return res.status(403).send('Only team members and leads can add logs in their shift');
  }
  for (const required of ["measurableId", "value"]) {
    if (!req.body[required]) {
      return res.status(400)
        .send(`Field "${required}" is missing in the body`);
    }
  }
  const { measurableId, time, value, remark } = req.body;
  req.measurable = await Measurable.findById(measurableId).select(['shiftIds']).exec();
  if (!req.measurable) {
    return res.status(400)
      .send('The provided measurableId is not in the system');
  }
  if (isNaN(value)) {
    return res.status(400)
      .send('Fields "value" should be a number');
  }
  const measTime = (time) ? Date.parse(time) : Date.now();
  if (isNaN(measTime)) {
    return res.status(400)
      .send('Field "time" should be a valid time entry');
  }
  try {
    const session = await req.app.db.startSession();
    await session.withTransaction(async (session) => {
      const log = {
        measurableId, value, remark,
        time: new Date(measTime)
      };
      const shiftDet = await Shift.findById(req.shift._id)
        .select('logs').exec();
      shiftDet.logs.push(log);
      await shiftDet.save({ session });
      /** Adding shift to measurable's list of shifts with its logs */
      const isLoggedShift = req.measurable.shiftIds.some(function (shift) {
        return shift.equals(req.shift._id);
      });
      if (!isLoggedShift) {
        req.measurable.shiftIds.push(req.shift._id);
        await req.measurable.save({ session });
      }
    });
    return res.sendStatus(201);
  } catch (err) {
    return handleErr500(res, err, 'Error creating log');
  }
});

/**
 * @swagger
 * /api/shifts/{shiftId}/logs:
 *   get:
 *     summary: Returns a list of the logs measured during a shift
 *     security:
 *       - BearerAuth: []
 *     tags: [Logs, Shifts]
 *     parameters:
 *       - in: path
 *         name: shiftId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the shift whose logs are being requested
 *     responses:
 *       200:
 *         description: The list of the requested shift logs
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/ShiftLog'
 *       404:
 *         description: The shift does not exist
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 */
shftLogsRouter.get('/', async (req, res) => {
  const shiftDet = await Shift.findById(req.shift._id)
    .select('logs').sort({ 'logs.time': -1 }).exec();
  return res.json(shiftDet.logs);
});

module.exports = { measLogsRouter, shftLogsRouter };
