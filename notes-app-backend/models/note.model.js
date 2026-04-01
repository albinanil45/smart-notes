const mongoose = require("mongoose");

const noteSchema = new mongoose.Schema(
    {
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
            index: true,
        },

        collectionId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Collection",
            default: null,
        },

        title: {
            type: String,
            default: "",
            trim: true,
        },

        content: {
            type: String,
            default: "",
        },

        // 📌 Global pin (top in all notes)
        isPinnedGlobal: {
            type: Boolean,
            default: false,
            index: true,
        },

        // 📌 Collection pin (top inside collection)
        isPinnedInCollection: {
            type: Boolean,
            default: false,
            index: true,
        },

        // 📦 Archive
        isArchived: {
            type: Boolean,
            default: false,
            index: true,
        },

        // 🗑️ Soft delete
        isDeleted: {
            type: Boolean,
            default: false,
            index: true,
        },

        deletedAt: {
            type: Date,
            default: null,
            index: true,
        },

        // 🎨 UI color
        color: {
            type: String,
            default: "",
        },
    },
    {
        timestamps: true,
    }
);

// 🧹 TTL index → auto delete after 30 days
noteSchema.index(
    { deletedAt: 1 },
    {
        expireAfterSeconds: 60 * 60 * 24 * 30,
    }
);

module.exports = mongoose.model("Note", noteSchema);