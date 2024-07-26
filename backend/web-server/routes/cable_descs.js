'use strict';

/**
 * @swagger
 * components:
 *   schemas:
 *     CableDesc:
 *       type: object
 *       required:
 *         - id
 *         - author
 *         - equipment
 *         - labelDets
 *         - purpose
 *         - termDesc
 *       properties:
 *         id:
 *           type: string
 *           description: The unique-identifier of the cable descriptor
 *         author:
 *           type: object
 *           description: The details of the user who published the startup proecdure
 *           properties:
 *             id:
 *               type: string
 *               description: The identifier of the author
 *             username:
 *               type: string
 *               description: The username of the author
 *         equipment:
 *           type: object
 *           description: The details of the equipment that the cable belongs
 *           properties:
 *             id:
 *               type: string
 *               description: The unique-identifier of the equipment
 *             name:
 *               type: string
 *               description: The name of the equipment
 *             cableShedId:
 *               type: string
 *               description: The unique-identifier of the cable schedule
 *             panel:
 *               type: string
 *               description: The panel of the equipment
 *         labelDets:
 *           type: string
 *           description: The visual/label details of the cable
 *         purpose:
 *           type: string
 *           description: The link to the image of the panel
 *         changeLogs:
 *           type: array
 *           items:
 *             type: string
 *             description: A description of any change made to the descriptor
 *         termDesc:
 *           type: object
 *           description: The details of the cable descriptor the cable terminates into
 *           properties:
 *             id:
 *               type: string
 *               description: The unique-identifier of the cable descriptor
 *             labelDets:
 *               type: string
 *               description: The visual/label details of the cable
 *             equipment:
 *               type: object
 *               description: The details of the equipment that the termination cable belongs
 *               properties:
 *                 id:
 *                   type: string
 *                   description: The unique-identifier of the equipment
 *                 name:
 *                   type: string
 *                   description: The name of the equipment
 *                 cableShedId:
 *                   type: string
 *                   description: The unique-identifier of the cable schedule
 *                 panel:
 *                   type: string
 *                   description: The panel of the equipment
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
 *         author:
 *           id: 65324h3kj3545565n23hu870
 *           username: Fct0.Oprt0
 *         equipment:
 *           id: 6778f8whfj5894bbhr883bb3
 *           name: F0P0.Eqpt0
 *           cableSchedId: 6952f262ca26dfee9648
 *           panel: Rear left panel
 *         labelDets: Red cable, first from the right
 *         purpose: Motor control +
 *         termDesc:
 *           id: 67532ed4ac990bc099da5234
 *           labelDets: Red cable, first from the right
 *           equipment:
 *             id: 67fj5878f8w2ca26dfee9648
 *             name: F0P0.Eqpt1
 *             cableSchedId: 6952f26h94bbhr883bb3
 *             panel: Only panel
 *         createdAt: 2024-07-10T17:30:12.015Z
 *         updatedAt: 2024-07-10T17:30:12.015Z
 *     SchedCableDesc:
 *       type: object
 *       required:
 *         - id
 *         - labelDets
 *         - purpose
 *         - termDesc
 *       properties:
 *         id:
 *           type: string
 *           description: The unique-identifier of the cable descriptor
 *         labelDets:
 *           type: string
 *           description: The visual/label details of the cable
 *         purpose:
 *           type: string
 *           description: The link to the image of the panel
 *         changeLogs:
 *           type: array
 *           items:
 *             type: string
 *             description: A description of any change made to the descriptor
 *         termDesc:
 *           type: object
 *           description: The details of the cable descriptor the cable terminates into
 *           properties:
 *             id:
 *               type: string
 *               description: The unique-identifier of the cable descriptor
 *             labelDets:
 *               type: string
 *               description: The visual/label details of the cable
 *             equipment:
 *               type: object
 *               description: The details of the equipment that the termination cable belongs
 *               properties:
 *                 id:
 *                   type: string
 *                   description: The unique-identifier of the equipment
 *                 name:
 *                   type: string
 *                   description: The name of the equipment
 *                 cableShedId:
 *                   type: string
 *                   description: The unique-identifier of the cable schedule
 *                 panel:
 *                   type: string
 *                   description: The panel of the equipment
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
 *         labelDets: Red cable, first from the right
 *         purpose: Motor control +
 *         termDesc:
 *           id: 67532ed4ac990bc099da5234
 *           labelDets: Red cable, first from the right
 *           equipment:
 *             id: 67fj5878f8w2ca26dfee9648
 *             name: F0P0.Eqpt1
 *             cableSchedId: 6952f26h94bbhr883bb3
 *             panel: Only panel
 *         createdAt: 2024-07-10T17:30:12.015Z
 *         updatedAt: 2024-07-10T17:30:12.015Z
 *     CableDescCreateInfo:
 *       type: object
 *       required:
 *         - labelDets
 *         - purpose
 *       properties:
 *         labelDets:
 *           type: string
 *           description: The visual/label details of the cable
 *         purpose:
 *           type: string
 *           description: The link to the image of the panel
 *       example:
 *         labelDets: Red cable, first from the right
 *         purpose: Motor control +
 *     CableDescEditInfo:
 *       type: object
 *       required:
 *         - oneOf:
 *           - labelDets
 *           - purpose
 *           - unlink
 *       properties:
 *         labelDets:
 *           type: string
 *           description: The visual/label details of the cable
 *         purpose:
 *           type: string
 *           description: The link to the image of the panel
 *         unlink:
 *           type: boolean
 *           description: Added to unlink the terminating cable descriptor
 *         changeLog:
 *           type: string
 *           description: An optional description of the change being made
 *       example:
 *         labelDets: Red cable, first from the right
 *         purpose: Motor control +
 * tags:
 *   name: CableDescs
 *   description: The cable descriptors management API
 */

