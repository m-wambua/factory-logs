'use strict';
const { Schema } = require('mongoose');
module.exports = (mongoose) => {
  const ProcessSchema = new Schema({
    name: {
      type: String,
      required: true,
      unique: true
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
    processes: [ProcessSchema]
  }, {
    toJSON: {
      transform: function (doc, ret) {
        ret.id = ret._id;
        delete ret._id;
        delete ret.__v;
      }
    }
  });
  
  return mongoose.model('Factory', FactorySchema);
};
