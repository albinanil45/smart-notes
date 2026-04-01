const express = require("express");
const router = express.Router();

const collectionController = require("../controllers/collection.controller");
const authMiddleware = require("../middlewares/auth.middleware");

// 🔐 Protect all routes
router.use(authMiddleware);

// ✅ Create collection
router.post("/", collectionController.createCollection);

// ✅ Get all collections of user
router.get("/", collectionController.getUserCollections);

// ✅ Update collection
router.put("/:id", collectionController.updateCollection);

// ✅ Delete collection (permanent + unlink notes)
router.delete("/:id", collectionController.deleteCollection);

module.exports = router;