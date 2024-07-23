'use strict';

/**
 * @swagger
 * components:
 *   schemas:
 *     EquipmentDowntime:
 *       type: object
 *       required:
 *         - id
 *         - shiftId
 *         - type
 *         - downAt
 *         - resumedAt
 *       properties:
 *         id:
 *           type: string
 *           description: The unique-idenifier of the downtime log
 *         shiftId:
 *           type: string
 *           description: The unique identifier of the shift when the downtime occurred
 *         type:
 *           type: string
 *           description: The downtime class to which the new downtime belongs ('Failure', or 'Maintenance')
 *         downAt:
 *           type: string
 *           format: date-time
 *           description: The time when the downtime began
 *         resumedAt:
 *           type: string
 *           format: date-time
 *           description: The time when the equipment was back up and running
 *         remark:
 *           type: string
 *           description: An optional description of the downtime
 *       example:
 *         id: 676058acfd5894bbfe458ab5
 *         shiftId: 6778f8acfd5894bbfe883bb3
 *         type: Failure
 *         downAt: 2024-07-10T17:30:12.015Z
 *         resumedAt: 2024-07-10T17:40:12.015Z
 *         remark: Caused by overheating after cooling system ran out of water
 *     ShifttDowntime:
 *       type: object
 *       required:
 *         - id
 *         - equipment
 *         - type
 *         - downAt
 *         - resumedAt
 *       properties:
 *         id:
 *           type: string
 *           description: The unique-idenifier of the downtime log
 *         equipment:
 *           type: object
 *           description: The details of the equipment that experienced the downtime
 *           properties:
 *             id:
 *               type: string
 *               description: The unique-identifier of the equipment
 *             name:
 *               type: string
 *               description: The factory-unique name of the equipment
 *         type:
 *           type: string
 *           description: The downtime class to which the new downtime belongs ('Failure', or 'Maintenance')
 *         downAt:
 *           type: string
 *           format: date-time
 *           description: The time when the downtime began
 *         resumedAt:
 *           type: string
 *           format: date-time
 *           description: The time when the equipment was back up and running
 *         remark:
 *           type: string
 *           description: An optional description of the downtime
 *       example:
 *         id: 676058acfd5894bbfe458ab5
 *         equipment:
 *           id: 6778f8acfd5894bbfe883bb3
 *           name: F0P0.Eqpt0
 *         type: Failure
 *         downAt: 2024-07-10T17:30:12.015Z
 *         resumedAt: 2024-07-10T17:40:12.015Z
 *         remark: Caused by overheating after cooling system ran out of water
 *     DowntimeCreateInfo:
 *       type: object
 *       required:
 *         - equipmentId
 *         - type
 *       properties:
 *         equipmentId:
 *           type: string
 *           description: The unique-identifier of the equipment that experienced the downtime
 *         type:
 *           type: string
 *           description: The downtime class to which the new downtime belongs ('Failure', or 'Maintenance')
 *         downAt:
 *           type: string
 *           format: date-time
 *           description: The time when the downtime began (defaults to now)
 *         resumedAt:
 *           type: string
 *           format: date-time
 *           description: The time when the equipment was back up and running (defaults to 1 hour after downAt)
 *         remark:
 *           type: string
 *           description: An optional description of the downtime
 *       example:
 *         equipmentId: 6778f8acfd5894bbfe883bb3
 *         type: Failure
 *         downAt: 2024-07-10T17:30:12.015Z
 *         resumedAt: 2024-07-10T17:40:12.015Z
 *         remark: Caused by overheating after cooling system ran out of water
 *     DowntimeEditInfo:
 *       type: object
 *       required:
 *         - oneOf:
 *           - resumedAt
 *           - remark
 *       properties:
 *         resumedAt:
 *           type: string
 *           format: date-time
 *           description: The time when the equipment was back up and running
 *         remark:
 *           type: string
 *           description: An optional description of the downtime
 *       example:
 *         resumedAt: 2024-07-10T17:50:12.015Z
 * tags:
 *   name: Downtimes
 *   description: The downtimes management API
 */

const express = require('express');
const { Equipment, Shift, Downtime } = require('../models');
const { verifySession } = require('../controllers/auth');
const handleErr500 = require('../utils/senderr500');

const eqptDowntimesRouter = express.Router();

/** To make sure all routes after this point require a login */
eqptDowntimesRouter.use(verifySession);

/**
 * @swagger
 * /api/equipments/{equipmentId}/downtimes:
 *   get:
 *     summary: Returns a list of the downtimes that the equipment has
 *     security:
 *       - BearerAuth: []
 *     tags: [Equipments]
 *     parameters:
 *       - in: path
 *         name: equipmentId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the equipment whose downtimes are being requested
 *     responses:
 *       200:
 *         description: The list of the requested equipment downtimes
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/EquipmentDowntime'
 *       404:
 *         description: The equipment does not exist
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 */
eqptDowntimesRouter.get('/', async (req, res) => {
  const equipmentDet = await Equipment.findById(req.equipment._id)
    .select('downtimeIds')
    .populate({
      path: 'downtimeIds',
      select: '-equipmentId',
      sort: { downAt: -1 }
    }).exec();
  return res.json(equipmentDet.downtimeIds);
});

const shftDowntimesRouter = express.Router();

/** To make sure all routes after this point require a login */
shftDowntimesRouter.use(verifySession);

/**
 * @swagger
 * /api/shifts/{shiftId}/downtimes:
 *   post:
 *     summary: Records a new downtime that occurred during a shift (team-members or lead only)
 *     security:
 *       - BearerAuth: []
 *     tags: [Downtimes, Shifts]
 *     parameters:
 *       - in: path
 *         name: shiftId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the shift to which the downtime belongs
 *     requestBody:
 *       description: The details of the new downtime
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/DowntimeCreateInfo'
 *     responses:
 *       201:
 *         description: Successfully created the shift downtime
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/ShiftDowntime'
 *       404:
 *         description: The shift does not exist
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *       500:
 *         description: Server Error. Could not add the downtime log.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error creating downtime: ...'
 */
