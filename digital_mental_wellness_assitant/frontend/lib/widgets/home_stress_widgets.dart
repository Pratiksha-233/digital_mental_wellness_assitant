import 'package:flutter/material.dart';
import '../models/stress_model.dart';
import 'app_section_card.dart';



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

  @override
  void initState() {
    super.initState();
    _fetchStressData();
  }

  Future<void> _fetchStressData() async {
    try {




      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final stressColor = _getStressColor(_stressData?.stressLevel ?? 50);

    return GestureDetector(
      onTap: widget.onTap,
      child: AppSectionCard(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        gradient: AppSectionCard.gradientFromScheme(
          cs,
          a: stressColor,
          b: cs.surface,
          aAlpha: 0.16,
          bAlpha: 0.85,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : _stressData == null
            ? Text(
                'Unable to load stress data',
                style: TextStyle(color: cs.onSurfaceVariant),
              )
            : _buildStressContent(),
      ),
    );
  }

  Widget _buildStressContent() {
    final cs = Theme.of(context).colorScheme;
    final stressColor = _getStressColor(_stressData?.stressLevel ?? 50);

    return Column(
      children: [

        LayoutBuilder(
          builder: (context, constraints) {
            final imageHeight = constraints.maxWidth > 400 ? 120.0 : 100.0;
            final borderRadius = constraints.maxWidth > 400 ? 16.0 : 12.0;

            return Container(
              height: imageHeight,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.6),
                ),
                gradient: LinearGradient(
                  colors: [
                    stressColor.withValues(alpha: 0.14),
                    cs.surfaceContainerHighest.withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: Stack(
                  fit: StackFit.expand,
                  children: [

                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: imageHeight * 0.4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              cs.scrim.withValues(alpha: 0.28),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withValues(
                            alpha: 0.9,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: stressColor.withValues(alpha: 0.28),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.self_improvement,
                              color: stressColor,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Wellness',
                              style: TextStyle(
                                color: stressColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
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
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      _stressData!.stressLevel.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/100',
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurfaceVariant,
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
                    color: stressColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: stressColor.withValues(alpha: 0.2),
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

        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _stressData!.stressLevel / 100,
            minHeight: 6,
            backgroundColor: cs.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(stressColor),
          ),
        ),
        const SizedBox(height: 12),

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
                _stressData!.moodPattern == 'improving'
                    ? '📈'
                    : _stressData!.moodPattern == 'declining'
                    ? '📉'
                    : '➡️',
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
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(label, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
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
    final cs = Theme.of(context).colorScheme;
    final categoryColor = _getCategoryColor();

    return AppSectionCard(
      margin: const EdgeInsets.all(16),
      gradient: AppSectionCard.gradientFromScheme(
        cs,
        a: categoryColor,
        b: cs.surface,
        aAlpha: 0.14,
        bAlpha: 0.85,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_getCategoryEmoji(), style: const TextStyle(fontSize: 24)),
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
                        color: categoryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(fontSize: 13, color: cs.onSurface),
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
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ),
              if (onViewDetails != null)
                ElevatedButton(
                  onPressed: onViewDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: categoryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('View Details'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}


class StressRecommendationChip extends StatelessWidget {
  final String recommendation;
  final VoidCallback? onTap;

  const StressRecommendationChip({
    super.key,
    required this.recommendation,
    this.onTap,
  });

  String _getIcon() {
    if (recommendation.toLowerCase().contains('meditat')) {
      return '🧘';
    }
    if (recommendation.toLowerCase().contains('exercise') ||
        recommendation.toLowerCase().contains('physical')) {
      return '🏃';
    }
    if (recommendation.toLowerCase().contains('sleep')) {
      return '😴';
    }
    if (recommendation.toLowerCase().contains('breath')) {
      return '🌬️';
    }
    if (recommendation.toLowerCase().contains('water')) {
      return '💧';
    }
    if (recommendation.toLowerCase().contains('talk') ||
        recommendation.toLowerCase().contains('friend')) {
      return '👥';
    }
    return '💡';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_getIcon(), style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                recommendation,
                style: TextStyle(fontSize: 12, color: cs.onSurface),
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
