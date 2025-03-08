require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { GoogleGenerativeAI } = require("@google/generative-ai");
const tf = require('@tensorflow/tfjs');
const toxicity = require('@tensorflow-models/toxicity');
const fs = require('fs').promises;
const path = require('path');

// Import routes
const authRoutes = require("./routes/authRoutes");
const profileRoutes = require("./routes/profileRoutes");

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Google Generative AI Setup
const genAI = new GoogleGenerativeAI(process.env.GOOGLE_API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });

// Path to the suicidal dataset
const datasetPath = path.join(__dirname, 'datasets', 'Suicide_Ideation_Dataset(Twitter-based).csv');

// In-memory storage for processed dataset
let suicideDataset = [];
let suicidalPatterns = [];
let initialized = false;

// Load and process suicide dataset
async function loadSuicideDataset() {
    if (initialized) {
        return true;
    }
    
    try {
        // Check if the file exists
        if (!await fileExists(datasetPath)) {
            console.error("Dataset file not found at:", datasetPath);
            return false;
        }

        const data = await fs.readFile(datasetPath, 'utf8');
        const lines = data.split('\n');
        
        // Process header and data
        const [header, ...records] = lines;
        const [tweetIndex, suicideIndex] = getColumnIndexes(header);
        
        if (tweetIndex === -1 || suicideIndex === -1) {
            console.error("Dataset does not contain required columns (Tweet, Suicide)");
            return false;
        }

        suicideDataset = parseDataset(records, tweetIndex, suicideIndex);
        
        // Extract patterns after loading dataset
        extractSuicidePatterns();
        initialized = true;
        console.log(`Loaded ${suicideDataset.length} records from suicide dataset`);
        return true;
    } catch (error) {
        console.error("Error loading suicide dataset:", error);
        return false;
    }
}

// Helper functions
async function fileExists(filePath) {
    try {
        await fs.access(filePath);
        return true;
    } catch {
        return false;
    }
}

function getColumnIndexes(header) {
    const headerColumns = header.split(',');
    const tweetIndex = headerColumns.findIndex(col => col.trim().toLowerCase() === 'tweet');
    const suicideIndex = headerColumns.findIndex(col => col.trim().toLowerCase() === 'suicide');
    return [tweetIndex, suicideIndex];
}

function parseDataset(records, tweetIndex, suicideIndex) {
    return records
        .filter(record => record.trim())
        .map(record => {
            const columns = record.split(',');
            return { Tweet: columns[tweetIndex].trim(), Suicide: columns[suicideIndex].trim() };
        });
}

// Extract suicide keywords and patterns from the dataset
function extractSuicidePatterns() {
    const baseIndicators = [
        "kill myself", "suicide", "end my life", "want to die", 
        "tired of living", "don't want to be here", "end it all",
        "put myself to rest", "roll over and die", "hate my life",
        "life is miserable", "hope i die"
    ];
    
    suicidalPatterns = [...baseIndicators];

    suicideDataset.forEach(item => {
        if (item.Suicide.toLowerCase().includes("suicide") || item.Suicide.toLowerCase().includes("potential")) {
            baseIndicators.forEach(indicator => {
                if (item.Tweet.toLowerCase().includes(indicator) && !suicidalPatterns.includes(indicator)) {
                    suicidalPatterns.push(indicator);
                }
            });
        }
    });

    console.log(`Extracted ${suicidalPatterns.length} suicide patterns from dataset`);
}

// Detect harmful content
async function detectHarmfulText(text) {
    const suicidalCheck = detectSuicidalContent(text);
    if (suicidalCheck.isSuicidal) {
        return { harmful: true, type: 'suicidal', details: suicidalCheck };
    }

    try {
        const toxicityModel = await toxicity.load(0.8);
        const predictions = await toxicityModel.classify([text]);
        
        for (const prediction of predictions) {
            if (prediction.results[0].match) {
                return { harmful: true, type: 'toxicity', category: prediction.label };
            }
        }
    } catch (error) {
        console.error("Error with toxicity model:", error);
    }

    return { harmful: false };
}

