const mongoose = require("mongoose");

const collectionSchema = new mongoose.Schema(
    {
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
            index: true,
        },

        name: {
            type: String,
            required: true,
            trim: true,
        },

        color: {
            type: String,
            default: "",
        },
    },
    {
        timestamps: true,
    }
);

// ✅ Optional: prevent duplicate collection names per user
collectionSchema.index(
    { userId: 1, name: 1 },
    { unique: true }
);

module.exports = mongoose.model("Collection", collectionSchema);