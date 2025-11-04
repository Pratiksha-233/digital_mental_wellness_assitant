import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _recommendations = [];
  final _emotionController = TextEditingController();
  bool _isLoading = false;

  void _getRecommendations() async {
    if (_emotionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an emotion')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = await _api.getRecommendations(_emotionController.text);
      setState(() => _recommendations = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching recommendations: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendations'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emotionController,
              decoration: InputDecoration(
                labelText: 'Enter emotion (e.g. sad, happy, anxious)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.emoji_emotions_outlined),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _getRecommendations,
              icon: const Icon(Icons.search),
              label: const Text('Get Recommendations'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _recommendations.isEmpty
                      ? const Center(
                          child: Text(
                            'No recommendations yet. Enter an emotion above.',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: _recommendations.length,
                          itemBuilder: (context, index) {
                            final rec = _recommendations[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: const Icon(Icons.lightbulb_outline,
                                    color: Colors.teal),
                                title: Text(
                                  rec['suggestion_text'] ?? 'No suggestion text',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: rec['resource_link'] != null &&
                                        rec['resource_link'].toString().isNotEmpty
                                    ? Text(
                                        rec['resource_link'],
                                        style: const TextStyle(
                                          color: Colors.blueAccent,
                                          decoration: TextDecoration.underline,
                                        ),
                                      )
                                    : const Text('No resource link available'),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
