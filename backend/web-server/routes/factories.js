'use strict';

/**
 * @swagger
 * components:
 *   schemas:
 *     Factory:
 *       type: object
 *       required:
 *         - id
 *         - companyName
 *         - location
 *       properties:
 *         id:
 *           type: string
 *           description: The unique identifier of the factory
 *         companyName:
 *           type: string
 *           description: The unique CompanyName of the factory
 *         location:
 *           type: string
 *           description: The location where the factory is situated
 *         processIds:
 *           type: array
 *           items:
 *             type: string
 *             description: The unique identifier of a process of the factory
 *       example:
 *         id: 648et52706e53812e7fr5ki8
 *         companyName: Factory0
 *         location: City0
 *         processIds:
 *           - 668ec52476e53805e7fa5cc6
 *           - 657hc41476e54505e9yj5fd2
 * tags:
 *   name: Factories
 *   description: The factories management API
 */

const process = require('process');
const express = require('express');
const { Factory, User } = require('../models');
const { verifySession, hashPassword } = require('../controllers/auth');
const handleErr500 = require('../utils/senderr500');

const factoriesRouter = express.Router();

if (process.env.NODE_ENV !== 'production') {
  /**
   * @swagger
   * /api/factories/all:
   *   get:
   *     summary: Returns a list of all the factories (for debug purposes only)
   *     tags: [Factories]
   *     responses:
   *       200:
   *         description: The list of factories
   *         content:
   *           application/json:
   *             schema:
   *               type: array
   *               items:
   *                 $ref: '#/components/schemas/Factory'
   */
  factoriesRouter.get('/all', async (req, res) => {
    const factories = await Factory.find().sort({ id: -1 }).exec();
    res.json(factories);
  });
}

/** To make sure all routes after this point require a login */
factoriesRouter.use(verifySession);

/**
 * @swagger
 * /api/factories/mine/detail:
 *   get:
 *     summary: Returns the details of the currently logged in user's factory
 *     security:
 *       - BearerAuth: []
 *     tags: [Factories]
 *     responses:
 *       200:
 *         description: The details of the factory of the current user
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Factory'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 */
factoriesRouter.get('/mine/detail', async (req, res) => {
  const factory = await Factory.findById(req.user.factoryId).exec();
  res.json(factory);
});

/**
 * @swagger
 * /api/factories/mine:
 *   get:
 *     summary: Returns shortened details of the currently logged in user's factory
 *     security:
 *       - BearerAuth: []
 *     tags: [Factories]
 *     responses:
 *       200:
 *         description: The shortened details of the factory of the current user
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               required:
 *                 - id
 *                 - companyName
 *               properties:
 *                 id:
 *                   type: string
 *                   description: The unique identifier of the user's factory
 *                 companyName:
 *                   type: string
 *                   description: The unique CompanyName of the user's factory
 *               example:
 *                 id: 648et52706e53812e7fr5ki8
 *                 companyName: Factory0
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 */
factoriesRouter.get('/mine', async (req, res) => {
  const factory = await Factory.findById(req.user.factoryId)
    .select(['id', 'companyName']).exec();
  res.json(factory);
});

/**
 * @swagger
 * /api/factories/users:
 *   get:
 *     summary: Returns list of users of the currently logged in user's factory
 *     security:
 *       - BearerAuth: []
 *     tags: [Factories, Users]
 *     responses:
 *       200:
 *         description: The list of userss of the factory of the current user
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/User'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 */
factoriesRouter.get('/users', async (req, res) => {
  const users = await User.find({ factoryId: req.user.factoryId })
    .sort({ createdId: 1 }).exec();
  res.json(users);
});

/**
 * @swagger
 * /api/factories/admin:
 *   put:
 *     summary: Edits the details the current user's factory (logged in user must be an admin in the factory)
 *     security:
 *       - BearerAuth: []
 *     tags: [Factories]
 *     requestBody:
 *       description: The factory's details that are to be updated
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - oneOf:
 *                 - companyName
 *                 - location
 *             properties:
 *               companyName:
 *                 type: string
 *                 description: The new unique CompanyName of the factory
 *               location:
 *                 type: string
 *                 description: The new location where the factory is situated
 *             example:
 *               companyName: Factory00
 *               location: City00
 *     responses:
 *       200:
 *         description: The factory's details after editting
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Factory'
 *       400:
 *         description: Bad Request. companyName and location not provided. At least one is required.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Fields "companyName" or "location" required for edit'
 *       500:
 *         description: Server Error. Could not update the user details.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error updating factory details: ...'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 */
factoriesRouter.put('/admin', async (req, res) => {
  if (req.user.role !== 'Admin') {
    return res.status(403);
  }
  const { companyName, location } = req.body;
  if (!companyName && !location) {
    return res.status(400)
      .send('Fields "companyName" or "location" required for edit');
  }
  const factory = await Factory.findById(req.user.factoryId).exec();
  if (companyName) {
    factory.companyName = companyName;
  }
  if (location) {
    factory.location = location;
  }
  try {
    await factory.save();
    res.json(factory);
  } catch (err) {
    return handleErr500(res, err, 'Error updating factory details');
  }
});

module.exports = factoriesRouter;
