const express = require("express");
const dotenv = require("dotenv");
const cors = require("cors");
const bodyParser = require("body-parser");
const connectDB = require("./config/feed-db");

dotenv.config();
const app = express();

app.use(cors());
app.use(bodyParser.json());

// ✅ Connect to MongoDB
connectDB();

// ✅ Middleware (Request Logger)
const authMiddleware = require("./middleware/authMiddleware");
app.use(authMiddleware);

// ✅ Import & Use Routes
const feedRoutes = require("./routes/feed-page-routes");
app.use("/api/feed", feedRoutes);

// ✅ Start Server
const PORT = process.env.PORT || 5001;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
