import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MeditationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> meditation;

  const MeditationDetailScreen({super.key, required this.meditation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meditation['title'] ?? 'Meditation'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4B9FE1), Color(0xFF1EBBD7)], // Gradient for AppBar
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meditation Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  meditation['image'] ?? '',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Meditation Title
              Text(
                meditation['title'] ?? 'No Title',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Meditation Author
              Text(
                'By ${meditation['author'] ?? 'Unknown'}',
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 10),

              // Meditation Category and Duration
              Row(
                children: [
                  Chip(
                    label: Text(meditation['category'] ?? 'Unknown'),
                    backgroundColor: const Color(0xFF1EBBD7).withValues(alpha: 0.2), // Teal with transparency
                  ),
                  const SizedBox(width: 10),
                  Chip(
                    label: Text(meditation['duration'] ?? 'Unknown'),
                    backgroundColor: const Color(0xFF20E4B5).withValues(alpha: 0.2), // Greenish accent with transparency
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Meditation Description
              Text(
                meditation['description'] ?? 'No description available.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),

              // Play Meditation Button with Gradient
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4B9FE1), Color(0xFF1EBBD7)], // Gradient for button
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // Allows gradient to show
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0, // Removes default shadow for a sleek look
                    ),
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    label: const Text("Play Meditation", style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      final url = meditation['url'];
                      if (url != null && url.isNotEmpty) {
                        final Uri uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Could not open video")),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("No video available")),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
