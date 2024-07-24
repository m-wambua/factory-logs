'use strict';

/**
 * @swagger
 * components:
 *   schemas:
 *     Shift:
 *       type: object
 *       required:
 *         - id
 *         - lead
 *         - type
 *         - start
 *         - end
 *       properties:
 *         id:
 *           type: string
 *           description: The unique identifier of the shift
 *         lead:
 *           type: object
 *           description: The details of the user leading the during the shift
 *           properties:
 *             id:
 *               type: string
 *               description: The unique identifier of the user
 *             userName:
 *               type: string
 *               description: The unique userName of the user
 *         teammates:
 *           type: array
 *           description: List of the other users present during the shift
 *           items:
 *             type: object
 *             properties:
 *               id:
 *                 type: string
 *                 description: The unique identifier of a user
 *               userName:
 *                 type: string
 *                 description: The unique userName of a user
 *         type:
 *           type: string
 *           description: The type of shift ('Morning', 'Afternoon', 'Evening', 'Night', or 'Supervisory')
 *         start:
 *           type: string
 *           format: date-time
 *           description: The time the shift began (Defaults to now)
 *         end:
 *           type: string
 *           format: date-time
 *           description: The time the shift ended (Defaults to 5 hours from now)
 *         createdAt:
 *           type: string
 *           format: date-time
 *           description: The time the procedure was added to the system
 *         updatedAt:
 *           type: string
 *           format: date-time
 *           description: The last time the procedure details were edited
 *       example:
 *         id: 6778f8whfj5894bbhr883bb3
 *         lead:
 *           id: 666058acfd589890acb07e7f
 *           userName: Fct0.Oprt0
 *         teammates:
 *           - id: 676058acfd5894bbfe458ab5
 *             userName: Fct0.Tech0
 *           - id: 6778f8acfd5894bbfe883bb3
 *             userName: Fct0.Tech1
 *         type: Morning
 *         start: 2024-07-10T17:30:12.015Z
 *         end: 2024-07-10T22:30:12.015Z
 *         createdAt: 2024-07-10T17:30:12.015Z
 *         updatedAt: 2024-07-10T17:30:12.015Z
 *     ShiftShortDetail:
 *       type: object
 *       required:
 *         - id
 *         - lead
 *         - type
 *         - start
 *       properties:
 *         id:
 *           type: string
 *           description: The unique identifier of the shift
 *         lead:
 *           type: object
 *           description: The details of the user leading the during the shift
 *           properties:
 *             id:
 *               type: string
 *               description: The unique identifier of the user
 *             userName:
 *               type: string
 *               description: The unique userName of the user
 *         type:
 *           type: string
 *           description: The type of shift ('Morning', 'Afternoon', 'Evening', 'Night', or 'Supervisory')
 *         start:
 *           type: string
 *           format: date-time
 *           description: The time the shift began (Defaults to now)
 *       example:
 *         id: 6778f8whfj5894bbhr883bb3
 *         lead:
 *           id: 666058acfd589890acb07e7f
 *           userName: Fct0.Oprt0
 *         type: Morning
 *         start: 2024-07-10T17:30:12.015Z
 *     ShiftCreateInfo:
 *       type: object
 *       required:
 *         - type
 *       properties:
 *         teammates:
 *           type: array
 *           description: List of the other users present during the shift
 *           items:
 *             type: string
 *             description: The unique userName of a user on duty during the shift
 *         type:
 *           type: string
 *           description: The type of shift ('Morning', 'Afternoon', 'Evening', 'Night', or 'Supervisory')
 *         start:
 *           type: string
 *           format: date-time
 *           description: The time the shift began (Defaults to now)
 *         end:
 *           type: string
 *           format: date-time
 *           description: The time the shift ended (Defaults to 5 hours from now)
 *       example:
 *         teammates:
 *           - 676058acfd5894bbfe458ab5
 *           - 6778f8acfd5894bbfe883bb3
 *         type: Morning
 *         start: 2024-07-10T17:30:12.015Z
 *         end: 2024-07-10T22:30:12.015Z
 *     ShiftLog:
 *       type: object
 *       required:
 *         - measurableId
 *         - time
 *         - value
 *       properties:
 *         measurableId:
 *           type: string
 *           description: The unique identifier of the measurable that the log contains
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
 *         measurableId: 669ae6a3aeb6ecf601e0881a
 *         time: 2024-07-19T22:20:19.276Z
 *         value: 20
 *         remark: Power surge caused lower current draw
 * tags:
 *   name: Shifts
 *   description: The shifts management API
 */

const express = require('express');
const { User, Shift } = require('../models');
const { verifySession } = require('../controllers/auth');
const handleErr500 = require('../utils/senderr500');

const shiftsRouter = express.Router();

/** To make sure all routes after this point require a login */
shiftsRouter.use(verifySession);

/* Attaching the different shift routes */
const { shftDowntimesRouter } = require('./downtimes');
const { shftLogsRouter } = require('./logs');

shiftsRouter.use('/:shiftId/downtimes', shftDowntimesRouter);
shiftsRouter.use('/:shiftId/logs', shftLogsRouter);

