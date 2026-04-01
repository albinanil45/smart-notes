require("dotenv").config();

const express = require("express");
const cors = require("cors");

const connectDB = require("./config/db");

const authRoutes = require("./routes/auth.routes");
const noteRoutes = require("./routes/note.routes");
const collectionRoutes = require("./routes/collection.routes"); // ✅ NEW

const app = express();

// Connect DB
connectDB();

// Middlewares
app.use(cors());
app.use(express.json());

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/notes", noteRoutes);
app.use("/api/collections", collectionRoutes); // ✅ NEW

// Test Route
app.get("/", (req, res) => {
    res.send("API Running");
});

// Server
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});