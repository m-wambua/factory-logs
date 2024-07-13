'use strict';
const { Schema } = require('mongoose');
module.exports = (mongoose) => {
  const CableSchedSchema = new Schema({
    processId: {
      type: String,
      required: true,
      unique: true
    },
    cables: [{
      color: {
        type: String,
        required: true
      },
      purpose: {
        type: String,
        required: true
      },
      equipment1: {
        type: Schema.Types.ObjectId,
        ref: 'Equipment',
        required: true
      },
      phy_label1: {
        type: String,
        required: true
      },
      equipment2: {
        type: Schema.Types.ObjectId,
        ref: 'Equipment',
        required: true
      },
      phy_label2: {
        type: String,
        required: true
      }
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
  
  return mongoose.model('CableShed', CableSchedSchema);
};
