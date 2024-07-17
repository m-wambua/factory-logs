'use strict';

/**
 * @swagger
 * components:
 *   schemas:
 *     Process:
 *       type: object
 *       required:
 *         - id
 *         - name
 *         - createdAt
 *         - updatedAt
 *       properties:
 *         id:
 *           type: string
 *           description: The unique identifier of the process
 *         name:
 *           type: string
 *           description: The unique name of the process
 *         startupId:
 *           type: string
 *           description: The unique identifier of the latest startup procedure for the process
 *         equipmentIds:
 *           type: array
 *           items:
 *             type: string
 *             description: The unique identifier of an equipment of the process
 *         createdAt:
 *           type: string
 *           format: date-time
 *           description: The time the process was added to the system
 *         updatedAt:
 *           type: string
 *           format: date-time
 *           description: The last time the process details were edited
 *       example:
 *         id: 668ec52476e53805e7fa5cc6
 *         name: Fct0.Process0
 *         startupId: 768fg69423y56242c9j9rp9
 *         equipmentIds:
 *           - 768fg69423y56242c9j9rp9
 *           - 478gd98789d57587h2s9fm6
 *           - 345mf90368n95864w9f2md7
 *         createdAt: 2024-07-10T17:30:12.515Z
 *         updatedAt: 2024-07-10T17:30:12.515Z
 *     ProcessInfo:
 *       type: object
 *       required:
 *         - id
 *         - name
 *         - createdAt
 *         - updatedAt
 *       properties:
 *         id:
 *           type: string
 *           description: The unique identifier of the process
 *         name:
 *           type: string
 *           description: The unique name of the process
 *         startup:
 *           type: object
 *           description: The short details of the latest startup procedure for the process
 *           properties:
 *             id:
 *               type: string
 *               description: The unique identifier of the startup procedure
 *             steps:
 *               type: array
 *               description: The list of actions to be taken during startup of the process
 *               items:
 *                 type: string
 *                 description: the action of a given step
 *         equipmentTypes:
 *           type: array
 *           description: The types of equipment that the process has
 *           items:
 *             type: object
 *             description: The process's equipment that are of a specific type
 *             additionalProperties:
 *               type: array
 *               items:
 *                 type: object
 *                 description: The short details of a specific equipment
 *                 properties:
 *                   id:
 *                     type: string
 *                     description: The unique identifier of the equipment
 *                   name:
 *                     type: string
 *                     description: The name of the equipment
 *         createdAt:
 *           type: string
 *           format: date-time
 *           description: The time the process was added to the system
 *         updatedAt:
 *           type: string
 *           format: date-time
 *           description: The last time the process details were edited
 *       example:
 *         id: 668ec52476e53805e7fa5cc6
 *         name: Fct0.Process0
 *         startup:
 *           id: 66957454aa580a78c46a3017
 *           steps:
 *             - 'Step1: first step of startup'
 *             - 'Step2: second step of startup'
 *         equipmentTypes:
 *           Drive:
 *             - id: 768fg69423y56242c9j9rp9
 *               name: F0P0.Eqpt0
 *             - id: 478gd98789d57587h2s9fm6
 *               name: F0P0.Eqpt1
 *           Motor:
 *             - id: 345mf90368n95864w9f2md7
 *               name: F0P0.Eqpt2
 *         createdAt: 2024-07-10T17:30:12.515Z
 *         updatedAt: 2024-07-10T17:30:12.515Z
 * tags:
 *   name: Processes
 *   description: The processes management API
 */

const express = require('express');
const { Factory, Process } = require('../models');
const { verifySession } = require('../controllers/auth');
const handleErr500 = require('../utils/senderr500');

const processesRouter = express.Router();

/** To make sure all routes after this point require a login */
processesRouter.use(verifySession);

/**
 * @swagger
 * /api/processes:
 *   get:
 *     summary: Returns a list of all the processes of the current user's factory
 *     security:
 *       - BearerAuth: []
 *     tags: [Processes]
 *     responses:
 *       200:
 *         description: The list of processes
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Process'
 */
