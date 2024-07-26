'use strict';

/**
 * @swagger
 * components:
 *   securitySchemes:
 *     BearerAuth:
 *       type: oauth2
 *       flows:
 *         password:
 *           tokenUrl: /api/auth/login
 *   responses:
 *     Unauthorised:
 *       description: Unauthorised. The user is currently not logged in
 *     Forbidden:
 *       description: Forbidden. Wrong authorization details provided
 * tags:
 *   name: Auth
 *   description: The authentication management API
 */

const express = require('express');
const auth = require('../controllers/auth');

const authRouter = express.Router();

function verifyLoginDetails (req, res, next) {
  for (const required of ["username", "password"]) {
    if (!req.body[required]) {
      return res.status(400)
        .send(`Field "${required}" is missing in the body`);
    }
  }
  next();
}

function verifyRefreshDetails (req, res, next) {
  const cookies = req.cookies;
  if (!cookies?.jwt) {
    return res.status(401).send('No token provided');
  }
  req.refreshToken = cookies.jwt;
  next();
}

async function verifyLogoutDetails (req, res, next) {
  const cookies = req.cookies;
  if (!cookies?.jwt) {
    return res.status(204).send('No token provided. May already be logged out.');
  }
  req.refreshToken = cookies.jwt;
  next();
}

function verifyNewUserDetails (req, res, next) {
  for (const required of ["username", "role", "password"]) {
    if (!req.body[required]) {
      return res.status(400)
        .send(`Field "${required}" is missing in the body`);
    }
  }
  next();
}

/**
 * @swagger
 * /api/auth/login:
 *   post:
 *     summary: Logs in a user into the system returning an authentication token
 *     tags:
 *       - Auth
 *     requestBody:
 *       description: The credentials of the user
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - username
 *               - password
 *             properties:
 *               username:
 *                 type: string
 *                 description: The User Name of the user
 *               password:
 *                 type: string
 *                 description: The password of the user
 *             example:
 *               username: Fct0.Admn0
 *               password: password0A0
 *     responses:
 *       200:
 *         description: The user has been successfully logged in
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               required:
 *                 - accessToken
 *             properties:
 *               accessToken:
 *                 type: string
 *                 description: The token to be used as the Bearer token for successive requests
 *             example:
 *               accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI5MzNmOWM0Mi1hOWNhLTRiN2QtOTk1NC1iOTJlNmNmM2QxNmYiLCJpYXQiOjE3MDg4NzE2MjEsImV4cCI6MTcwODg3MjIyMX0.lLr7PfN5dZloel2uG_uaucBwvNJeghxb86ddFABOC_0'
 *       400:
 *         description: Bad Request. username or password not provided.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Field "username" is missing in the body'
 *       401:
 *         description: Unauthorised. Provided credentials (username or password) are not correct.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Provided credentials are incorrect'
 *       500:
 *         description: Server Error. Could not login the user.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Authentication Error occured: ...'
 */
authRouter.post('/login', verifyLoginDetails, auth.handleLogin);

/**
 * @swagger
 * /api/auth/refresh:
 *   get:
 *     summary: Refreshes the authentication token of a logged in user
 *     tags:
 *       - Auth
 *     parameters:
 *       - in: cookie
 *         name: jwt
 *         schema:
 *           type: string
 *         required: true
 *         description: The refresh token for the user's login session
 *     responses:
 *       200:
 *         description: The user session has been successfully refreshed
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               required:
 *                 - access_token
 *             properties:
 *               accessToken:
 *                 type: string
 *                 description: The token to be used as the Bearer token for successive requests
 *             example:
 *               access_token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI5MzNmOWM0Mi1hOWNhLTRiN2QtOTk1NC1iOTJlNmNmM2QxNmYiLCJpYXQiOjE3MDg4NzE2MjEsImV4cCI6MTcwODg3MjIyMX0.lLr7PfN5dZloel2uG_uaucBwvNJeghxb86ddFABOC_0'
 *       401:
 *         description: Unauthorised. No refresh token has been provided.
 *       403:
 *         description: Forbidden. The refresh token provided is invalid.
 */
authRouter.get('/refresh', verifyRefreshDetails, auth.handleRefresh);

/**
 * @swagger
 * /api/auth/logout:
 *   get:
 *     summary: Logs out and deletes a user's session
 *     tags:
 *       - Auth
 *     parameters:
 *       - in: cookie
 *         name: jwt
 *         schema:
 *           type: string
 *         required: true
 *         description: The refresh token for the user's login session
 *     responses:
 *       200:
 *         description: The user session has been successfully logged out.
 *       204:
 *         description: The request's session has been cleared but the refreshToken may still persist in the server.
 *       500:
 *         description: Server Error. The request's session has been cleared but deletion of the server-side token failed.
 */
authRouter.get('/logout', verifyLogoutDetails, auth.handleLogout);

/** To make sure all routes after this point require a login */
authRouter.use(auth.verifySession);

/**
 * @swagger
 * /api/auth/newuser:
 *   post:
 *     summary: Creates a new user in the system for the factory of the logged in admin
 *     security:
 *       - BearerAuth: []
 *     tags:
 *       - Auth
 *       - Users
 *     requestBody:
 *       description: The details of the new user
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - username
 *               - role
 *               - password
 *             properties:
 *               username:
 *                 type: string
 *                 description: The unique User Name to be saved for the new user
 *               role:
 *                 type: string
 *                 description: The role the new user has in the factory. Acceptable options are ['Admin', 'Operator', 'Technician']
 *               password:
 *                 type: string
 *                 description: The password to be saved for the new user
 *             example:
 *               username: Fct0.Tech0
 *               role: Technician
 *               password: password0T0
 *     responses:
 *       201:
 *         description: The user has been successfully created
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/User'
 *       400:
 *         description: Bad Request. username or role or password not provided.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'username is missing in the body'
 *       500:
 *         description: Server Error. Could not register the new user.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error creating user: ...'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 */
authRouter.post('/newuser', verifyNewUserDetails, auth.handleAddUser);

module.exports = authRouter;
