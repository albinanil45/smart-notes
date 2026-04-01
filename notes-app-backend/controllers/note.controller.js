const Note = require("../models/note.model");

// ✅ Create Note
exports.createNote = async (req, res) => {
    try {
        const { title, content, collectionId, color } = req.body;

        const note = await Note.create({
            userId: req.userId,
            title,
            content,
            collectionId: collectionId || null,
            color: color || "",
            isPinnedGlobal: false,
            isPinnedInCollection: false,
        });

        res.status(201).json(note);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// ✅ Update Note
exports.updateNote = async (req, res) => {
    try {
        const { id } = req.params;

        const note = await Note.findOneAndUpdate(
            { _id: id, userId: req.userId },
            req.body,
            { new: true }
        );

        if (!note) return res.status(404).json({ message: "Note not found" });

        res.json(note);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// ✅ Soft Delete (multiple)
exports.softDeleteNotes = async (req, res) => {
    try {
        const { ids } = req.body;

        await Note.updateMany(
            { _id: { $in: ids }, userId: req.userId },
            {
                isDeleted: true,
                deletedAt: new Date(),
                isPinnedGlobal: false,
                isPinnedInCollection: false,
                isArchived: false,
            }
        );

        res.json({ message: "Notes moved to trash" });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// ✅ Permanent Delete
exports.permanentDeleteNotes = async (req, res) => {
    try {
        const { ids } = req.body;
        const userId = req.userId;

        const notes = await Note.find({
            _id: { $in: ids },
            userId,
            isDeleted: true,
        });

        const deletableIds = notes.map((n) => n._id);

        await Note.deleteMany({
            _id: { $in: deletableIds },
        });

        // 🔥 socket emit
        const io = req.app.get("io");

        deletableIds.forEach((id) => {
            io.to(userId.toString()).emit("noteChanged", {
                type: "permanent_deleted",
                noteId: id,
            });
        });

        res.json({ message: "Notes permanently deleted" });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// ✅ Restore Notes
exports.restoreNotes = async (req, res) => {
    try {
        const { ids } = req.body;

        await Note.updateMany(
            { _id: { $in: ids }, userId: req.userId },
            {
                isDeleted: false,
                deletedAt: null,
            }
        );

        res.json({ message: "Notes restored" });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// ✅ Fetch All Notes (Global View)
exports.getUserNotes = async (req, res) => {
    try {
        const notes = await Note.find({
            userId: req.userId,
        }).sort({
            updatedAt: -1,
        });

        res.json(notes);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// ✅ Toggle Global Pin
exports.toggleGlobalPin = async (req, res) => {
    try {
        const { id } = req.params;

        const note = await Note.findOne({
            _id: id,
            userId: req.userId,
        });

        if (!note) return res.status(404).json({ message: "Note not found" });

        note.isPinnedGlobal = !note.isPinnedGlobal;

        await note.save();

        res.json(note);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// ✅ Toggle Collection Pin
exports.toggleCollectionPin = async (req, res) => {
    try {
        const { id } = req.params;

        const note = await Note.findOne({
            _id: id,
            userId: req.userId,
        });

        if (!note) return res.status(404).json({ message: "Note not found" });

        // ❗ Only allow if note has collection
        if (!note.collectionId) {
            return res.status(400).json({
                message: "Note is not inside a collection",
            });
        }

        note.isPinnedInCollection = !note.isPinnedInCollection;

        await note.save();

        res.json(note);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// ✅ Toggle Archive
exports.toggleArchive = async (req, res) => {
    try {
        const { id } = req.params;

        const note = await Note.findOne({
            _id: id,
            userId: req.userId,
        });

        if (!note) return res.status(404).json({ message: "Note not found" });

        note.isArchived = !note.isArchived;

        // 🔥 Unpin when archived
        if (note.isArchived) {
            note.isPinnedGlobal = false;
            note.isPinnedInCollection = false;
        }

        await note.save();

        res.json(note);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};