processesRouter.get('/', async (req, res) => {
  const factory = await Factory.findById(req.user.factoryId)
    .select('processIds').populate('processIds')
    .exec();
  return res.json(factory.processIds);
});

/**
 * @swagger
 * /api/processes/:
 *   post:
 *     summary: Adds a new process to the current user's factory (only admins)
 *     security:
 *       - BearerAuth: []
 *     tags: [Processes]
 *     requestBody:
 *       description: The details of the new process
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *             properties:
 *               name:
 *                 type: string
 *                 description: The unique name to be saved for the new process
 *             example:
 *               name: Fct0.Prcs3
 *     responses:
 *       200:
 *         description: The details of the created process
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Process'
 *       400:
 *         description: Bad Request. name not provided.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Field "name" is missing in the body'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *       500:
 *         description: Server Error. Could not create the process.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error creating process: ...'
 */
processesRouter.post('/', async (req, res) => {
  if (req.user?.role !== 'Admin') {
    return res.status(403).send('Only admins can add new processes');
  }
  const { name } = req.body;
  if (!name) {
    return res.status(400)
      .send('Field "name" is missing in the body');
  }
  try {
    const session = await req.app.db.startSession();
    const process = await session.withTransaction(async (session) => {
      const processes = await Process.create([
        { _factoryId: req.user.factoryId, name }
      ], { session });
      const factory = await Factory.findById(req.user.factoryId).exec();
      factory.processIds.push(processes[0]._id);
      await factory.save({ session });
      return processes[0];
    });
    return res.json(process);
  } catch (err) {
    return handleErr500(res, err, 'Error creating process');
  }
});

/**
 * @swagger
 * /api/processes/{processId}:
 *   put:
 *     summary: Edits the details of a process (only admins & operators)
 *     security:
 *       - BearerAuth: []
 *     tags: [Processes]
 *     parameters:
 *       - in: path
 *         name: processId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the process to be edited
 *     requestBody:
 *       description: The new details of the process
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *             properties:
 *               name:
 *                 type: string
 *                 description: The unique name to be saved for the process
 *             example:
 *               name: Fct0.PrcsA
 *     responses:
 *       200:
 *         description: The details of the edited process
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Process'
 *       400:
 *         description: Bad Request. name not provided.
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
 *         description: Server Error. Could not edit the process.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error updating process: ...'
 */
processesRouter.put('/:processId', async (req, res) => {
  if (!['Admin', 'Operator'].includes(req.user?.role)) {
    return res.status(403).send('Only admins and operators can edit processes');
  }
  const { name } = req.body;
  if (!name) {
    return res.status(400)
      .send('Field "name" is missing in the body');
  }
  try {
    req.process.name = name;
    await req.process.save();
    return res.json(req.process);
  } catch (err) {
    return handleErr500(res, err, 'Error updating process');
  }
});

/**
 * @swagger
 * /api/processes/{processId}:
 *   get:
 *     summary: Returns the details of a specific process
 *     security:
 *       - BearerAuth: []
 *     tags: [Processes]
 *     parameters:
 *       - in: path
 *         name: processId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the process being requested
 *     responses:
 *       200:
 *         description: The expanded details of the requested process
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ProcessInfo'
 *       404:
 *         description: The process does not exist or does not belong to the current user's factory
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 */
processesRouter.get('/:processId', async (req, res) => {
  await req.process.populate({
    path: 'startupId',
    select: 'steps'
  });

  await req.process.populate({
    path: 'equipmentIds',
    select: ['_id', 'name', 'type']
  });
  const equipmentTypes = req.process.equipmentIds.reduce((types, item) => {
    const type = (types[item.type] || []);
    type.push(item);
    types[item.type] = type;
    item.type = undefined;
    return types;
  }, {});
  req.process.equipmentIds = undefined;
  return res.json({ ...req.process.toJSON(), equipmentTypes });
});

module.exports = processesRouter;
