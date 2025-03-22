import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/bottom_navbar.dart';
import '../therapist_dashboard/appointment_screen.dart';
import '../profile_setup_page/profile_setup_screen.dart';
import '../feed-page/meditation_detail_screen.dart';
import '../home/home_page.dart';
import 'dart:math' as Math;

class MeditationListScreen extends StatefulWidget {
  const MeditationListScreen({super.key});

  @override
  _MeditationListScreenState createState() => _MeditationListScreenState();
}

class _MeditationListScreenState extends State<MeditationListScreen> {
  int _selectedIndex = 2;
  List<dynamic> meditations = [];
  bool isLoading = true;
  String errorMessage = "";
  String selectedFilter = "All"; // Added filter state

  // ✅ Backend API URL (Updated to match backend endpoint)
  final String apiUrl = "http://localhost:5001/api/feed";

  @override
  void initState() {
    super.initState();
    fetchMeditations();
  }

  // ✅ Function to Fetch Meditations from Backend - Simplified without auth
  Future<void> fetchMeditations() async {
    try {
      print("Fetching meditations from: $apiUrl");
      final response = await http.get(Uri.parse(apiUrl));

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body.substring(0, Math.min(100, response.body.length))}...");

      if (response.statusCode == 200) {
        setState(() {
          meditations = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load meditations: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching meditations: $e");
      setState(() {
        isLoading = false;
        errorMessage = "Could not load data. Using offline data.";
        meditations = backupMeditations;
      });
    }
  }

  // ✅ Filtered Meditations Getter
  List<dynamic> get filteredMeditations {
    if (selectedFilter == "All") {
      return meditations;
    } else {
      return meditations
          .where((med) => med["category"] == selectedFilter)
          .toList();
    }
  }

  // ✅ Backup Data (Used when Backend Fails)
  final List<Map<String, String>> backupMeditations = [
    {
      "title": "Yoga Nidra For Sleep",
      "duration": "18 min",
      "category": "Sleep",
      "author": "Satvic Yoga",
      "image":
      "https://cdn.pixabay.com/photo/2024/04/19/22/25/man-8707406_1280.png",
      "description":
      "A deep relaxation yoga practice that helps calm the nervous system and promote deep sleep.",
      "url": "https://youtu.be/uPSml_JQGVY?si=uAuuvPDMDQlV7az4"
    },
    {
      "title": "Deep Sleep Guided Meditation",
      "duration": "120 min",
      "category": "Sleep",
      "author": "Lauren Gale",
      "image":
      "https://images.pexels.com/photos/8263101/pexels-photo-8263101.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
      "description":
      "A long, guided meditation session to help you relax and fall into a deep and peaceful sleep.",
      "url": "https://youtu.be/gnmlcfZdnBg?si=A1-zDZKzwSmkWp5v"
    },
    {
      "title": "Breathing Into Sleep",
      "duration": "30 min",
      "category": "Sleep",
      "author": "Ally Boothroyd",
      "image":
      "https://images.pexels.com/photos/289586/pexels-photo-289586.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
      "description":
      "This 30-minute guided sleep meditation combines gentle pranayama, deep relaxation, and ocean wave sounds to help you fall asleep quickly and overcome insomnia.",
      "url": "https://youtu.be/1G2he0jYOl0?si=b0HrMUXJoqycxjPd"
    },
    {
      "title": "Peaceful Sleep Meditation",
      "duration": "7 min",
      "category": "Sleep",
      "author": "Tone It Up",
      "image":
      "https://images.pexels.com/photos/8261185/pexels-photo-8261185.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
      "description":
      "This evening meditation promotes relaxation, gratitude, and stress release, facilitating a peaceful transition into sleep and setting a positive tone for the next day.",
      "url": "https://youtu.be/PZqvrttn7-c?si=TL0g5ApoQLeyDnsv"
    },
    {
      "title": "Morning Yoga Flow",
      "duration": "22 min",
      "category": "Yoga",
      "author": "Adriene",
      "image":
      "https://images.pexels.com/photos/4056723/pexels-photo-4056723.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
      "description":
      "This 21-minute breath-focused morning flow combines core activation, mobility exercises, and mindful movement to cultivate a peaceful mind, strong body, and positive mindset for the day ahead.",
      "url": "https://youtu.be/LqXZ628YNj4?si=xt_7MZQOyGHjODUX"
    },
    {
      "title": "Meditation for Focus",
      "duration": "10 min",
      "category": "Meditation",
      "author": "Declutter The Mind",
      "image": "https://i.imgur.com/M5qCCV4_d.webp?maxwidth=760&fidelity=grand",
      "description":
      "This 10-minute voice-only guided meditation uses breath awareness and mindfulness to enhance concentration, clarity, and focus for improved productivity in work, school, or daily life.",
      "url": "https://youtu.be/ausxoXBrmWs?si=SXMNeKsuMVvtOfxK"
    }
  ];

  // ✅ Function to Open YouTube Links
  void _launchYouTube(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open video.")),
      );
    }
  }

  // ✅ Navigation Function for Bottom Navbar
  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
        break;
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AppointmentScreen()));
        break;
      case 2:
        break;
      case 3:
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProfilePage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              var begin = Offset(0.0, 1.0);
              var end = Offset.zero;
              var curve = Curves.easeInOut;
              var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                  position: animation.drive(tween), child: child);
            },
          ),
        );
        break;
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
              colors: [Color(0xFF4B9FE1), Color(0xFF1EBBD7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage,
                style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = "";
                });
                fetchMeditations();
              },
              child: const Text("Try Again"),
            ),
          ],
        ),
      )
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

          // Meditation List - UPDATED TO USE FILTERED RESULTS
          Expanded(
            child: ListView.builder(
              itemCount: filteredMeditations.length,
              itemBuilder: (context, index) {
                final meditation = filteredMeditations[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to MeditationDetailScreen when tapping the text
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MeditationDetailScreen(
                                  meditation: meditation),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // Thumbnail (Tappable to Open YouTube)
                          GestureDetector(
                            onTap: () =>
                                _launchYouTube(meditation["url"]!),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(8),
                                  child: Image.network(
                                    meditation["image"]!,
                                    width: 120,
                                    height: 80,
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
                                      return Container(
                                        width: 120,
                                        height: 80,
                                        color: Colors.grey.shade300,
                                        child: const Center(
                                          child: Icon(
                                              Icons
                                                  .image_not_supported,
                                              size: 50,
                                              color: Colors.grey),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const Icon(Icons.play_circle_fill,
                                    color: Colors.white, size: 40),
                              ],
                            ),
                          ),

                          // Meditation Info (Tappable to Open Details)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meditation["title"]!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "${meditation["duration"]} • ${meditation["author"]}",
                                    style: TextStyle(
                                        color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
          selectedIndex: _selectedIndex, onItemTapped: _onItemTapped),
    );
  }
}

