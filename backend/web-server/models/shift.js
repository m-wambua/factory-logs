'use strict';
const { Schema } = require('mongoose');
module.exports = (mongoose) => {
  const ShiftSchema = new Schema({
    leadId: {
      type: Schema.Types.ObjectId,
      ref: 'User'
    },
    teammateIds: [{
      type: Schema.Types.ObjectId,
      ref: 'User'
    }],
    type: {
      type: String,
      enum: {
        values: ['A', 'B', 'C', 'G'],
        message: 'Shift type {VALUE} is not supported'
      },
      required: true
    },
    date: [{
      type: Schema.Types.Date,
      required: true
    }],
    start: [{
      type: Schema.Types.Date,
      required: true
    }],
    end: [{
      type: Schema.Types.Date,
      required: true
    }],
    ODSs: [{
      type: String,
      required: true
    }],
    logs: [{
      measurableId: {
        type: Schema.Types.ObjectId,
        ref: 'Measurable'
      },
      time: {
        type: Schema.Types.Date,
        required: true
      },
      value: {
        type: number,
        required: true
      }
    }],
    downtimeIds: [{
      type: Schema.Types.ObjectId,
      ref: 'Downtime'
    }]
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
  
  return mongoose.model('Shift', ShiftSchema);
};
