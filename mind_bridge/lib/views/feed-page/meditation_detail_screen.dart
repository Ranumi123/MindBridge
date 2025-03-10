import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; //url_launcher supported in ndk version 27 onwards

class MeditationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> meditation;

  const MeditationDetailScreen({super.key, required this.meditation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meditation['title'] ?? 'Meditation'),
        backgroundColor: Colors.blueAccent, //main color of the app
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
                    backgroundColor: Colors.blueAccent.withValues(alpha: 0.3), //withOpacity was deprecated hence withValues with alpha was used
                  ),
                  const SizedBox(width: 10),
                  Chip(
                    label: Text(meditation['duration'] ?? 'Unknown'),
                    backgroundColor: Colors.greenAccent.withValues(alpha: 0.3),
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

              // Play Meditation Button
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
            ],
          ),
        ),
      ),
    );
  }
}
