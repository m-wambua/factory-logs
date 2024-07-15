'use strict';
const { Schema } = require('mongoose');
module.exports = (mongoose) => {
  const MeasurableSchema = new Schema({
    equipmentId: {
      type: Schema.Types.ObjectId,
      ref: 'Equipment',
      required: true
    },
    quantity: {
      type: String,
      required: true
    },
    unit: {
      type: String,
      required: true
    },
    shiftIds: [{
      type: Schema.Types.ObjectId,
      ref: 'Shift'
    }],
  }, {
    timestamps: true,
    toJSON: {
      transform: function (doc, ret) {
        ret.id = ret._id;
        delete ret._id;
        delete ret.__v;
        if (doc.populated('equipmentId')) {
          ret.equipment = ret.equipmentId;
          delete ret.equipmentId;
        }
        if (doc.populated('shiftIds')) {
          ret.shifts = ret.shiftIds;
          delete ret.shiftIds;
        }
      }
    }
  });
  
  return mongoose.model('Measurable', MeasurableSchema);
};
