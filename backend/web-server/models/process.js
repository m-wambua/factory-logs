'use strict';
const { Schema } = require('mongoose');
module.exports = (mongoose) => {
  const ProcessSchema = new Schema({
    _factoryId: {
      type: Schema.Types.ObjectId,
      ref: 'Factory',
      required: true
    },
    name: {
      type: String,
      required: true,
      unique: true
    },
    startupId: {
      type: Schema.Types.ObjectId,
      ref: 'StartupPrcd'
    },
    equipmentIds: [{
      type: Schema.Types.ObjectId,
      ref: 'Equipment'
    }]
  }, {
    timestamps: true,
    toJSON: {
      transform: function (doc, ret) {
        ret.id = ret._id;
        delete ret._id;
        delete ret.__v;
        delete ret._factoryId;
        if (doc.populated('startupId')) {
          ret.startup = ret.startupId;
          delete ret.startupId;
        }
        if (doc.populated('equipmentIds')) {
          ret.equipments = ret.equipmentIds;
          delete ret.equipmentIds;
        }
      }
    }
  });
  
  return mongoose.model('Process', ProcessSchema);
};
