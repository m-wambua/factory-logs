'use strict';
const { Schema } = require('mongoose');
module.exports = (mongoose) => {

  const FactorySchema = new Schema({
    companyName: {
      type: String,
      required: true,
      unique: true
    },
    location: {
      type: String,
      required: true
    },
    processIds: [{
      type: Schema.Types.ObjectId,
      ref: 'Process'
    }]
  }, {
    toJSON: {
      transform: function (doc, ret) {
        ret.id = ret._id;
        delete ret._id;
        delete ret.__v;
        if (doc.populated('processIds')) {
          ret.processes = ret.processIds;
          delete ret.processIds;
        }
      }
    }
  });
  
  return mongoose.model('Factory', FactorySchema);
};
