const mongoose = require("mongoose");

const FeedSchema = new mongoose.Schema({
  title: { type: String, required: true },
  author: { type: String, default: "Unknown" },
  category: { type: String, required: true },
  duration: { type: String, required: true },
  description: { type: String },
  image: { type: String },
  url: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model("Feed", FeedSchema);