const express = require('express');
const { CableDesc, CableSched } = require('../models');
const { verifySession } = require('../controllers/auth');
const handleErr500 = require('../utils/senderr500');

const schedCableDescsRouter = express.Router();

/** Function to check whether a provided descriptor label detail is already taken for a given schedule */
async function cableDescLabelTaken(schedule, labelDets) {
  const takenDets = schedule.cableIds.map((desc) => desc.labelDets);
  return takenDets.includes(labelDets);
}

/** To make sure all routes after this point require a login */
schedCableDescsRouter.use(verifySession);

/**
 * @swagger
 * /api/cablescheds/{cableSchedId}/cabledescs:
 *   get:
 *     summary: Retrieves the cable descriptors of a given cable schedule
 *     security:
 *       - BearerAuth: []
 *     tags: [CableDescs, CableScheds]
 *     parameters:
 *       - in: path
 *         name: cableSchedId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the schedule whose cable descriptors are required
 *     responses:
 *       200:
 *         description: The list of the cable schedule's cable descriptors
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/SchedCableDesc'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *       404:
 *         description: Not Found. The cable schedule does not exist
 */
schedCableDescsRouter.get('/', async (req, res) => {
  await req.cableSched.populate({
    path: 'cableIds',
    select: ['-parentSchedId', '-authorId'],
    populate: {
      path: 'termDescId',
      select: ['labelDets', 'parentSchedId'],
      populate: {
        path: 'parentSchedId',
        select: ['panel', 'equipmentId'],
        populate: { path: 'equipmentId' , select: 'name' }
      }
    }
  });
  const descsDets = req.cableSched.cableIds.map((cable) => cable.toJSON());
  const descsRet = descsDets.map((descDets) => {
    return {
      ...descDets,
      termDesc: (!descDets.termDesc) ? undefined : {
        id: descDets.termDesc.id,
        labelDets: descDets.termDesc.labelDets,
        equipment: {
          ...descDets.termDesc.parentSched.equipment,
          cableSchedId: descDets.termDesc.parentSched.id,
          panel: descDets.termDesc.parentSched.panel,
        },
      }
    };
  });
  return res.json(descsRet);
});

/**
 * @swagger
 * /api/cablescheds/{cableSchedId}/cabledescs:
 *   post:
 *     summary: Adds a new cable descriptor to a given cable schedule
 *     security:
 *       - BearerAuth: []
 *     tags: [CableDescs, CableScheds]
 *     parameters:
 *       - in: path
 *         name: cableSchedId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the schedule to which the cable descriptor belongs
 *     requestBody:
 *       description: The details of the new cable schedule
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *               $ref: '#/components/schemas/CableDescCreateInfo'
 *     responses:
 *       201:
 *         description: Successfully created the cable schedule
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: string
 *                   description: Unique identifier of the created cable descriptor
 *               example:
 *                 id: 67fj5878f8w2ca26dfee9648
 *       400:
 *         description: Bad Request. labelDets and purpose not provided.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Field "labelDets" is missing in the body'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *       404:
 *         description: The cable schedule does not exist or does not belong to the current user's factory
 *       500:
 *         description: Server Error. Could not create the cable descriptor.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error creating cable descriptor: ...'
 */
