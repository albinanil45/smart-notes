const express = require("express");
const router = express.Router();

const noteController = require("../controllers/note.controller");
const authMiddleware = require("../middlewares/auth.middleware");

// 🔐 All routes are protected
router.use(authMiddleware);

// ✅ Create
router.post("/", noteController.createNote);

// ✅ Get all notes (global view)
router.get("/", noteController.getUserNotes);

// ✅ Update note
router.put("/:id", noteController.updateNote);

// ✅ Toggle global pin
router.patch("/:id/pin-global", noteController.toggleGlobalPin);

// ✅ Toggle collection pin
router.patch("/:id/pin-collection", noteController.toggleCollectionPin);

// ✅ Toggle archive
router.patch("/:id/archive", noteController.toggleArchive);

// ✅ Soft delete (multiple)
router.patch("/delete", noteController.softDeleteNotes);

// ✅ Restore (multiple)
router.patch("/restore", noteController.restoreNotes);

// ✅ Permanent delete (multiple)
router.delete("/permanent", noteController.permanentDeleteNotes);

module.exports = router;