/**
 * @swagger
 * /api/shifts/{shiftId}/ods:
 *   get:
 *     summary: Returns a list of the occurences during a shift (ODS)
 *     security:
 *       - BearerAuth: []
 *     tags: [Shifts]
 *     parameters:
 *       - in: path
 *         name: shiftId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the shift whose ODSs are being requested
 *     responses:
 *       200:
 *         description: The list of the requested shifts ODSs
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: string
 *                 description: Descriptive message of an occurence
 *               example:
 *                 - 'Power supply was fluctuating'
 *                 - 'High humidity forced equipment to be run slightly slower'
 *       404:
 *         description: The shift does not exist
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 */
shiftsRouter.get('/:shiftId/ods', async (req, res) => {
  const shiftDet = await Shift.findById(req.shift._id)
    .select('ODSs').exec();
  return res.json(shiftDet.ODSs);
});

/**
 * @swagger
 * /api/shifts/{shiftId}/ods:
 *   post:
 *     summary: Addds a new description of an occurence during a shift (ODS)
 *     security:
 *       - BearerAuth: []
 *     tags: [Shifts]
 *     parameters:
 *       - in: path
 *         name: shiftId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the shift to add the ODS to
 *     requestBody:
 *       description: The details of the occurence
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - desc
 *             properties:
 *               desc:
 *                 type: string
 *                 description: a descriptive message of the occurence
 *             example:
 *               desc: 'Power supply was fluctuating'
 *     responses:
 *       201:
 *         description: The ODS has been successfully added
 *       400:
 *         description: Bad Request. desc not provided of is an empty string.
 *       404:
 *         description: The shift does not exist
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *       500:
 *         description: Server Error. Could not add the ODS.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error saving ODS: ...'
 */
shiftsRouter.post('/:shiftId/ods', async (req, res) => {
  const { desc } = req.body;
  if ((!desc) || (desc === '')) {
    return res.status(400).send('Field "desc" is missing in the body or is empty');
  }
  const shiftDet = await Shift.findById(req.shift._id)
    .select('ODSs').exec();
  try {
    shiftDet.ODSs.push(desc);
    await shiftDet.save();
    return res.sendStatus(201);
  } catch (err) {
    return handleErr500(res, err, 'Error saving ODS');
  }
});

/**
 * @swagger
 * /api/shifts:
 *   get:
 *     summary: Returns a list of all the shifts in the system
 *     security:
 *       - BearerAuth: []
 *     tags: [Shifts]
 *     responses:
 *       200:
 *         description: The details of the requested shift
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/ShiftShortDetail'
 *       404:
 *         description: The shift does not exist
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 */
shiftsRouter.get('/', async (req, res) => {
  const shifts = await Shift.find()
    .select(['_id', 'leadId', 'type', 'start'])
    .populate({ path: 'leadId', select: ['userName'] })
    .sort({ start: -1 });
  return res.json(shifts);
});

/**
 * @swagger
 * /api/shifts:
 *   post:
 *     summary: Starts a new shift for logging of shift measurements
 *     security:
 *       - BearerAuth: []
 *     tags: [Shifts]
 *     requestBody:
 *       description: The details of the new shift
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/ShiftCreateInfo'
 *     responses:
 *       200:
 *         description: The details of the created shift
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Shift'
 *       400:
 *         description: Bad Request. type not provided, or teammates is not an array, or start / end is invalid.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Field "type" is missing in the body'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *       500:
 *         description: Server Error. Could not create the shift.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error creating shift: ...'
 */
shiftsRouter.post('/', async (req, res) => {
  if (!req.body["type"]) {
    return res.status(400)
      .send('Field "type" is missing in the body');
  }
  const { teammates, type, start, end } = req.body;
  let teammateIds;
  if (teammates) {
    if (!Array.isArray(teammates)) {
      return res.status(400)
        .send('Field "teammates" is not an array');
    }
    teammateIds = await teammates.map(async (mateName) => {
      return (await User.findOne({ userName: mateName })
        .select('_id').exec())._id;
    });
    if (teammateIds.includes(undefined)) {
      return res.status(400)
        .send('At least one of the teammate userNames is not in the system');
    }
  }
  if (start || end) {
    if (!start || !end) {
      return res.status(400)
        .send('If field "start" or "end" is provided, the other is required');
    }
    if ((isNaN(Date.parse(start))) || (isNaN(Date.parse(end)))) {
      return res.status(400)
        .send('Fields "start" and "end" should be valid time entries');
    }
    if ((Date.parse(start)) >= (Date.parse(end))) {
      return res.status(400)
        .send('Start time should be earlier than the end time');
    }
  }
  try {
    const shift = await Shift.create({
      _factoryId: req.user.factoryId,
      leadId: req.user._id,
      teammateIds, type,
      start: new Date(start),
      end: new Date(end)
    });
    shift.logs = undefined;
    shift.downtimeIds = undefined;
    shift.ODSs = undefined;
    await shift.populate({ path: 'teammateIds', select: ['userName'] })
      .populate({ path: 'leadId', select: ['userName']});
    return res.json(shift);
  } catch (err) {
    return handleErr500(res, err, 'Error creating shift');
  }
});