shftDowntimesRouter.post('/', async (req, res) => {
  if ((!req.shift.teammateIds.includes(req.user._id)) && (!req.shift.leadId.equals(req.user._id))) {
    return res.status(403).send('Only team members and leads can add downtimes in their shift');
  }
  for (const required of ["equipmentId", "type"]) {
    if (!req.body[required]) {
      return res.status(400)
        .send(`Field "${required}" is missing in the body`);
    }
  }
  const { equipmentId, type, downAt, resumedAt, remark } = req.body;
  req.equipment = await Equipment.findById(equipmentId).select(['downtimeIds']).exec();
  if (!req.equipment) {
    return res.status(400)
      .send('The provided equipmentId is not in the system');
  }
  if (resumedAt && !downAt) {
    return res.status(400)
      .send('Field "downAt" is required if "resumedAt" is provided');
  }
  const downAtTime = (downAt) ? Date.parse(downAt) : Date.now();
  const resumedAtTime = (resumedAt) ? Date.parse(resumedAt) : (downAtTime + 3600000);
  if (isNaN(downAtTime) || isNaN(resumedAtTime)) {
    return res.status(400)
      .send('Fields "downAt" and "resumedAt" should be valid time entries');
  }
  if (downAtTime >= resumedAtTime) {
    return res.status(400)
      .send('DownAt time should be earlier than the resumedAt time');
  }
  try {
    const session = await req.app.db.startSession();
    const downtime = await session.withTransaction(async (session) => {
      const downtimes = await Downtime.create([{
        shiftId: req.shift._id,
        equipmentId, type, remark,
        downAt: new Date(downAtTime),
        resumedAt: new Date(resumedAtTime)
      }], { session });
      req.equipment.downtimeIds.push(downtimes[0]._id);
      await req.equipment.save({ session });
      const shiftDet = await Shift.findById(req.shift._id)
        .select('downtimeIds').exec();
      shiftDet.downtimeIds.push(downtimes[0]._id);
      await shiftDet.save({ session });
      return downtimes[0];
    });
    downtime.shiftId = undefined;
    return res.json(downtime);
  } catch (err) {
    return handleErr500(res, err, 'Error creating downtime');
  }
});

/**
 * @swagger
 * /api/shifts/{shiftId}/downtimes:
 *   get:
 *     summary: Returns a list of the downtimes that occurred during a shift
 *     security:
 *       - BearerAuth: []
 *     tags: [Downtimes, Shifts]
 *     parameters:
 *       - in: path
 *         name: shiftId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the shift whose downtimes are being requested
 *     responses:
 *       200:
 *         description: The list of the requested shift downtimes
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/ShiftDowntime'
 *       404:
 *         description: The shift does not exist
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 */
shftDowntimesRouter.get('/', async (req, res) => {
  const shiftDet = await Shift.findById(req.shift._id)
    .select('downtimeIds')
    .populate({
      path: 'downtimeIds',
      select: '-shiftId',
      populate: { path: 'equipmentId', select: ['name'] },
      sort: { downAt: -1 }
    }).exec();
  return res.json(shiftDet.downtimeIds);
});

/**
 * @swagger
 * /api/shifts/{shiftId}/downtimes/{downtimeId}:
 *   put:
 *     summary: Edits the details of a downtime (team-members or lead only)
 *     security:
 *       - BearerAuth: []
 *     tags: [Downtimes, Shifts]
 *     parameters:
 *       - in: path
 *         name: shiftId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the shift to which the downtime belongs
 *       - in: path
 *         name: downtimeId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the downtime to be edited
 *     requestBody:
 *       description: The new details of the downtime
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/DowntimeEditInfo'
 *     responses:
 *       200:
 *         description: The list of the requested shift downtimes
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/ShiftDowntime'
 *       400:
 *         description: Bad Request. resumedAt and remark not provided. At least one is required.
 *       404:
 *         description: The shift or downtime does not exist
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *       500:
 *         description: Server Error. Could not edit the downtime.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error updating downtime: ...'
 */
shftDowntimesRouter.put('/:downtimeId', async (req, res) => {
  req.downtime = await Downtime.findById(req.params.downtimeId).exec();
  if ((!req.downtime) || (!req.downtime.shiftId.equals(req.shift._id))) {
    return res.status(404);
  }
  if ((!req.shift.teammateIds.includes(req.user._id)) && (!req.shift.leadId.equals(req.user._id))) {
    return res.status(403).send('Only team members and leads can edit downtimes of their shift');
  }
  const { resumedAt, remark } = req.body;
  if ((!resumedAt) && (!remark)) {
    return res.status(400)
      .send('No supported field has been provided for edit');
  }
  if (resumedAt) {
    if (isNaN(Date.parse(resumedAt))) {
      return res.status(400)
        .send('Field "resumedAt" should be a valid time entry');
    }
    if ((Date.parse(req.downtime.downAt)) >= (Date.parse(resumedAt))) {
      return res.status(400)
        .send('DownAt time should be earlier than the resumedAt time');
    }
    req.downtime.resumedAt = new Date(resumedAt);
  }
  if (remark) {
    req.downtime.remark = remark;
  }
  try {
    await req.downtime.save();
    return res.json(req.downtime);
  } catch (err) {
    return handleErr500(res, err, 'Error updating downtime');
  }
});

module.exports = { eqptDowntimesRouter, shftDowntimesRouter };
