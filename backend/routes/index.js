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

const apiRouter = express.Router();

/* Attaching the different routes */
const authRouter = require('./auth');

apiRouter.use('/auth', authRouter);

module.exports = apiRouter