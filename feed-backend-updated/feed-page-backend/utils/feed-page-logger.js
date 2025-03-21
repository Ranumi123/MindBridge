const mongoose = require("mongoose");
const dotenv = require("dotenv");
const Feed = require("../models/feed-page-model");
const sampleData = require("../data/sampleFeedData");

dotenv.config();

mongoose
  .connect(process.env.MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(async () => {
    console.log("Connected to MongoDB");
    await Feed.deleteMany(); // Clear old data
    await Feed.insertMany(sampleData);
    console.log("✅ Sample data inserted!");
    mongoose.connection.close();
  })
  .catch((err) => console.error("❌ MongoDB connection error:", err));
