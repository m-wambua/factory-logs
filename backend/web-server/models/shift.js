'use strict';
const { Schema } = require('mongoose');
module.exports = (mongoose) => {
  const LogSchema = new Schema({
    measurableId: {
      type: Schema.Types.ObjectId,
      ref: 'Measurable',
      required: true
    },
    time: {
      type: Schema.Types.Date,
      required: true
    },
    value: {
      type: Number,
      required: true
    },
    remark: {
      type: String
    }
  }, {
    _id : false,
    toJSON: {
      transform: function (doc, ret) {
        delete ret.__v;
        if (doc.populated('measurableId')) {
          ret.measurable = ret.measurableId;
          delete ret.measurableId;
        }
      }
    }
  });

  const ShiftSchema = new Schema({
    _factoryId: {
      type: Schema.Types.ObjectId,
      ref: 'Factory',
      required: true
    },
    leadId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    teammateIds: [{
      type: Schema.Types.ObjectId,
      ref: 'User'
    }],
    type: {
      type: String,
      enum: {
        values: ['Morning', 'Afternoon', 'Evening', 'Night', 'Supervisory'],
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
    logs: [LogSchema],
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
        delete ret._factoryId;
        if (doc.populated('leadId')) {
          ret.lead = ret.leadId;
          delete ret.leadId;
        }
        if (doc.populated('teammateIds')) {
          ret.teammates = ret.teammateIds;
          delete ret.teammateIds;
        }
        if (doc.populated('downtimeIds')) {
          ret.downtimes = ret.downtimeIds;
          delete ret.downtimeIds;
        }
      }
    }
  });
  
  return mongoose.model('Shift', ShiftSchema);
};
