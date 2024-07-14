'use strict';
const { Schema } = require('mongoose');
module.exports = (mongoose) => {
  const CableDescSchema = new Schema({
    parentSchedId: {
      type: Schema.Types.ObjectId,
      ref: 'CableSched',
      required: true
    },
    authorId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    prevDescId: {
      type: Schema.Types.ObjectId,
      ref: 'CableDesc'
    },
    labelDesc: {
      type: String,
      required: true
    },
    purpose: {
      type: String,
      required: true
    },
    termDescId: {
      type: Schema.Types.ObjectId,
      ref: 'CableDesc'
    }
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
  
  return mongoose.model('CableDesc', CableDescSchema);
};
