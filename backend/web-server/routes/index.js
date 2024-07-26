'use strict';

/**
 * @swagger
 * components:
 *   parameters:
 *     pagination_cursor:
 *       in: query
 *       name: cursor
 *       schema:
 *         type: string
 *       required: false
 *       description: the cursor from a previous request to load the next values
 *     pagination_limit:
 *       in: query
 *       name: limit
 *       schema:
 *         type: integer
 *         maximum: 40
 *         minimum: 1
 *       required: false
 *       description: the maximum number of items to retrieve, defaults to 20
 */

const express = require('express');
const models= require('../models');

const apiRouter = express.Router();

/* Attaching the different routes */
const authRouter = require('./auth');
const usersRouter = require('./users');
const factoriesRouter = require('./factories');
const processesRouter = require('./processes');
const startupPrcdsRouter = require('./startup_prcds');
const equipmentsRouter = require('./equipments');
const { measurablesRouter } = require('./measurables');
const shiftsRouter = require('./shifts');
const { cableSchedsRouter } = require('./cable_scheds');
const { cableDescsRouter } = require('./cable_descs');

apiRouter.use('/auth', authRouter);
apiRouter.use('/users', usersRouter);
apiRouter.use('/factories', factoriesRouter);
apiRouter.use('/processes', processesRouter);
apiRouter.use('/startup', startupPrcdsRouter);
apiRouter.use('/equipments', equipmentsRouter);
apiRouter.use('/measurables', measurablesRouter);
apiRouter.use('/shifts', shiftsRouter);
apiRouter.use('/cablescheds', cableSchedsRouter);
apiRouter.use('/cabledescs', cableDescsRouter);

/** Middleware for retrieving a specific user's details for
 *  admin purposes */
async function userIdParamCallback (req, res, next, userId) {
  if (req.user.role !== 'Admin') {
    return res.status(403).send('Only admins may access a specific user\'s details');
  }
  req.subjUser = await models.User.findById(userId).exec();
  if (!req.subjUser) {
    return res.sendStatus(404);
  }
  if (!req.subjUser.factoryId.equals(req.user.factoryId)) {
    return res.status(403).send('The requested user does not belong to the admin\'s factory');
  }
  next();
}

/** Middleware for retrieving a specific process's details */
async function processIdParamCallback (req, res, next, processId) {
  req.process = await models.Process.findById(processId).exec();
  if (!req.process) {
    return res.sendStatus(404);
  }
  if (!req.process._factoryId.equals(req.user.factoryId)) {
    return res.status(403).send('The process does not belong to the user\'s factory');
  }
  next();
}

/** Middleware for retrieving a specific startup procedure's details */
async function startupIdParamCallback (req, res, next, startupId) {
  req.startupPrcd = await models.StartupPrcd.findById(startupId)
    .populate({ path: 'authorId', select: ['_id', 'username'] }).exec();
  if (!req.startupPrcd) {
    return res.sendStatus(404);
  }
  if (!req.startupPrcd._factoryId.equals(req.user.factoryId)) {
    return res.status(403).send('The startup procedure does not belong to the user\'s factory');
  }
  next();
}

/** Middleware for retrieving a specific equipment's details */
async function equipmentIdParamCallback (req, res, next, equipmentId) {
  req.equipment = await models.Equipment.findById(equipmentId)
    .select(['-manuals', '-downtimeIds', '-cableSchedIds', '-codebases'])
    .populate({ path: 'measurableIds', select: ['quantity', 'unit'] }).exec();
  if (!req.equipment) {
    return res.sendStatus(404);
  }
  if (!req.equipment._factoryId.equals(req.user.factoryId)) {
    return res.status(403).send('The equipment does not belong to the user\'s factory');
  }
  next();
}

/** Middleware for retrieving a specific shift's details */
async function shiftIdParamCallback (req, res, next, shiftId) {
  req.shift = await models.Shift.findById(shiftId)
    .select(['-logs', '-ODSs', '-downtimeIds']).exec();
  if (!req.shift) {
    return res.sendStatus(404);
  }
  if (!req.shift._factoryId.equals(req.user.factoryId)) {
    return res.status(403).send('The shift does not belong to the user\'s factory');
  }
  req.isShiftMember = function() {
    const isMate = req.shift.teammateIds.some(function (mate) {
      return mate.equals(req.user._id);
    });
    return (isMate || (req.shift.leadId.equals(req.user._id)))
  };
  next();
}

/** Middleware for retrieving a specific cableSched's details */
async function cableSchedIdParamCallback (req, res, next, cableSchedId) {
  req.cableSched = await models.CableSched.findById(cableSchedId)
    .populate({ path: 'equipmentId', select: ['_factoryId', 'name', 'location'] }).exec();
  if (!req.cableSched) {
    return res.sendStatus(404);
  }
  if (!req.cableSched.equipmentId._factoryId.equals(req.user.factoryId)) {
    return res.status(403).send('The cableSched does not belong to the user\'s factory');
  }
  next();
}

/** Middleware for retrieving a specific cableSched's details */
async function cableDescIdParamCallback (req, res, next, cableDescId) {
  req.cableDesc = await models.CableDesc.findById(cableDescId)
    .populate({
      path: 'parentSchedId',
      select: ['equipmentId', 'panel'],
      populate: { path: 'equipmentId', select: ['_factoryId', 'name', 'location'] }
    }).exec();
  if (!req.cableDesc) {
    return res.sendStatus(404);
  }
  if (!req.cableDesc.parentSchedId.equipmentId._factoryId.equals(req.user.factoryId)) {
    return res.status(403).send('The cableDesc does not belong to the user\'s factory');
  }
  next();
}

usersRouter.param('userId', userIdParamCallback);

processesRouter.param('processId', processIdParamCallback);

startupPrcdsRouter.param('processId', processIdParamCallback);
startupPrcdsRouter.param('startupId', startupIdParamCallback);

equipmentsRouter.param('processId', processIdParamCallback);
equipmentsRouter.param('equipmentId', equipmentIdParamCallback);

shiftsRouter.param('shiftId', shiftIdParamCallback);

cableSchedsRouter.param('cableSchedId', cableSchedIdParamCallback);

cableDescsRouter.param('cableDescId', cableDescIdParamCallback);

module.exports = apiRouter;