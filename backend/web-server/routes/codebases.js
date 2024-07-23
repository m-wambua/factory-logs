'use strict';

/**
 * @swagger
 * components:
 *   schemas:
 *     Codebase:
 *       type: object
 *       required:
 *         - name
 *         - date
 *         - files
 *       properties:
 *         name:
 *           type: string
 *           description: Equipment-unique descriptive name of the codebase
 *         date:
 *           type: string
 *           format: date-time
 *           description: timestamp of the codebase deployment
 *         files:
 *           type: array
 *           items:
 *             type: string
 *             description: Link to the resource containing an uploaded file of the codebase
 *       example:
 *         name: Main PLC ladder logic
 *         date: 2024-07-10T17:30:12.015Z
 *         files:
 *           - fct0.eqpt0/code/main_plc_code.zip
 */

const express = require('express');
const { Equipment } = require('../models');
const { verifySession } = require('../controllers/auth');
const handleErr500 = require('../utils/senderr500');

const eqptCodebasesRouter = express.Router();

/** Function to check whether a provided codebase name is already taken for a given equipment */
async function codebaseNameTaken(equipment, name) {
  const takenNames = equipment.codebases.map((code) => code.name);
  return takenNames.includes(name);
}

/** To make sure all routes after this point require a login */
eqptCodebasesRouter.use(verifySession);

/**
 * @swagger
 * /api/equipments/{equipmentId}/codebases:
 *   get:
 *     summary: Returns a list of the codebases that the equipment has 
 *     security:
 *       - BearerAuth: []
 *     tags: [Equipments]
 *     parameters:
 *       - in: path
 *         name: equipmentId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the equipment to which the codebases belong
 *     responses:
 *       200:
 *         description: The list of the requested measurable logs
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Codebase'
 *       404:
 *         description: The equipment does not exist
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 */
eqptCodebasesRouter.get('/', async (req, res) => {
  const eqpt = await Equipment.findById(req.equipment._id).select('codebases').exec();
  return res.json(eqpt.codebases);
});

/**
 * @swagger
 * /api/equipments/{equipmentId}/codebases:
 *   delete:
 *     summary: Removes a codebase (Admins and operators only)
 *     security:
 *       - BearerAuth: []
 *     tags: [Equipments]
 *     parameters:
 *       - in: path
 *         name: equipmentId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the equipment whose codebase is to be deleted
 *     requestBody:
 *       description: The details of the codebase to be deleted
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
 *                 description: The equipment-unique name of the codebase to be deleted
 *             example:
 *               name: Main PLC ladder logic
 *     responses:
 *       204:
 *         description: The codebase has been deleted successfully
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
 *         description: Not Found. The equipment or codebase does not exist
 *       500:
 *         description: Server Error. Could not delete the codebase.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error deleting codebase: ...'
 */
eqptCodebasesRouter.delete('/', async (req, res) => {
  if (!['Admin', 'Operator'].includes(req.user?.role)) {
    return res.status(403).send('Only admins and operators can delete codebases');
  }
  const { name } = req.body;
  if (!name) {
    return res.status(400)
      .send('Field "name" is missing in the body');
  }
  let codebaseIndex;
  const eqpt = await Equipment.findById(req.equipment._id).select('codebases').exec();
  const foundCodebase = eqpt.codebases.find((val, index) => {
    codebaseIndex = index;
    return val.name === name;
  });
  if (!foundCodebase) {
    return res.sendStatus(404);
  }
  try {
    eqpt.codebases.splice(codebaseIndex, 1);
    await eqpt.save();
    return res.sendStatus(204);
  } catch (err) {
    return handleErr500(res, err, 'Error deleting codebase');
  }
});

/**
 * @swagger
 * /api/equipments/{equipmentId}/codebases:
 *   post:
 *     summary: Adds a new codebase to a given equipment (only admins & operators)
 *     security:
 *       - BearerAuth: []
 *     tags: [Equipments]
 *     parameters:
 *       - in: path
 *         name: equipmentId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the equipment to which the codebase is to belong
 *     requestBody:
 *       description: The details of the new codebase
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *               $ref: '#/components/schemas/Codebase'
 *     responses:
 *       201:
 *         description: Successfully added the codebase
 *       400:
 *         description: Bad Request. name or files not provided, or files is not an array, or date is invalid.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Field "name" is missing in the body'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *       404:
 *         description: The equipment does not exist or does not belong to the current user's factory
 *       500:
 *         description: Server Error. Could not create the codebase.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error creating codebase: ...'
 */
eqptCodebasesRouter.post('/', async (req, res) => {
  if (!['Admin', 'Operator'].includes(req.user?.role)) {
    return res.status(403).send('Only admins and operators can add codebases');
  }
  for (const required of ["name", "files"]) {
    if (!req.body[required]) {
      return res.status(400)
        .send(`Field "${required}" is missing in the body`);
    }
  }
  const { name, date, files} = req.body;
  if (!Array.isArray(files)) {
    return res.status(400)
      .send('Field "files" is not an array');
  }
  if ((date) && (isNaN(Date.parse(date)))) {
    return res.status(400)
      .send('Field "date" is not a valid date entry');
  }
  const eqpt = await Equipment.findById(req.equipment._id).select('codebases').exec();
  if (await codebaseNameTaken(eqpt, name)) {
    return res.status(400)
      .send('Provided codebase name already exists for the given equipment');
  }
  try {
    const session = await req.app.db.startSession();
    await session.withTransaction(async (session) => {
      eqpt.codebases.push({
        name,
        date: date ?? (new Date()),
        files: [...files]
      });
      await eqpt.save({ session });
    });
    return res.sendStatus(201);
  } catch (err) {
    return handleErr500(res, err, 'Error creating codebase');
  }
});

module.exports = eqptCodebasesRouter;
