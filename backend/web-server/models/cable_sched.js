'use strict';
const { Schema } = require('mongoose');
module.exports = (mongoose) => {
  const CableSchedSchema = new Schema({
    equipmentId: {
      type: Schema.Types.ObjectId,
      ref: 'Equipment',
      required: true
    },
    panel: {
      type: String
    },
    image: {
      type: String
    },
    cableIds: [{
      type: Schema.Types.ObjectId,
      ref: 'CableDesc'
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
        if (doc.populated('cableIds')) {
          ret.cables = ret.cableIds;
          delete ret.cableIds;
        }
      }
    }
  });
  
  return mongoose.model('CableSched', CableSchedSchema);
};
