import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; //url_launcher supported in ndk version 27 onwards
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'meditation_detail_screen.dart';

class MeditationListScreen extends StatefulWidget {
  const MeditationListScreen({super.key});

  @override
  _MeditationListScreenState createState() => _MeditationListScreenState();
}

class _MeditationListScreenState extends State<MeditationListScreen> {
  List<dynamic> meditations = []; // Holds data from backend server
  String selectedFilter = "All";  // Default filter so "All" is selected
  bool isLoading = true;          // Loading state
  String errorMessage = "";        // Error message

  @override
  void initState() {
    super.initState();
    fetchMeditations();
  }

  // Fetch data from backend server
  Future<void> fetchMeditations() async {
    try {
      final response =
          await http.get(Uri.parse("http://localhost:5000/api/meditations"));

      if (response.statusCode == 200) { //for successful response
        setState(() {
          meditations = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load meditations");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Could not load data. Check your internet connection";
      });
    }
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
      throw "Could not launch $url";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wellness Page"),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading state
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
              : Column(
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
                                      color: Colors.black.withOpacity(0.3), // Fixed opacity issue
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
                                            child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
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
    );
  }
}
