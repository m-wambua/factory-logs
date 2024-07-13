'use strict';

/** This function handles internal server errors and returns
 * a meaningful message to the user
 */
function handleErr500 (res, err, leadMsg) {
  const retErr = (err.name.startsWith('Sequelize')) ? err.errors[0].message : err;
  return res.status(500)
    .send(`${leadMsg}: ${retErr}`);
}

module.exports = handleErr500;