// Detect suicidal content in text
function detectSuicidalContent(text) {
    const textLower = text.toLowerCase();
    
    for (const phrase of suicidalPatterns) {
        if (textLower.includes(phrase)) {
            return { isSuicidal: true, matchedPhrase: phrase };
        }
    }

    const suicidePatterns = [
        /i (?:want|need|wish) to d[ie]{2}/i,
        /(?:kill(?:ing)? myself|end(?:ing)? (?:my life|it all))/i,
        /(?:don'?t|do not) want to (?:live|be here|exist)/i,
        /(?:hate|tired of) (?:my )?life/i,
        /(?:put (?:myself|me) to rest)/i,
        /(?:no reason to (?:live|be here|continue))/i
    ];

    for (const pattern of suicidePatterns) {
        if (pattern.test(textLower)) {
            return { isSuicidal: true, matchedPattern: pattern.toString() };
        }
    }

    return { isSuicidal: false };
}

// Response functions
function getSuicidalResponse() {
    const responses = [
        "I notice you're expressing thoughts about harming yourself. Please know that help is available. Would you like me to provide crisis resources?",
        "I'm concerned about what you've shared. If you're feeling suicidal, please talk to someone right away. The National Suicide Prevention Lifeline is available 24/7 at 988 or 1-800-273-8255.",
        "It sounds like you're going through a difficult time. Your life matters, and there are people who want to help. Would you like information about crisis support services?"
    ];
    return responses[Math.floor(Math.random() * responses.length)];
}

function notifyEmergencyContacts(userId) {
    const emergencyContacts = getEmergencyContacts(userId);
    emergencyContacts.forEach(contact => {
        sendSMS(contact.phone, `Urgent: User ${userId} may be in danger. Please check on them immediately.`);
    });
}

function getEmergencyContacts(userId) {
    return [
        { name: "Contact 1", phone: "+1234567890" },
        { name: "Contact 2", phone: "+0987654321" }
    ];
}

function sendSMS(phone, message) {
    console.log(`Sending SMS to ${phone}: ${message}`);
}

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/profile", profileRoutes);

// Health check route
app.get("/", (req, res) => {
    res.send("Server is running!");
});

// Chat route
app.post('/chat', async (req, res) => {
    try {
        const { message, userId } = req.body;

        if (!message) {
            return res.status(400).json({ error: "Message is required" });
        }

        const sanitizedMessage = message.trim();

        if (sanitizedMessage.length < 5) {
            return res.json({ reply: "I need a bit more information to help you. Could you please elaborate?", status: "normal" });
        }

        const commonPhrases = ['hello', 'good morning', 'how are you', 'test', 'thanks', 'bye'];
        if (commonPhrases.some(phrase => sanitizedMessage.toLowerCase().includes(phrase))) {
            return res.json({ reply: "Thank you for reaching out! How can I assist you today?", status: "normal" });
        }

        const { harmful, type, details } = await detectHarmfulText(sanitizedMessage);
        
        if (harmful) {
            if (type === 'suicidal') {
                console.log(`Suicidal content detected: "${sanitizedMessage}"`);
                console.log(`Matched with: ${JSON.stringify(details)}`);
                
                notifyEmergencyContacts(userId);
                
                return res.status(200).json({ 
                    reply: getSuicidalResponse(),
                    status: "crisis",
                    resources: {
                        hotline: "988 or 1-800-273-8255",
                        text: "Text HOME to 741741",
                        chat: "https://suicidepreventionlifeline.org/chat/"
                    }
                });
            } else {
                return res.status(200).json({ 
                    reply: "I'm not able to respond to that type of content. How can I help you with something else?",
                    status: "inappropriate"
                });
            }
        }

        const result = await model.generateContent(sanitizedMessage);
        const response = await result.response;
        const text = response.candidates[0]?.content?.parts[0]?.text || "I'm sorry, I couldn't generate a response. How else can I help you?";

        res.json({ reply: text, status: "normal" });
    } catch (error) {
        console.error("Error:", error);
        res.status(500).json({ error: "Something went wrong with processing your message. Please try again.", status: "error" });
    }
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ msg: "Something went wrong!" });
});

// Initialize the dataset when server starts
(async function() {
    await loadSuicideDataset();
})();

const PORT = process.env.PORT || 5001;
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
