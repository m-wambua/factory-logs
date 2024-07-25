'use strict';

/**
 * @swagger
 * components:
 *   schemas:
 *     CableSched:
 *       type: object
 *       required:
 *         - id
 *         - equipment
 *         - panel
 *         - cables
 *       properties:
 *         id:
 *           type: string
 *           description: The unique-identifier of the cable schedule
 *         equipment:
 *           type: object
 *           description: The details of the equipment that the schedule belongs
 *           properties:
 *             id:
 *               type: string
 *               description: The unique-identifier of the equipment
 *             name:
 *               type: string
 *               description: The name of the equipment
 *         panel:
 *           type: string
 *           description: The equipment-unique panel that the schedule corresponds to
 *         image:
 *           type: string
 *           description: The link to the image of the panel
 *         cables:
 *           type: array
 *           description: A list of the cable descriptors in the schedule
 *           items:
 *             type: object
 *             properties:
 *               id: 
 *                 type: string
 *                 description: The unique-identifier of a cable descriptor
 *               labelDets: 
 *                 type: string
 *                 description: The visual/label details of a cable
 *         createdAt:
 *           type: string
 *           format: date-time
 *           description: The time the cable schedule was added to the system
 *         updatedAt:
 *           type: string
 *           format: date-time
 *           description: The last time the cable schedule details were edited
 *       example:
 *         id: 657f89fafj5894abadd99bc4
 *         equipment:
 *           id: 6778f8whfj5894bbhr883bb3
 *           name: F0P0.Eqpt0
 *         panel: Rear left panel
 *         image: '/Factory0/F0P0.Eqpt0_rear_panel.jpg'
 *         cableIds:
 *           - 6778f8whfj94abadd99bc47
 *           - 612efd88675cb903ee891aa
 *         createdAt: 2024-07-10T17:30:12.015Z
 *         updatedAt: 2024-07-10T17:30:12.015Z
 *     EquipmentCableSched:
 *       type: object
 *       required:
 *         - id
 *         - panel
 *       properties:
 *         id:
 *           type: string
 *           description: The unique-identifier of the cable schedule
 *         panel:
 *           type: string
 *           description: The equipment-unique panel that the schedule corresponds to
 *         image:
 *           type: string
 *           description: The link to the image of the panel
 *         createdAt:
 *           type: string
 *           format: date-time
 *           description: The time the cable schedule was added to the system
 *         updatedAt:
 *           type: string
 *           format: date-time
 *           description: The last time the cable schedule details were edited
 *       example:
 *         id: 657f89fafj5894abadd99bc4
 *         panel: Rear left panel
 *         image: '/Factory0/F0P0.Eqpt0_rear_panel.jpg'
 *         createdAt: 2024-07-10T17:30:12.015Z
 *         updatedAt: 2024-07-10T17:30:12.015Z
 *     CableSchedCreateInfo:
 *       type: object
 *       required:
 *         - panel
 *       properties:
 *         panel:
 *           type: string
 *           description: The equipment-unique panel that the schedule corresponds to
 *         image:
 *           type: string
 *           description: The link to the image of the panel
 *       example:
 *         panel: Rear left panel
 *         image: '/Factory0/F0P0.Eqpt0_rear_panel.jpg'
 * tags:
 *   name: CableScheds
 *   description: The cable schedules management API
 */

const express = require('express');
const { CableSched, Equipment } = require('../models');
const { verifySession } = require('../controllers/auth');
const handleErr500 = require('../utils/senderr500');

const eqptCableSchedsRouter = express.Router();

/** Function to check whether a provided schedule panel name is already taken for a given equipment */
async function cableSchedPanelTaken(equipment, panel) {
  const takenNames = equipment.cableSchedIds.map((sched) => sched.panel);
  return takenNames.includes(panel);
}

/** To make sure all routes after this point require a login */
eqptCableSchedsRouter.use(verifySession);

