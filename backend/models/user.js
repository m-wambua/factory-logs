'use strict';
const { Schema } = require('mongoose');
module.exports = (mongoose) => {
  const UserSchema = new Schema({
    userName: {
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
        delete ret.hashedPassword;
        delete ret.refreshToken;
        delete ret.__v;
      }
    }
  });
  
  return mongoose.model('User', UserSchema);
};
