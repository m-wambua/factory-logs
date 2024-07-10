'use strict';

/**
 * @swagger
 * components:
 *   schemas:
 *     User:
 *       type: object
 *       required:
 *         - id
 *         - userName
 *         - role
 *         - factoryId
 *       properties:
 *         id:
 *           type: string
 *           description: The unique identifier of the user
 *         userName:
 *           type: string
 *           description: The unique UserName of the user
 *         role:
 *           type: string
 *           description: The role the user has in the factory. Acceptable options are ['Admin', 'Operator', 'Technician']
 *         factoryId:
 *           type: string
 *           description: The unique identifier that the user belongs to
 *         createdAt:
 *           type: string
 *           format: date-time
 *           description: The time the user was added to the system
 *         updatedAt:
 *           type: string
 *           format: date-time
 *           description: The last time the user details were edited
 *       example:
 *         id: 668ec52476e53805e7fa5cc6
 *         userName: Fct0.Admn0
 *         role: Admin
 *         factoryId: 668ec52476e53805e7fa5cc1
 *         createdAt: 2024-07-10T17:30:12.515Z
 *         updatedAt: 2024-07-10T17:30:12.515Z
 * tags:
 *   name: Users
 *   description: The users management API
 */

const process = require('process');
const express = require('express');
const { User } = require('../models');
const { verifySession, hashPassword } = require('../controllers/auth');
const handleErr500 = require('../utils/senderr500');

const usersRouter = express.Router();

if (process.env.NODE_ENV !== 'production') {
  /**
   * @swagger
   * /api/users/all:
   *   get:
   *     summary: Returns a list of all the users (for debug purposes only)
   *     tags: [Users]
   *     responses:
   *       200:
   *         description: The list of users
   *         content:
   *           application/json:
   *             schema:
   *               type: array
   *               items:
   *                 $ref: '#/components/schemas/User'
   */
  usersRouter.get('/all', async (req, res) => {
    const users = await User.find().sort({ createdAt: -1 }).exec();
    res.json(users);
  });
}

/** To make sure all routes after this point require a login */
usersRouter.use(verifySession);

/**
 * @swagger
 * /api/users/me:
 *   get:
 *     summary: Returns the details of the currently logged in user
 *     security:
 *       - BearerAuth: []
 *     tags: [Users]
 *     responses:
 *       200:
 *         description: The current user's details
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/User'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 */
usersRouter.get('/me', (req, res) => {
  res.json(req.user);
});

/**
 * @swagger
 * /api/users/{userId}:
 *   put:
 *     summary: Edits the details of a specific user (logged in user must be an admin in the user's factory)
 *     security:
 *       - BearerAuth: []
 *     tags: [Users]
 *     parameters:
 *       - in: path
 *         name: userId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the user to be edited
 *     requestBody:
 *       description: The user's details that are to be updated
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - oneOf:
 *                 - userName
 *                 - role
 *                 - password
 *             properties:
 *               userName:
 *                 type: string
 *                 description: The new userName to be saved for the user
 *               role:
 *                 type: string
 *                 description: The new role to be saved for the user. Acceptable options are ['Admin', 'Operator', 'Technician']
 *               password:
 *                 type: string
 *                 description: The new password to be saved for the user
 *             example:
 *               userName: Fct0.Oprt0
 *               role: Operator
 *               password: password0P0
 *     responses:
 *       200:
 *         description: The user's details after editting
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/User'
 *       400:
 *         description: Bad Request. userName and role and password not provided. At least one is required.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Fields "userName" or "role" or "password" required for edit'
 *       406:
 *         description: Method Not Allowed. To prevent admin-less factories, Admins cannot edit their role.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'An admin cannot edit their own role'
 *       500:
 *         description: Server Error. Could not update the user details.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error updating user details: SequelizeValidationError: ...'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *   delete:
 *     summary: Deletes a specific user from the system
 *     security:
 *       - BearerAuth: []
 *     tags: [Users]
 *     responses:
 *       200:
 *         description: The user has been deleted
 *       406:
 *         description: Method Not Allowed. To prevent admin-less factories, Admins cannot delete themselves.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'An admin cannot delete their own account'
 *       500:
 *         description: Server Error. Could not delete the user.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error deleting user: ...'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 */
usersRouter.route('/:userId')
  /* To update a specific user's details */
  .put(async (req, res) => {
    const { userName, role, password } = req.body;
    if (!userName && !role && !password) {
      return res.status(400)
        .send('Fields "userName" or "role" or "password" required for edit');
    }
    if (userName) {
      req.subjUser.userName = userName;
    }
    if (role) {
      if ((req.subjUser._id === req.user._id) && (role !== 'Admin')) {
        return res.status(406).send('An admin cannot edit their own role');
      }
      req.subjUser.role = role;
    }
    if (password) {
      req.subjUser.hashPassword = await hashPassword(password);
    }
    try {
      await req.subjUser.save();
      res.json(req.subjUser);
    } catch (err) {
      return handleErr500(res, err, 'Error updating user details');
    }
  })
  /* To delete a specific user */
  .delete(async (req, res) => {
    if (req.subjUser._id === req.user._id) {
      return res.status(406).send('An admin cannot delete their own account');
    }
    try {
      await req.subjUser.deleteOne();
      res.sendStatus(204);
    } catch (err) {
      return handleErr500(res, err, 'Error deleting user');
    }
  });

module.exports = usersRouter;
