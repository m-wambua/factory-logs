'use strict';
const { Schema } = require('mongoose');
module.exports = (mongoose) => {
  const StartupPrcdSchema = new Schema({
    processId: {
      type: String,
      required: true,
      unique: true
    },
    steps: [{
      number: {
        type: number,
        required: true
      },
      procedure: {
        type: String,
        required: true
      },
    }],
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
  
  return mongoose.model('StartupPrcd', StartupPrcdSchema);
};
