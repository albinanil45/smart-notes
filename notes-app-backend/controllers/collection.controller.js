const Collection = require("../models/collection.model");
const Note = require("../models/note.model");


// ✅ Create Collection
exports.createCollection = async (req, res) => {
    try {
        const { name, color } = req.body;

        const collection = await Collection.create({
            userId: req.userId,
            name,
            color: color || "",
        });

        res.status(201).json(collection);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};


// ✅ Update Collection
exports.updateCollection = async (req, res) => {
    try {
        const { id } = req.params;

        const collection = await Collection.findOneAndUpdate(
            { _id: id, userId: req.userId },
            req.body,
            { new: true }
        );

        if (!collection)
            return res.status(404).json({ message: "Collection not found" });

        res.json(collection);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};


// ✅ Get all collections
exports.getUserCollections = async (req, res) => {
    try {
        const collections = await Collection.find({
            userId: req.userId,
        }).sort({ createdAt: -1 });

        res.json(collections);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};


// ✅ Permanent Delete Collection (NO soft delete)
exports.deleteCollection = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.userId;

        const collection = await Collection.findOne({
            _id: id,
            userId,
        });

        if (!collection)
            return res.status(404).json({ message: "Collection not found" });

        // 🔥 get notes before update (for socket emit)
        const notes = await Note.find({
            collectionId: id,
            userId,
        });

        const noteIds = notes.map((n) => n._id);

        // ✅ remove collectionId from notes (NOT deleting)
        await Note.updateMany(
            { collectionId: id, userId },
            { collectionId: null }
        );

        // ✅ delete collection
        await Collection.deleteOne({ _id: id });

        res.json({ message: "Collection deleted and notes unlinked" });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};