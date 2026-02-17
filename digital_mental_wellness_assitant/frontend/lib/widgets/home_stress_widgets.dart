import 'package:flutter/material.dart';
import '../models/stress_model.dart';

/// Mini Stress Indicator Widget for Home Screen
/// Shows a quick summary of current stress level
class QuickStressIndicator extends StatefulWidget {
  final int userId;
  final VoidCallback? onTap;
  final Duration refreshInterval;

  const QuickStressIndicator({
    super.key,
    required this.userId,
    this.onTap,
    this.refreshInterval = const Duration(hours: 1),
  });

  @override
  State<QuickStressIndicator> createState() => _QuickStressIndicatorState();
}

class _QuickStressIndicatorState extends State<QuickStressIndicator> {
  StressData? _stressData;
  bool _isLoading = true;
  late DateTime _lastRefresh;

  @override
  void initState() {
    super.initState();
    _lastRefresh = DateTime.now();
    _fetchStressData();
  }

  Future<void> _fetchStressData() async {
    try {
      // Import and use your ApiService
      // final api = StressApiService();
      // _stressData = await api.getStressLevel(userId: widget.userId);
      
      setState(() {
        _isLoading = false;
        _lastRefresh = DateTime.now();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getStressColor(_stressData?.stressLevel ?? 50).withOpacity(0.15),
              _getStressColor(_stressData?.stressLevel ?? 50).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getStressColor(_stressData?.stressLevel ?? 50).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : _stressData == null
                ? const SizedBox(
                    height: 100,
                    child: Center(
                      child: Text('Unable to load stress data'),
                    ),
                  )
                : _buildStressContent(),
      ),
    );
  }

  Widget _buildStressContent() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Stress Level',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${_stressData!.stressLevel.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/100',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _stressData!.stressCategory,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getStressColor(_stressData!.stressLevel),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStressColor(_stressData!.stressLevel).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _stressData!.categoryEmoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Mini stress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _stressData!.stressLevel / 100,
            minHeight: 6,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getStressColor(_stressData!.stressLevel),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Quick info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildQuickInfoItem(
                '😊',
                _stressData!.primaryEmotion,
                'Primary Emotion',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickInfoItem(
                '⚡',
                '${_stressData!.energyLevel}/10',
                'Energy',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickInfoItem(
                _stressData!.moodPattern == 'improving' ? '📈' : _stressData!.moodPattern == 'declining' ? '📉' : '➡️',
                _stressData!.moodPattern,
                'Trend',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickInfoItem(String icon, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Color _getStressColor(double value) {
    if (value < 25) return Colors.green;
    if (value < 50) return Colors.amber;
    if (value < 75) return Colors.orange;
    return Colors.red;
  }
}

/// Stress Alert Widget - Shows when stress is high
class StressAlertBanner extends StatelessWidget {
  final String category;
  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onViewDetails;

  const StressAlertBanner({
    super.key,
    required this.category,
    required this.message,
    this.onDismiss,
    this.onViewDetails,
  });

  Color _getCategoryColor() {
    switch (category) {
      case 'HIGH':
        return Colors.orange;
      case 'CRITICAL':
        return Colors.red;
      default:
        return Colors.amber;
    }
  }

  String _getCategoryEmoji() {
    switch (category) {
      case 'HIGH':
        return '🟠';
      case 'CRITICAL':
        return '🔴';
      default:
        return '⚠️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getCategoryColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getCategoryColor(),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _getCategoryColor().withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _getCategoryEmoji(),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'High Stress Detected',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getCategoryColor(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onDismiss != null)
                TextButton(
                  onPressed: onDismiss,
                  child: Text(
                    'Dismiss',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              if (onViewDetails != null)
                ElevatedButton(
                  onPressed: onViewDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getCategoryColor(),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Stress Recommendation Chip
class StressRecommendationChip extends StatelessWidget {
  final String recommendation;
  final VoidCallback? onTap;

  const StressRecommendationChip({
    super.key,
    required this.recommendation,
    this.onTap,
  });

  String _getIcon() {
    if (recommendation.toLowerCase().contains('meditat')) return '🧘';
    if (recommendation.toLowerCase().contains('exercise') || recommendation.toLowerCase().contains('physical')) return '🏃';
    if (recommendation.toLowerCase().contains('sleep')) return '😴';
    if (recommendation.toLowerCase().contains('breath')) return '🌬️';
    if (recommendation.toLowerCase().contains('water')) return '💧';
    if (recommendation.toLowerCase().contains('talk') || recommendation.toLowerCase().contains('friend')) return '👥';
    return '💡';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_getIcon(), style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                recommendation,
                style: const TextStyle(fontSize: 12, color: Colors.blue),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
