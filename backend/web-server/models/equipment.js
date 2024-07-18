'use strict';
const { Schema } = require('mongoose');
module.exports = (mongoose) => {
  const LocationSchema = new Schema({
    description: {
      type: String,
      required: true
    },
    image: {
      type: String
    }
  }, { _id: false });

  const ManualSchema = new Schema({
    name: {
      type: String,
      required: true
    },
    file: {
      type: String,
      required: true
    }
  }, { _id: false });

  const CodebaseSchema = new Schema({
    name: {
      type: String,
      required: true
    },
    date: {
      type: Schema.Types.Date,
      required: true
    },
    files: {
      type: [{
        type: String
      }],
      validate: [(val) => (val.length > 0), 'Codebase must include at least one file']
    }
  }, { _id: false });

  const EquipmentSchema = new Schema({
    _factoryId: {
      type: Schema.Types.ObjectId,
      ref: 'Factory',
      required: true
    },
    name: {
      type: String,
      required: true
    },
    type: {
      type: String,
      required: true
    },
    manufacturer: {
      type: String,
      required: true
    },
    serialNum: {
      type: String,
      required: true,
      unique: true
    },
    rating: {
      type: String
    },
    decommissioned: {
      type: Schema.Types.Boolean,
      default: false,
      required: true
    },
    location: {
      type: LocationSchema,
      required: true
    },
    manuals: [ManualSchema],
    measurableIds: [{
      type: Schema.Types.ObjectId,
      ref: 'Measurable'
    }],
    downtimeIds: [{
      type: Schema.Types.ObjectId,
      ref: 'Downtime'
    }],
    codebases: [CodebaseSchema],
    cableSchedIds: [{
      type: Schema.Types.ObjectId,
      ref: 'CableSched'
    }]
  }, {
    timestamps: true,
    toJSON: {
      transform: function (doc, ret) {
        ret.id = ret._id;
        delete ret._id;
        delete ret.__v;
        delete ret._factoryId;
        if (doc.populated('measurableIds')) {
          ret.measurables = ret.measurableIds;
          delete ret.measurableIds;
        }
        if (doc.populated('downtimeIds')) {
          ret.downtimes = ret.downtimeIds;
          delete ret.downtimeIds;
        }
        if (doc.populated('cableSchedIds')) {
          ret.cableScheds = ret.cableSchedIds;
          delete ret.cableSchedIds;
        }
      }
    }
  });
  
  return mongoose.model('Equipment', EquipmentSchema);
};
