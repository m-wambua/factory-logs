'use strict';

/**
 * @swagger
 * components:
 *   schemas:
 *     Manual:
 *       type: object
 *       required:
 *         - name
 *         - file
 *       properties:
 *         name:
 *           type: string
 *           description: Equipment-unique descriptive name of the manual
 *         file:
 *           type: string
 *           description: Link to the resource containing the uploaded file
 *       example:
 *         name: User Guide
 *         file: fct0.eqpt0/man/technical_user_guide.pdf
 */

const express = require('express');
const { Equipment } = require('../models');
const { verifySession } = require('../controllers/auth');
const handleErr500 = require('../utils/senderr500');

const eqptManualsRouter = express.Router();

/** Function to check whether a provided manual name is already taken for a given equipment */
async function manualNameTaken(equipment, name) {
  const takenNames = equipment.manuals.map((man) => man.name);
  return takenNames.includes(name);
}

/** To make sure all routes after this point require a login */
eqptManualsRouter.use(verifySession);

/**
 * @swagger
 * /api/equipments/{equipmentId}/manuals:
 *   get:
 *     summary: Returns a list of the manuals that the equipment has 
 *     security:
 *       - BearerAuth: []
 *     tags: [Equipments]
 *     parameters:
 *       - in: path
 *         name: equipmentId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the equipment to which the manuals belong
 *     responses:
 *       200:
 *         description: The list of the requested measurable logs
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Manual'
 *       404:
 *         description: The equipment does not exist
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 */
eqptManualsRouter.get('/', async (req, res) => {
  const eqpt = await Equipment.findById(req.equipment._id).select('manuals').exec();
  return res.json(eqpt.manuals);
});

/**
 * @swagger
 * /api/equipments/{equipmentId}/manuals:
 *   delete:
 *     summary: Removes a manual (Admins and operators only)
 *     security:
 *       - BearerAuth: []
 *     tags: [Equipments]
 *     parameters:
 *       - in: path
 *         name: equipmentId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the equipment whose manual is to be deleted
 *     requestBody:
 *       description: The details of the manual to be deleted
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
 *                 description: The equipment-unique name of the manual to be deleted
 *             example:
 *               name: User Guide
 *     responses:
 *       204:
 *         description: The manual has been deleted successfully
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
 *         description: Not Found. The equipment or manual does not exist
 *       500:
 *         description: Server Error. Could not delete the manual.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error deleting manual: ...'
 */
eqptManualsRouter.delete('/', async (req, res) => {
  if (!['Admin', 'Operator'].includes(req.user?.role)) {
    return res.status(403).send('Only admins and operators can delete manuals');
  }
  const { name } = req.body;
  if (!name) {
    return res.status(400)
      .send('Field "name" is missing in the body');
  }
  let manualIndex;
  const eqpt = await Equipment.findById(req.equipment._id).select('manuals').exec();
  const foundManual = eqpt.manuals.find((val, index) => {
    manualIndex = index;
    return val.name === name;
  });
  if (!foundManual) {
    return res.sendStatus(404);
  }
  try {
    eqpt.manuals.splice(manualIndex, 1);
    await eqpt.save();
    return res.sendStatus(204);
  } catch (err) {
    return handleErr500(res, err, 'Error deleting manual');
  }
});

/**
 * @swagger
 * /api/equipments/{equipmentId}/manuals:
 *   post:
 *     summary: Adds a new manual to a given equipment (only admins & operators)
 *     security:
 *       - BearerAuth: []
 *     tags: [Equipments]
 *     parameters:
 *       - in: path
 *         name: equipmentId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the equipment to which the manual is to belong
 *     requestBody:
 *       description: The details of the new manual
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *               $ref: '#/components/schemas/Manual'
 *     responses:
 *       201:
 *         description: Successfully added the manual
 *       400:
 *         description: Bad Request. name or file not provided.
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
 *         description: Server Error. Could not create the manual.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error creating manual: ...'
 */
eqptManualsRouter.post('/', async (req, res) => {
  if (!['Admin', 'Operator'].includes(req.user?.role)) {
    return res.status(403).send('Only admins and operators can add manuals');
  }
  for (const required of ["name", "file"]) {
    if (!req.body[required]) {
      return res.status(400)
        .send(`Field "${required}" is missing in the body`);
    }
  }
  const eqpt = await Equipment.findById(req.equipment._id).select('manuals').exec();
  const { name, file} = req.body;
  if (await manualNameTaken(eqpt, name)) {
    return res.status(400)
      .send('Provided manual name already exists for the given equipment');
  }
  try {
    const session = await req.app.db.startSession();
    await session.withTransaction(async (session) => {
      eqpt.manuals.push({
        name, file
      });
      await eqpt.save({ session });
    });
    return res.sendStatus(201);
  } catch (err) {
    return handleErr500(res, err, 'Error creating manual');
  }
});

module.exports = eqptManualsRouter;
