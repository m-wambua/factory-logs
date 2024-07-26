'use strict';
const { Schema } = require('mongoose');
module.exports = (mongoose) => {
  const UserSchema = new Schema({
    username: {
      type: String,
      required: true,
      unique: true
    },
    role: {
      type: String,
      enum: {
        values: ['Admin', 'Operator', 'Technician'],
        message: 'User role {VALUE} is not supported'
      },
      required: true
    },
    hashedPassword: {
      type: String,
      required: true
    },
    refreshToken: {
      type: String
    },
    factoryId: {
      type: Schema.Types.ObjectId,
      ref: 'Factory',
      required: true
    }
  }, {
    timestamps: true,
    toJSON: {
      transform: function (doc, ret) {
        ret.id = ret._id;
        delete ret._id;
        delete ret.hashedPassword;
        delete ret.refreshToken;
        delete ret.__v;
        if (doc.populated('factoryId')) {
          ret.factory = ret.factoryId;
          delete ret.factoryId;
        }
      }
    }
  });
  
  return mongoose.model('User', UserSchema);
};
