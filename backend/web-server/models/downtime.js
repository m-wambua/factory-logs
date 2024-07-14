'use strict';
const { Schema } = require('mongoose');
module.exports = (mongoose) => {
  const DowntimeSchema = new Schema({
    equipmentId: {
      type: Schema.Types.ObjectId,
      ref: 'Equipment',
      required: true
    },
    shiftId: {
      type: Schema.Types.ObjectId,
      ref: 'Shift',
      required: true
    },
    type: {
      type: String,
      enum: {
        values: ['Failure', 'Maintenance'],
        message: 'Downtime type {VALUE} is not supported'
      },
      required: true
    },
    start: [{
      type: Schema.Types.Date,
      required: true
    }],
    end: [{
      type: Schema.Types.Date,
      required: true
    }],
    remark: {
      type: String,
      required: true
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
  
  return mongoose.model('Downtime', DowntimeSchema);
};
