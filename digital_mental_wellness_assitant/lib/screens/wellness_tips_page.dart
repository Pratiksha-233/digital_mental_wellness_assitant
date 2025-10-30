import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WellnessTipsPage extends StatefulWidget {
  const WellnessTipsPage({Key? key}) : super(key: key);

  @override
  State<WellnessTipsPage> createState() => _WellnessTipsPageState();
}

class _WellnessTipsPageState extends State<WellnessTipsPage> {
  List<dynamic> _tips = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  Future<void> _loadTips() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final tips = await ApiService.fetchWellnessTips();
      setState(() {
        _tips = tips;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness Tips'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Failed to load tips', style: TextStyle(color: Colors.red[700])),
                        const SizedBox(height: 8),
                        Text(_error ?? ''),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadTips,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _tips.isEmpty
                    ? Center(child: Text('No tips available', style: TextStyle(color: Colors.grey[700])))
                    : ListView.separated(
                        itemCount: _tips.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final t = _tips[index];
                          final title = (t is Map && t['title'] != null) ? t['title'].toString() : t.toString();
                          final content = (t is Map && t['content'] != null) ? t['content'].toString() : '';
                          final readTime = (t is Map && t['readTimeMinutes'] != null) ? t['readTimeMinutes'].toString() : null;

                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: content.isNotEmpty ? Text(content, maxLines: 2, overflow: TextOverflow.ellipsis) : null,
                              trailing: readTime != null ? Text('$readTime min') : null,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(title),
                                    content: SingleChildScrollView(child: Text(content)),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
