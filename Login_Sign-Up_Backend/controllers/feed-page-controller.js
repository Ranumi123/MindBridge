const Feed = require("../models/feed-page-model");

// ✅ Fetch all feed items
const getFeeds = async (req, res) => {
  try {
    const feeds = await Feed.find();
    res.json(feeds);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ✅ Fetch a single feed item by ID
const getFeedById = async (req, res) => {
  try {
    const feed = await Feed.findById(req.params.id);
    if (!feed) {
      return res.status(404).json({ message: "Feed not found" });
    }
    res.json(feed);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ✅ Add a new feed item
const addFeed = async (req, res) => {
  const { title, author, category, duration, description, image, url } = req.body;
  
  try {
    const newFeed = new Feed({
      title,
      author,
      category,
      duration,
      description,
      image,
      url,
    });
    
    const savedFeed = await newFeed.save();
    res.status(201).json(savedFeed);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { getFeeds, getFeedById, addFeed };