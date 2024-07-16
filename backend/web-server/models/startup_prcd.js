'use strict';
const { Schema } = require('mongoose');
module.exports = (mongoose) => {
  const StartupPrcdSchema = new Schema({
    authorId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    prevPrcdId: {
      type: Schema.Types.ObjectId,
      ref: 'StartupPrcd'
    },
    changeLog: {
      type: String,
    },
    steps: {
      type: [{
        type: String
      }],
      validate: [(val) => (val.length > 0), 'Startup Procedure must include at least one step']
    },
  }, {
    timestamps: true,
    toJSON: {
      transform: function (doc, ret) {
        ret.id = ret._id;
        delete ret._id;
        delete ret.__v;
        if (doc.populated('authorId')) {
          ret.author = ret.authorId;
          delete ret.authorId;
        }
        if (doc.populated('prevPrcdId')) {
          ret.prevPrcd = ret.prevPrcdId;
          delete ret.prevPrcdId;
        }
      }
    }
  });
  
  return mongoose.model('StartupPrcd', StartupPrcdSchema);
};
