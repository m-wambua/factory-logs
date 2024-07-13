'use strict';

const process = require('process');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { User } = require('../models');
const handleErr500 = require('../utils/senderr500');

const REFRESH_TOKEN_LIFESPAN =
  (process.env.NODE_ENV === 'production') ? '3d' : '100d';
const JWT_COOKIE_AGE_DAYS =
  (process.env.NODE_ENV === 'production') ? 3 : 100;
const ACCESS_TOKEN_LIFESPAN =
  (process.env.NODE_ENV === 'production') ? 600 : '10d';

/** To login a user */
async function handleLogin (req, res) {
  const { userName, password } = req.body;
  const user = await User.findOne({ userName })
    .select('_id hashedPassword refreshToken')
    .exec();
  if (!user) {
    return res.status(401)
      .send('Provided credentials are incorrect');
  }
  try {
    const correctPass = await bcrypt.compare(password, user.hashedPassword);
    if (!correctPass) {
      return res.status(401)
        .send('Provided credentials are incorrect');
    }
    const accessToken = jwt.sign(
      { userId: user._id },
      process.env.ACCESS_TOKEN_SECRET,
      { expiresIn: ACCESS_TOKEN_LIFESPAN }
    );
    /* To avoid logging out the user on other devices */
    let cookieAge = 0;
    if (user.refreshToken) {
      jwt.verify(
        user.refreshToken,
        process.env.REFRESH_TOKEN_SECRET,
        (err, tokenData) => {
          if (!err && (tokenData.userId === user._id)) {
            cookieAge = (tokenData.exp * 1000) - Date.now();
          }
        }
      );
    }
    if (cookieAge < 1800000/* 30 min */) {
      const refreshToken = jwt.sign(
        { userId: user._id },
        process.env.REFRESH_TOKEN_SECRET,
        { expiresIn: REFRESH_TOKEN_LIFESPAN }
      );
      user.refreshToken = refreshToken;
      cookieAge = JWT_COOKIE_AGE_DAYS * 24 * 60 * 60 * 1000;
    }
    await user.save();
    res.cookie('jwt', user.refreshToken, {
      httpOnly: true,
      sameSite: 'none',
      secure: true,
      maxAge: cookieAge
    });
    return res.json({ accessToken });
  } catch (err) {
    return res.status(500)
      .send(`Authentication Error occured: ${err}`);
  }
}

/** To refresh a user access token */
async function handleRefresh (req, res) {
  const user = await User.findOne({ refreshToken: req.refreshToken })
    .select('_id').exec();
  if (!user) {
    return res.sendStatus(403);
  }

  jwt.verify(
    req.refreshToken,
    process.env.REFRESH_TOKEN_SECRET,
    (err, tokenData) => {
      if (err || (tokenData.userId !== user._id)) {
        return res.sendStatus(403);
      }
      const accessToken = jwt.sign(
        { userId: user._id },
        process.env.ACCESS_TOKEN_SECRET,
        { expiresIn: ACCESS_TOKEN_LIFESPAN }
      );
      return res.json({ accessToken });
    }
  );
}

/** To logout a user */
async function handleLogout (req, res) {
  res.clearCookie('jwt', {
    httpOnly: true,
    sameSite: 'none',
    secure: true,
    maxAge: 3 * 24 * 60 * 60 * 1000
  });
  const user = await User.findOne({ refreshToken: req.refreshToken })
    .select('_id').exec();
  if (!user) {
    return res.sendStatus(204);
  }
  user.refreshToken = null;
  try {
    await user.save();
    return res.sendStatus(200);
  } catch (err) {
    return res.status(500);
  }
}

async function verifySession (req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.sendStatus(401);
  }
  /* Auth header is expected to be a bearer token in the format: "Bearer <token>" */
  const token = authHeader.split(' ')[1];
  jwt.verify(
    token,
    process.env.ACCESS_TOKEN_SECRET,
    async (err, tokenData) => {
      if (err) {
        return res.sendStatus(403);
      }
      req.user = await User.findOne({ _id: tokenData.userId });
      if (!req.user?.refreshToken) {
        return res.sendStatus(403);
      }
      next();
    }
  );
}

async function getLoggedInDetails (req) {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return;
  }
  /* Auth header is expected to be a bearer token in the format: "Bearer <token>" */
  const token = authHeader.split(' ')[1];
  const tokenData = jwt.verify(
    token,
    process.env.ACCESS_TOKEN_SECRET
  );
  req.user = await User.findOne({ _id: tokenData.userId });
}

async function hashPassword (password) {
  return await bcrypt.hash(password, 10);
}

/* To add a new user */
async function handleAddUser (req, res) {
  if (req.user?.role !== 'Admin') {
    return res.status(403).send('Only admins can add new users');
  }
  const { userName, role, password } = req.body;
  try {
    const hashedPassword = await hashPassword(password);
    const user = await User.create({
      userName, role, hashedPassword, factoryId: req.user.factoryId
    });
    return res.status(201).json(user);
  } catch (err) {
    return handleErr500(res, err, 'Error creating user');
  }
}

module.exports = {
  handleLogin, handleRefresh, handleLogout,
  verifySession, getLoggedInDetails,
  hashPassword, handleAddUser };
