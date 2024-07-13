'use strict';
const { Schema } = require('mongoose');
module.exports = (mongoose) => {
  const ProcessSchema = new Schema({
    name: {
      type: String,
      required: true,
      unique: true
    },
    cable_sched: require('./cable_sched').schema,
    startup: require('./startup_prcd').schema
  }, {
    timestamps: true,
    toJSON: {
      transform: function (doc, ret) {
        ret.id = ret._id;
        delete ret._id;
        delete ret.__v;
      }
    }
  });
  
  return mongoose.model('Process', ProcessSchema);
};
