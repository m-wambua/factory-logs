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
    changeLog: {
      type: String
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
        if (doc.populated('parentSchedId')) {
          ret.parentSched = ret.parentSchedId;
          delete ret.parentSchedId;
        }
        if (doc.populated('prevDescId')) {
          ret.prevDesc = ret.prevDescId;
          delete ret.prevDescId;
        }
        if (doc.populated('authorId')) {
          ret.author = ret.authorId;
          delete ret.authorId;
        }
        if (doc.populated('termDescId')) {
          ret.termDesc = ret.termDescId;
          delete ret.termDescId;
        }
      }
    }
  });
  
  return mongoose.model('CableDesc', CableDescSchema);
};