schedCableDescsRouter.post('/', async (req, res) => {
  for (const required of ["labelDets", "purpose"]) {
    if (!req.body[required]) {
      return res.status(400)
        .send(`Field "${required}" is missing in the body`);
    }
  }
  const { labelDets, purpose } = req.body;
  await req.cableSched.populate({ path: 'cableIds', select: ['labelDets'] });
  if (await cableDescLabelTaken(req.cableSched, labelDets)) {
    return res.status(400)
      .send('Provided labelDets already exists for the given schedule');
  }
  try {
    const session = await req.app.db.startSession();
    const desc = await session.withTransaction(async (session) => {
      const descs = await CableDesc.create([{
        parentSchedId: req.cableSched._id,
        authorId: req.user._id,
        labelDets, purpose
      }], { session });
      req.cableSched.cableIds.push(descs[0]._id);
      await req.cableSched.save({ session });
      return descs[0];
    });
    return res.status(201).send({ id: desc._id });
  } catch (err) {
    return handleErr500(res, err, 'Error creating cable descriptor');
  }
});

const cableDescsRouter = express.Router();

/** To make sure all routes after this point require a login */
cableDescsRouter.use(verifySession);

/**
 * @swagger
 * /api/cabledescs/link:
 *   put:
 *     summary: Links two cable descriptors (each terminating in the other)
 *     security:
 *       - BearerAuth: []
 *     tags: [CableDescs]
 *     requestBody:
 *       description: The new details of the cable descriptor
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *               type: object
 *               required:
 *                 - firstDescId
 *                 - secondDescId
 *               properties:
 *                 firstDescId:
 *                   type: string
 *                   description: The unique-identifier of the first cable descriptor
 *                 secondDescId:
 *                   type: string
 *                   description: The unique-identifier of the second cable descriptor
 *                 changeLog:
 *                   type: string
 *                   description: A description of the link update being made (Not needed for first link)
 *               example:
 *                 firstDescId: 6778f8whfj5894bbhr883bb3
 *                 secondDescId: 6478gd98789d57587h2s9fm6
 *                 changeLog: Correction
 *     responses:
 *       200:
 *         description: The cable descriptors have been linked successfully
 *       400:
 *         description: Bad Request. firstDescId or secondDescId not provided.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Two cable descriptors should be provided ("firstDescId" and "secondDescId")'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *       404:
 *         description: At least one of the cable descriptors does not exist
 *       406:
 *         description: At least one of the cable descriptors is already linked (should be unlinked first)
 *       500:
 *         description: Server Error. Could not link the cable descriptors.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error linking cable descriptors: ...'
 */
cableDescsRouter.put('/link', async (req, res) => {
  const { firstDescId, secondDescId, changeLog } = req.body;
  if ((!firstDescId) || (!secondDescId)) {
    return res.status(400)
      .send('Two cable descriptors should be provided ("firstDescId" and "secondDescId")');
  }
  try {
    const firstDesc = await CableDesc.findById(firstDescId)
      .select(['termDescId', 'changeLogs']).exec();
    if (!firstDesc) {
      return res.status(400).send('First descriptor does not exist');
    }
    const secondDesc = await CableDesc.findById(secondDescId)
      .select(['termDescId', 'changeLogs']).exec();
    if (!secondDesc) {
      return res.status(400).send('Second descriptor does not exist');
    }
    if ((firstDesc.termDescId) || (secondDesc.termDescId)) {
      return res.status(406).send('Both descriptors should be unlinked before linking');
    }
    if ((firstDesc.changeLogs.length) || (secondDesc.changeLogs.length)) {
      if (!changeLog) {
        return res.status(400)
          .send('A changeLog is required for descriptors that have been edited before');
      }
      let changeLogSave = `${(new Date).toISOString()}: ${req.user.username}(${req.user._id}) edited:`;
      firstDesc.changeLogs.push(`${changeLogSave}\n - linked to ${secondDescId}\n ++ ${changeLog}`);
      secondDesc.changeLogs.push(`${changeLogSave}\n - linked to ${firstDescId}\n ++ ${changeLog}`);
    }
    firstDesc.termDescId = secondDescId;
    secondDesc.termDescId = firstDescId;
    const session = await req.app.db.startSession();
    await session.withTransaction(async (session) => {
      await firstDesc.save({ session });
      await secondDesc.save({ session });
    });
    return res.sendStatus(200);
  } catch (err) {
    return handleErr500(res, err, 'Error linking cable descriptors');
  }
});

/**
 * @swagger
 * /api/cabledescs/{cableDescId}:
 *   put:
 *     summary: Edits the details of a cable descriptor
 *     security:
 *       - BearerAuth: []
 *     tags: [CableDescs]
 *     parameters:
 *       - in: path
 *         name: cableDescId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the cable descriptor to be edited
 *     requestBody:
 *       description: The new details of the cable descriptor
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *               $ref: '#/components/schemas/CableDescEditInfo'
 *     responses:
 *       200:
 *         description: The cable descriptor has been edited successfully
 *       400:
 *         description: Bad Request. labelDets, purpose and unlink not provided. At least one is required.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'No supported field has been provided for edit'
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 *       404:
 *         description: The cable descriptor does not exist
 *       500:
 *         description: Server Error. Could not edit the cable descriptor.
 *         content:
 *           text/plain; charset=utf-8:
 *             example: 'Error updating cable descriptor: ...'
 */
