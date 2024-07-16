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
const { User, Factory, Process, StartupPrcd } = require('../models');

const apiRouter = express.Router();

/* Attaching the different routes */
const authRouter = require('./auth');
const usersRouter = require('./users');
const factoriesRouter = require('./factories');
const processesRouter = require('./processes');
const startupPrcdsRouter = require('./startup_prcds');

apiRouter.use('/auth', authRouter);
apiRouter.use('/users', usersRouter);
apiRouter.use('/factories', factoriesRouter);
apiRouter.use('/processes', processesRouter);
apiRouter.use('/startup', startupPrcdsRouter);

/** Middleware for retrieving a specific user's details for
 *  admin purposes */
async function userIdParamCallback (req, res, next, userId) {
  if (req.user.role !== 'Admin') {
    return res.status(403).send('Only admins may access a specific user\'s details');
  }
  req.subjUser = await User.findById(userId).exec();
  if ((!req.subjUser) || (req.subjUser.factoryId !== req.user.factoryId)) {
    return res.sendStatus(404);
  }
  next();
}

/** Middleware for retrieving a specific process's details */
async function processIdParamCallback (req, res, next, processId) {
  req.factory = await Factory.findById(req.user.factoryId).exec();
  if ((!req.factory) || (!req.factory.processIds.includes(processId))) {
    return res.status(404).send('User does not have a factory, or no process by the given id is linked to the factory');
  }
  req.process = await Process.findById(processId).exec();
  if (!req.process) {
    return res.sendStatus(404);
  }
  next();
}

/** Middleware for retrieving a specific startup procedure's details */
async function startupIdParamCallback (req, res, next, startupId) {
  req.startupPrcd = await StartupPrcd.findById(startupId)
    .populate({ path: 'authorId', select: ['_id', 'userName'] }).exec();
  if (!req.startupPrcd) {
    return res.sendStatus(404);
  }
  const author = await User.findById(req.startupPrcd.authorId._id)
    .select('factoryId').exec();
  if ((!author) || (req.user.factoryId.toString() !== author.factoryId.toString())) {
    return res.status(403).send('The startup procedure does not belong to the user\'s factory');
  }
  next();
}

usersRouter.param('userId', userIdParamCallback);

processesRouter.param('processId', processIdParamCallback);

startupPrcdsRouter.param('processId', processIdParamCallback);
startupPrcdsRouter.param('startupId', startupIdParamCallback);

module.exports = apiRouter;