/**
 * @swagger
 * /api/equipments/{equipmentId}/cablescheds:
 *   get:
 *     summary: Retrieves the cable schedules of a given equipment
 *     security:
 *       - BearerAuth: []
 *     tags: [CableScheds, Equipments]
 *     parameters:
 *       - in: path
 *         name: equipmentId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the equipment whose cable schedules are required
 *     responses:
 *       200:
 *         description: The list of the equipment's cable schedules
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/EquipmentCableSched'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *       404:
 *         description: Not Found. The equipment does not exist
 */
eqptCableSchedsRouter.get('/', async (req, res) => {
  const eqpt = await Equipment.findById(req.equipment._id).select('cableSchedIds')
    .populate({ path: 'cableSchedIds', select: ['-cableIds', '-equipmentIds'] }).exec();
  return res.json(eqpt.cableSchedIds);
});

/**
 * @swagger
 * /api/equipments/{equipmentId}/cablescheds:
 *   post:
 *     summary: Adds a new cable schedule to a given equipment (only admins & operators)
 *     security:
 *       - BearerAuth: []
 *     tags: [CableSched, Equipments]
 *     parameters:
 *       - in: path
 *         name: equipmentId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the equipment to which the schedule is to belong
 *     requestBody:
 *       description: The details of the new cable schedule
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *               $ref: '#/components/schemas/CableSchedCreateInfo'
 *     responses:
 *       201:
 *         description: Successfully created the cable schedule
 *       400:
 *         description: Bad Request. panel not provided.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Field "panel" is missing in the body'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *       404:
 *         description: The equipment does not exist or does not belong to the current user's factory
 *       500:
 *         description: Server Error. Could not create the cable schedule.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error creating cable schedule: ...'
 */
eqptCableSchedsRouter.post('/', async (req, res) => {
  if (!['Admin', 'Operator'].includes(req.user?.role)) {
    return res.status(403).send('Only admins and operators can add cable schedules');
  }
  if (!req.body['panel']) {
    return res.status(400)
      .send(`Field "panel" is missing in the body`);
  }
  const { panel, image } = req.body;
  const eqptDets = await Equipment.findById(req.equipment._id).select('cableSchedIds')
    .populate({ path: 'cableSchedIds', select: ['panel'] }).exec();
  if (await cableSchedPanelTaken(eqptDets, panel)) {
    return res.status(400)
      .send('Provided panel already exists for the given equipment');
  }
  try {
    const session = await req.app.db.startSession();
    await session.withTransaction(async (session) => {
      const scheds = await CableSched.create([{
        equipmentId: req.equipment._id, panel, image
      }], { session });
      eqptDets.cableSchedIds.push(scheds[0]._id);
      await eqptDets.save({ session });
    });
    return res.sendStatus(201);
  } catch (err) {
    return handleErr500(res, err, 'Error creating cable schedule');
  }
});

const cableSchedsRouter = express.Router();

/** To make sure all routes after this point require a login */
cableSchedsRouter.use(verifySession);

/* Attaching the different cable schedule routes */
const { schedCableDescsRouter } = require('./cable_descs');

cableSchedsRouter.use('/:cableSchedId/cabledescs', schedCableDescsRouter);

/**
 * @swagger
 * /api/cablescheds/{cableSchedId}:
 *   get:
 *     summary: Retrieves the details of a cable schedule given its id
 *     security:
 *       - BearerAuth: []
 *     tags: [CableScheds]
 *     parameters:
 *       - in: path
 *         name: cableSchedId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the cable schedule whose details are being requested
 *     responses:
 *       200:
 *         description: The details of the requested cable schedule
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/CableSched'
 *       404:
 *         description: The cable schedule does not exist
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 */
cableSchedsRouter.get('/:cableSchedId', async (req, res) => {
  await req.cableSched
    .populate({ path: 'cableIds', select: ['labelDets'] }).exec();
  return res.json(req.cableSched);
});

module.exports = { eqptCableSchedsRouter, cableSchedsRouter };