cableDescsRouter.put('/:cableDescId', async (req, res) => {
  const { labelDets, purpose, unlink, changeLog } = req.body;
  if ((!labelDets) && (!purpose) && (!unlink)) {
    return res.status(400)
      .send('No supported field has been provided for edit');
  }
  try {
    let changeLogSave = `${(new Date).toISOString()}: ${req.user.username}(${req.user._id}) edited:`;
    if (unlink) {
      if ((labelDets) || (purpose) || (!changeLog)) {
        return res.status(400)
          .send('The unlink option requires a changeLog and must not be accompanied by the other options');
      }
      if (!req.cableDesc.termDescId) {
        return res.sendStatus(204);
      }
      const termDesc = await CableDesc.findById(req.cableDesc.termDescId)
        .select(['termDescId', 'changeLogs']).exec();
      termDesc.changeLogs.push(`${changeLogSave}\n - unlinked from ${termDesc.termDescId}\n ++ ${changeLog}`);
      termDesc.termDescId = undefined;
      req.cableDesc.changeLogs.push(`${changeLogSave}\n - unlinked from ${req.cableDesc.termDescId}\n ++ ${changeLog}`);
      req.cableDesc.termDescId = undefined;
      const session = await req.app.db.startSession();
      await session.withTransaction(async (session) => {
        await termDesc.save({ session });
        await req.cableDesc.save({ session });
      });
      return res.sendStatus(200);
    }
    if (labelDets) {
      const schedDets = await CableSched.findById(req.cableDesc.parentSchedId._id)
        .select('cableIds').populate({ path: 'cableIds', select: ['labelDets'] }).exec();
      if (await cableDescLabelTaken(schedDets, labelDets)) {
        return res.status(400)
          .send('Provided label is already taken for its parent schedule');
      }
      changeLogSave = `${changeLogSave}\n - labelDets from "${req.cableDesc.labelDets}"`;
      req.cableDesc.labelDets = labelDets;
    }
    if (purpose) {
      changeLogSave = `${changeLogSave}\n - purpose from "${req.cableDesc.purpose}"`;
      req.cableDesc.purpose = purpose;
    }
    if (changeLog) {
      changeLogSave = `${changeLogSave}\n ++ ${changeLog}`;
      req.cableDesc.changeLogs.push(changeLogSave);
    }
    await req.cableDesc.save();
    return res.sendStatus(200);
  } catch (err) {
    return handleErr500(res, err, 'Error updating cable descriptor');
  }
});

/**
 * @swagger
 * /api/cabledescs/{cableDescId}:
 *   get:
 *     summary: Retrieves the details of a cable descriptor given its id
 *     security:
 *       - BearerAuth: []
 *     tags: [CableDescs]
 *     parameters:
 *       - in: path
 *         name: cableDescId
 *         schema:
 *           type: string
 *         required: true
 *         description: the unique identifier of the cable descriptor whose details are being requested
 *     responses:
 *       200:
 *         description: The details of the requested cable descriptor
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/CableDesc'
 *       404:
 *         description: The cable descriptor does not exist
 *       401:
 *         $ref: '#/components/responses/Unauthorised'
 *       403:
 *         $ref: '#/components/responses/Forbidden'
 */
cableDescsRouter.get('/:cableDescId', async (req, res) => {
  await req.cableDesc.populate([
    {
      path: 'termDescId',
      select: ['labelDets', 'parentSchedId'],
      populate: {
        path: 'parentSchedId',
        select: ['panel', 'equipmentId'],
        populate: { path: 'equipmentId' , select: 'name' }
      }
    },
    {
      path: 'authorId',
      select: ['username'],
    }
  ]);
  const descDets = req.cableDesc.toJSON();
  const descRet = {
    ...descDets,
    equipment: {
      ...descDets.parentSched.equipment,
      cableSchedId: descDets.parentSched.id,
      panel: descDets.parentSched.panel,
    },
    termDesc: (!descDets.termDesc) ? undefined : {
      id: descDets.termDesc.id,
      labelDets: descDets.termDesc.labelDets,
      equipment: {
        ...descDets.termDesc.parentSched.equipment,
        cableSchedId: descDets.termDesc.parentSched.id,
        panel: descDets.termDesc.parentSched.panel,
      },
    },
    parentSched: undefined
  };
  return res.json(descRet);
});

module.exports = { schedCableDescsRouter, cableDescsRouter };
