import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'meditation_detail_screen.dart';

class MeditationListScreen extends StatefulWidget {
  const MeditationListScreen({super.key});

  @override
  _MeditationListScreenState createState() => _MeditationListScreenState();
}

class _MeditationListScreenState extends State<MeditationListScreen> {
  List<dynamic> meditations = []; // Will hold our sample data
  String selectedFilter = "All";
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    // Instead of fetching from server, load sample data
    loadSampleData();
  }

  // Load sample data
  void loadSampleData() {
    // Add a delay to simulate loading
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        // Sample data
        meditations = [
          {
            "id": "1",
            "title": "Mindful Breathing",
            "author": "Sarah Johnson",
            "duration": "10 min",
            "category": "Meditation",
            "image": "https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=500",
            "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            "description": "A simple meditation focusing on breath awareness to calm the mind."
          },
          {
            "id": "2",
            "title": "Deep Sleep Relaxation",
            "author": "Michael Chen",
            "duration": "30 min",
            "category": "Sleep",
            "image": "https://images.unsplash.com/photo-1455642305367-68834a9d3fb4?w=500",
            "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            "description": "Soothing sounds and guidance to help you fall into a deep, restful sleep."
          },
          {
            "id": "3",
            "title": "Morning Yoga Flow",
            "author": "Emma Wilson",
            "duration": "15 min",
            "category": "Yoga",
            "image": "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=500",
            "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            "description": "Energizing yoga sequence to start your day with vitality and focus."
          },
          {
            "id": "4",
            "title": "Stress Relief Meditation",
            "author": "David Park",
            "duration": "20 min",
            "category": "Meditation",
            "image": "https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=500",
            "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            "description": "Release tension and find calm with this guided meditation practice."
          },
          {
            "id": "5",
            "title": "Bedtime Relaxation",
            "author": "Lisa Thompson",
            "duration": "25 min",
            "category": "Sleep",
            "image": "https://images.unsplash.com/photo-1531353826977-0941b4779a1c?w=500",
            "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            "description": "Gentle relaxation exercises to prepare your body and mind for sleep."
          },
          {
            "id": "6",
            "title": "Gentle Stretching",
            "author": "Ryan Miller",
            "duration": "12 min",
            "category": "Yoga",
            "image": "https://images.unsplash.com/photo-1510894347713-fc3ed6fdf539?w=500",
            "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            "description": "Simple stretches to relieve tension and improve flexibility."
          }
        ];
        isLoading = false;
      });
    });
  }

  // Function to filter meditations based on category
  List<dynamic> get filteredMeditations {
    if (selectedFilter == "All") {
      return meditations;
    } else {
      return meditations
          .where((med) => med["category"] == selectedFilter)
          .toList();
    }
  }

  // Function to open YouTube links
  void _launchYouTube(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Instead of throwing, just show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open video player")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rest of your build method remains the same
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wellness Page"),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(
          child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
          child: Text(errorMessage,
              style: const TextStyle(color: Colors.red)))
          : Column(
        children: [
          // Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 10, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ["All", "Sleep", "Meditation", "Yoga"]
                  .map((filter) {
                return ChoiceChip(
                  label: Text(filter,
                      style: const TextStyle(color: Colors.white)),
                  selected: selectedFilter == filter,
                  selectedColor: Colors.blueAccent,
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
                        builder: (context) => MeditationDetailScreen(
                            meditation: meditation),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
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
                                meditation["image"],
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child,
                                    loadingProgress) {
                                  if (loadingProgress == null)
                                    return child;
                                  return const Center(
                                      child:
                                      CircularProgressIndicator());
                                },
                                errorBuilder:
                                    (context, error, stackTrace) {
                                  return const Icon(
                                      Icons.broken_image,
                                      size: 90,
                                      color: Colors.grey);
                                },
                              ),
                            ),
                            // Play Button Overlay
                            Positioned(
                              child: GestureDetector(
                                onTap: () => _launchYouTube(meditation[
                                "url"]),
                                child: const Icon(
                                  Icons.play_circle_fill,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          meditation["title"],
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