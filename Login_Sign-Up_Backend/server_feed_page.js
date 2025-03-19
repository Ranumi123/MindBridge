const express = require("express");
const cors = require("cors");

const app = express();
app.use(cors());

const meditations = [
  {
    "title": "Yoga Nidra For Sleep",
    "duration": "18 min",
    "category": "Sleep",
    "author": "Satvic Yoga",
    "image": "https://cdn.pixabay.com/photo/2024/04/19/22/25/man-8707406_1280.png",
    "description": "A deep relaxation yoga practice that helps calm the nervous system and promote deep sleep.",
    "url": "https://youtu.be/uPSml_JQGVY?si=uAuuvPDMDQlV7az4"
  },
  {
    "title": "Deep Sleep Guided Meditation",
    "duration": "120 min",
    "category": "Sleep",
    "author": "Lauren Gale",
    "image": "https://images.pexels.com/photos/8263101/pexels-photo-8263101.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
    "description": "A long, guided meditation session to help you relax and fall into a deep and peaceful sleep.",
    "url": "https://youtu.be/gnmlcfZdnBg?si=A1-zDZKzwSmkWp5v"
  },
  {
    "title": "Breathing Into Sleep",
    "duration": "30 min",
    "category": "Sleep",
    "author": "Ally Boothroyd",
    "image": "https://images.pexels.com/photos/289586/pexels-photo-289586.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
    "description": "This 30-minute guided sleep meditation combines gentle pranayama, deep relaxation, and ocean wave sounds to help you fall asleep quickly and overcome insomnia.",
    "url": "https://youtu.be/1G2he0jYOl0?si=b0HrMUXJoqycxjPd"
  },
  {
    "title": "Peaceful Sleep Meditation",
    "duration": "7 min",
    "category": "Sleep",
    "author": "Tone It Up",
    "image": "https://images.pexels.com/photos/8261185/pexels-photo-8261185.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
    "description": "This evening meditation promotes relaxation, gratitude, and stress release, facilitating a peaceful transition into sleep and setting a positive tone for the next day.",
    "url": "https://youtu.be/PZqvrttn7-c?si=TL0g5ApoQLeyDnsv"
  },
  {
    "title": "Morning Yoga Flow",
    "duration": "22 min",
    "category": "Yoga",
    "author": "Adriene",
    "image": "https://images.pexels.com/photos/4056723/pexels-photo-4056723.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
    "description": "This 21-minute breath-focused morning flow combines core activation, mobility exercises, and mindful movement to cultivate a peaceful mind, strong body, and positive mindset for the day ahead.",
    "url": "https://youtu.be/LqXZ628YNj4?si=xt_7MZQOyGHjODUX"
  },
  {
    "title": "Meditation for Focus",
    "duration": "10 min",
    "category": "Meditation",
    "author": "Declutter The Mind",
    "image": "https://i.imgur.com/M5qCCV4_d.webp?maxwidth=760&fidelity=grand",
    "description": "This 10-minute voice-only guided meditation uses breath awareness and mindfulness to enhance concentration, clarity, and focus for improved productivity in work, school, or daily life.",
    "url": "https://youtu.be/ausxoXBrmWs?si=SXMNeKsuMVvtOfxK"
  }
];

// API Route to serve meditations
app.get("/api/meditations", (req, res) => {
  res.json(meditations);
});

// Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
