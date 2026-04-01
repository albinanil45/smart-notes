const mongoose = require("mongoose");

const otpSchema = new mongoose.Schema({
    email: {
        type: String,
        required: true,
        unique: true, // one OTP per email
        index: true,
    },

    otp: {
        type: String,
        required: true,
    },

    attempts: {
        type: Number,
        default: 0,
    },

    expiresAt: {
        type: Date,
        required: true,
    },

    resendAfter: {
        type: Date,
        required: true,
    },

}, {
    timestamps: true
});

// TTL index (auto delete after expiry)
otpSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

module.exports = mongoose.model("Otp", otpSchema);