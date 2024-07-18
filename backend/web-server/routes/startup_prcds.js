'use strict';

/**
 * @swagger
 * components:
 *   schemas:
 *     StartupPrcd:
 *       type: object
 *       required:
 *         - id
 *         - author
 *         - steps
 *       properties:
 *         id:
 *           type: string
 *           description: The unique identifier of the startup procedure
 *         author:
 *           type: object
 *           description: The details of the user who published the startup proecdure
 *           properties:
 *             id:
 *               type: string
 *               description: The identifier of the author
 *             userName:
 *               type: string
 *               description: The userName of the author
 *         prevPrcdId:
 *           type: string
 *           description: The identifier of the procedure that was overwritten by this one
 *         changeLog:
 *           type: string
 *           description: A description of the updates from the previous procedure
 *         steps:
 *           type: array
 *           description: The list of actions to be taken during startup procedure
 *           items:
 *             type: string
 *             description: the action of a given step
 *         createdAt:
 *           type: string
 *           format: date-time
 *           description: The time the procedure was added to the system
 *         updatedAt:
 *           type: string
 *           format: date-time
 *           description: The last time the procedure details were edited
 *       example:
 *         id: 66957454aa580a78c46a3017
 *         author:
 *           id: 65324h3kj3545565n23hu870
 *           userName: Fct0.Oprt0
 *         changeLog: 'First published Startup Procedure'
 *         steps:
 *           - 'Step1: first step of startup'
 *           - 'Step2: second step of startup'
 *         createdAt: 2024-07-10T17:30:12.015Z
 *         updatedAt: 2024-07-10T17:30:12.015Z
 * tags:
 *   name: StartupPrcds
 *   description: The startup procedures management API
 */

const express = require('express');
const { StartupPrcd } = require('../models');
const { verifySession } = require('../controllers/auth');
const handleErr500 = require('../utils/senderr500');

const startupPrcdRouter = express.Router();

/** To make sure all routes after this point require a login */
startupPrcdRouter.use(verifySession);

/**
 * @swagger
 * /api/startup/cleanprev/{startupId}:
 *   delete:
 *     summary: Deletes previous versions of a startup procedure merging changeLogs (only admins & operators)
 *     security:
 *       - BearerAuth: []
 *     tags: [StartupPrcds]
 *     parameters:
 *       - in: path
 *         name: startupId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the startup procedure to be cleaned up
 *     responses:
 *       200:
 *         description: The details of the cleaned up startup procedure
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/StartupPrcd'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *       404:
 *         description: The startup procedure does not exist
 *       500:
 *         description: Server Error. Could not clean the startup procedure.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error cleaning startup procedure: ...'
 */
startupPrcdRouter.delete('/cleanprev/:startupId', async (req, res) => {
  if (!['Admin', 'Operator'].includes(req.user?.role)) {
    return res.status(403).send('Only admins and operators can clean startup procedures');
  }
  try {
    const session = await req.app.db.startSession();
    await session.withTransaction(async (session) => {
      let cleanIndicator = `\n\n===[Clean]===> ${(new Date).toISOString()}:`
      cleanIndicator = `${cleanIndicator} ${req.user.userName} (id ${req.user._id}) ++\n`
      /** Recursive function for cleaning up linked list of procedures */
      async function cleanupPrcd (prcd) {
        if (prcd.prevPrcdId){
          const prevPrcd = await StartupPrcd.findById(prcd.prevPrcdId)
            .select(['_id', 'changeLog', 'prevPrcdId']).exec();
          const appendChngLog = await cleanupPrcd (prevPrcd);
          prevPrcd.deleteOne({ session });
          return `${prcd.changeLog}${cleanIndicator}${appendChngLog}`;
        } else {
          return prcd.changeLog;
        }
      }
      req.startupPrcd.changeLog = await cleanupPrcd(req.startupPrcd);
      req.startupPrcd.prevPrcdId = undefined;
      await req.startupPrcd.save({ session });
    });
    return res.json(req.startupPrcd);
  } catch (err) {
    return handleErr500(res, err, 'Error cleaning startup procedure');
  }
});

