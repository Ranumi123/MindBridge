const express = require("express");
const { getFeeds, getFeedById, addFeed } = require("../controllers/feed-page-controller");

const router = express.Router();

// ✅ Get all feed items
router.get("/", getFeeds);

// ✅ Get a single feed item by ID
router.get("/:id", getFeedById);

// ✅ Add a new feed item
router.post("/", addFeed);

module.exports = router;
