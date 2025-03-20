import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'meditation_detail_screen.dart';

class MeditationListScreen extends StatefulWidget {
  const MeditationListScreen({super.key});

  @override
  _MeditationListScreenState createState() => _MeditationListScreenState();
}

class _MeditationListScreenState extends State<MeditationListScreen> {
  // Store meditation data locally instead of fetching from backend
  final List<Map<String, String>> meditations = [
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

  String selectedFilter = "All"; // Default filter

  // Filter meditations based on category
  List<Map<String, String>> get filteredMeditations {
    if (selectedFilter == "All") {
      return meditations;
    } else {
      return meditations
          .where((med) => med["category"] == selectedFilter)
          .toList();
    }
  }

  // Open YouTube links
  void _launchYouTube(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open the link.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wellness Page"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4B9FE1), Color(0xFF1EBBD7)], // Gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ["All", "Sleep", "Meditation", "Yoga"].map((filter) {
                return ChoiceChip(
                  label: Text(filter, style: const TextStyle(color: Colors.white)),
                  selected: selectedFilter == filter,
                  selectedColor: const Color(0xFF1EBBD7),
                  backgroundColor: Colors.grey[800],
                  onSelected: (bool selected) {
                    setState(() {
                      selectedFilter = filter;
                    });
                  },
                );
              }).toList(),
            ),
          ),

          // Meditation List
          Expanded(
            child: ListView.builder(
              itemCount: filteredMeditations.length,
              itemBuilder: (context, index) {
                final meditation = filteredMeditations[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MeditationDetailScreen(meditation: meditation),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                meditation["image"]!,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.broken_image, size: 90, color: Colors.grey);
                                },
                              ),
                            ),
                            // Play Button Overlay
                            Positioned(
                              child: GestureDetector(
                                onTap: () => _launchYouTube(meditation["url"]!),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          meditation["title"]!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "${meditation["duration"]} • ${meditation["author"]}",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