/**
 * @swagger
 * /api/startup/process/{processId}:
 *   post:
 *     summary: Adds a new startup procedure to a given process, overwriting an existing one (only admins & operators)
 *     security:
 *       - BearerAuth: []
 *     tags: [StartupPrcds]
 *     parameters:
 *       - in: path
 *         name: processId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the process that the startup procedure belongs
 *     requestBody:
 *       description: The details of the new startup procedure
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - steps
 *             properties:
 *               changeLog:
 *                 type: string
 *                 description: A description of the updates from the previous procedure
 *               steps:
 *                 type: array
 *                 description: The list of actions to be taken during startup procedure
 *                 items:
 *                   type: string
 *                   description: the action of a given step
 *             example:
 *               changeLog: 'Update after replacing motor drive'
 *               steps:
 *                 - 'Step1: first step of startup'
 *                 - 'Step2: second step of startup'
 *                 - 'Step3: third step of startup'
 *     responses:
 *       200:
 *         description: The details of the created startup procedure
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/StartupPrcd'
 *       400:
 *         description: Bad Request. steps not provided or is not of the correct format (array).
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Field "steps" is missing in the body or is not an array'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *       404:
 *         description: The process does not exist or does not belong to the current user's factory
 *       500:
 *         description: Server Error. Could not create the startup procedure.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error creating startup procedure: ...'
 */
startupPrcdRouter.post('/process/:processId', async (req, res) => {
  if (!['Admin', 'Operator'].includes(req.user?.role)) {
    return res.status(403).send('Only admins and operators can add startup procedures');
  }
  const { changeLog, steps } = req.body;
  if ((!steps) || (!Array.isArray(steps))) {
    return res.status(400)
      .send('Field "steps" is missing in the body or is not an array');
  }
  if ((!changeLog) && (req.process.startupId)) {
    return res.status(400)
      .send('Field "changeLog" is required when overwriting a process\'s startup procedure');
  }
  try {
    const session = await req.app.db.startSession();
    const startupPrcd = await session.withTransaction(async (session) => {
      const startupPrcds = await StartupPrcd.create([{
        _factoryId: req.user.factoryId,
        authorId: req.user._id,
        prevPrcdId: req.process.startupId,
        changeLog,
        steps: [...steps]
      }], { session });
      req.process.startupId = startupPrcds[0]._id;
      await req.process.save({ session });
      return startupPrcds[0];
    });
    return res.json(startupPrcd);
  } catch (err) {
    return handleErr500(res, err, 'Error creating startup procedure');
  }
});

/**
 * @swagger
 * /api/startup/{startupId}:
 *   put:
 *     summary: Edits the details of a startup procedure (only admins & author)
 *     security:
 *       - BearerAuth: []
 *     tags: [StartupPrcds]
 *     parameters:
 *       - in: path
 *         name: startupId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the startup procedure to be edited
 *     requestBody:
 *       description: The details of the new startup procedure
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - oneOf:
 *                 - changeLog
 *                 - steps
 *             properties:
 *               changeLog:
 *                 type: string
 *                 description: A description of the updates from the previous procedure
 *               steps:
 *                 type: array
 *                 description: The list of actions to be taken during startup procedure
 *                 items:
 *                   type: string
 *                   description: the action of a given step
 *             example:
 *               changeLog: 'Update after replacing motor drive (stressing first step)'
 *               steps:
 *                 - 'Step1: very important first step of startup'
 *                 - 'Step2: second step of startup'
 *                 - 'Step3: third step of startup'
 *     responses:
 *       200:
 *         description: The details of the edited startup procedure
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/StartupPrcd'
 *       400:
 *         description: Bad Request. steps or changeLog not provided. At least one is required.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Fields "changeLog" or "steps" required for edit'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *       404:
 *         description: The startup procedure does not exist
 *       500:
 *         description: Server Error. Could not edit the startup procedure.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error updating startup procedure: ...'
 */
startupPrcdRouter.put('/:startupId', async (req, res) => {
  if ((req.user?.role !== 'Admin') && (req.user._id !== req.startupPrcd.authorId._id)) {
    return res.status(403).send('Only admins and its author can edit a startup procedure');
  }
  const { changeLog, steps } = req.body;
  if ((!steps) && (!changeLog)) {
    return res.status(400)
      .send('Fields "changeLog" or "steps" required for edit');
  }
  if (!Array.isArray(steps)) {
    return res.status(400)
      .send('Fields "steps" is not an array');
  }
  try {
    if (changeLog) {
      req.startupPrcd.changeLog = changeLog;
    }
    if (steps) {
      req.startupPrcd.steps = [...steps];
    }
    await req.startupPrcd.save();
    return res.json(req.startupPrcd);
  } catch (err) {
    return handleErr500(res, err, 'Error updating startup procedure');
  }
});

/**
 * @swagger
 * /api/startup/{startupId}:
 *   get:
 *     summary: Returns the details of a specific startup procedure
 *     security:
 *       - BearerAuth: []
 *     tags: [StartupPrcds]
 *     parameters:
 *       - in: path
 *         name: startupId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the startup procedure being requested
 *     responses:
 *       200:
 *         description: The details of the requested startup procedure
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/StartupPrcd'
 *       404:
 *         description: The startup procedure does not exist
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 */
startupPrcdRouter.get('/:startupId', async (req, res) => {
  return res.json(req.startupPrcd);
});

module.exports = startupPrcdRouter;