/**
 * @swagger
 * /api/shifts/{shiftId}:
 *   delete:
 *     summary: Deletes a shift if it has no measurable or downtime logs (Only shift-lead and Admins)
 *     security:
 *       - BearerAuth: []
 *     tags: [Shifts]
 *     parameters:
 *       - in: path
 *         name: shiftId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the shift to be deleted
 *     responses:
 *       204:
 *         description: Successfully deleted the shift
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *       404:
 *         description: The shift does not exist
 *       406:
 *         description: Not Allowed. The shift must have no correspondng logs
 *       500:
 *         description: Server Error. Could not delete the shift.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error deleting the shift: ...'
 */
shiftsRouter.delete('/:shiftId', async (req, res) => {
  if ((req.user?.role !== 'Admin') && (req.shift.leadId._id !== req.user._id)) {
    return res.status(403).send('Only admins and shift leads can delete shifts');
  }
  const shift = await Shift.findById(req.shift._id)
    .select(['logs', 'ODSs', 'downtimeIds']).exec();
  if ((shift.logs.length) || (shift.ODSs.length) || (shift.downtimeIds.length)) {
    return res.status(406).send('The shift already has logs and may not be deleted');
  }
  try {
    await shift.deleteOne();
    return res.sendStatus(204);
  } catch (err) {
    return handleErr500(res, err, 'Error deleting shift');
  }
});

/**
 * @swagger
 * /api/shifts/{shiftId}:
 *   put:
 *     summary: Edits the details of an shift (only admins & shift-lead)
 *     security:
 *       - BearerAuth: []
 *     tags: [Shifts]
 *     parameters:
 *       - in: path
 *         name: shiftId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the shift to be edited
 *     requestBody:
 *       description: The new details of the shift
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *               $ref: '#/components/schemas/ShiftCreateInfo'
 *     responses:
 *       200:
 *         description: The details of the edited shift
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Shift'
 *       400:
 *         description: Bad Request. name, type, manufacturer, serialNum, rating and location not provided. At least one is required.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'No supported field has been provided for edit'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *       404:
 *         description: The startup procedure does not exist
 *       500:
 *         description: Server Error. Could not edit the shift.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error updating shift: ...'
 */
shiftsRouter.put('/:shiftId', async (req, res) => {
  if ((req.user?.role !== 'Admin') && (req.shift.leadId._id !== req.user._id)) {
    return res.status(403).send('Only admins and shift leads can edit an shift');
  }
  const { teammates, type, start, end } = req.body;
  if ((!teammates) && (!type) && (!start) && (!end)) {
    return res.status(400)
      .send('No supported field has been provided for edit');
  }
  try {
    if (teammates) {
      if (!Array.isArray(teammates)) {
        return res.status(400)
          .send('Field "teammates" is not an array');
      }
      const teammateIds = await teammates.map(async (mateName) => {
        return (await User.findOne({ userName: mateName })
          .select('_id').exec())._id;
      });
      if (teammateIds.includes(undefined)) {
        return res.status(400)
          .send('One of the teammate userNames is not in the system');
      }
      req.shift.teammateIds.splice(0, req.shift.teammateIds.length);
      req.shift.teammateIds.push(...teammateIds);
    }
    if (start || end) {
      const startTime = Date.parse(start ?? req.shift.start);
      if (isNaN(startTime)) {
        return res.status(400)
          .send('Field "start" should be a valid time entry');
      }
      const endTime = Date.parse(end ?? req.shift.end);
      if (isNaN(endTime)) {
        return res.status(400)
          .send('Field "end" should be a valid time entry');
      }
      if (startTime >= endTime) {
        return res.status(400)
          .send('Start time should be earlier than the end time');
      }
      req.shift.start = new Date(startTime);
      req.shift.end = new Date(endTime);
    }
    if (type) {
      req.shift.type = type;
    }
    await req.shift.save();
    await req.shift.populate({ path: 'teammateIds', select: ['userName'] })
      .populate({ path: 'leadId', select: ['userName']});
    return res.json(req.shift);
  } catch (err) {
    return handleErr500(res, err, 'Error updating shift');
  }
});

/**
 * @swagger
 * /api/shifts/{shiftId}:
 *   get:
 *     summary: Returns the details of a specific shift
 *     security:
 *       - BearerAuth: []
 *     tags: [Shifts]
 *     parameters:
 *       - in: path
 *         name: shiftId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the shift being requested
 *     responses:
 *       200:
 *         description: The details of the requested shift
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Shift'
 *       404:
 *         description: The shift does not exist
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 */
shiftsRouter.get('/:shiftId', async (req, res) => {
  await req.shift.populate({ path: 'teammateIds', select: ['userName'] });
  await req.shift.populate({ path: 'leadId', select: ['userName']});
  return res.json(req.shift);
});

module.exports = shiftsRouter;
