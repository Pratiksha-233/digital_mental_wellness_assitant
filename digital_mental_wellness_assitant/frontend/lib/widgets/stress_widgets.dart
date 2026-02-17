import 'package:flutter/material.dart';
import '../models/stress_model.dart';

/// Main Stress Level Display Widget - Big circular gauge
class StressLevelGauge extends StatefulWidget {
  final double stressLevel;
  final String stressCategory;
  final Duration animationDuration;

  const StressLevelGauge({
    super.key,
    required this.stressLevel,
    required this.stressCategory,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<StressLevelGauge> createState() => _StressLevelGaugeState();
}

class _StressLevelGaugeState extends State<StressLevelGauge> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.animationDuration);
    _animation = Tween<double>(begin: 0, end: widget.stressLevel).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(StressLevelGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stressLevel != widget.stressLevel) {
      _controller.reset();
      _animation = Tween<double>(begin: oldWidget.stressLevel, end: widget.stressLevel)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColor(double value) {
    if (value < 25) return Colors.green;
    if (value < 50) return Colors.amber;
    if (value < 75) return Colors.orange;
    return Colors.red;
  }

  String _getEmoji(String category) {
    switch (category) {
      case 'LOW':
        return '😊';
      case 'MODERATE':
        return '😐';
      case 'HIGH':
        return '😟';
      case 'CRITICAL':
        return '😰';
      default:
        return '😊';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          _getColor(_animation.value).withOpacity(0.1),
                          _getColor(_animation.value).withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getColor(_animation.value).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                  // Animated progress ring
                  CustomPaint(
                    size: const Size(220, 220),
                    painter: StressGaugePainter(
                      progress: _animation.value / 100,
                      color: _getColor(_animation.value),
                    ),
                  ),
                  // Center content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getEmoji(widget.stressCategory),
                        style: const TextStyle(fontSize: 50),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_animation.value.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Stress Level',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getColor(_animation.value).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getColor(_animation.value),
                width: 2,
              ),
            ),
            child: Text(
              widget.stressCategory,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getColor(_animation.value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for stress gauge ring
class StressGaugePainter extends CustomPainter {
  final double progress;
  final Color color;

  StressGaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final sweepAngle = (progress * 2 * 3.14159);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(StressGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Stress Category Banner
class StressCategoryBanner extends StatelessWidget {
  final String category;
  final String emotion;
  final int energyLevel;
  final String moodPattern;

  const StressCategoryBanner({
    super.key,
    required this.category,
    required this.emotion,
    required this.energyLevel,
    required this.moodPattern,
  });

  Color _getCategoryColor() {
    switch (category) {
      case 'LOW':
        return Colors.green;
      case 'MODERATE':
        return Colors.amber;
      case 'HIGH':
        return Colors.orange;
      case 'CRITICAL':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getMoodEmoji() {
    switch (moodPattern) {
      case 'improving':
        return '📈';
      case 'declining':
        return '📉';
      default:
        return '➡️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getCategoryColor().withOpacity(0.3),
            _getCategoryColor().withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getCategoryColor(), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getCategoryColor(),
                ),
              ),
              Text(
                _getCategoryEmoji(category),
                style: const TextStyle(fontSize: 28),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Primary Emotion',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      emotion,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Energy Level',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '$energyLevel / 10',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
            children: [
              Text(
                'Mood Trend:',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 8),
              Text(
                _getMoodEmoji(),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 4),
              Text(
                moodPattern.capitalizeFirst(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'LOW':
        return '🟢';
      case 'MODERATE':
        return '🟡';
      case 'HIGH':
        return '🟠';
      case 'CRITICAL':
        return '🔴';
      default:
        return '⚪';
    }
  }
}

/// Contributing Factors Widget
class ContributingFactorsCard extends StatelessWidget {
  final List<ContributingFactor> factors;

  const ContributingFactorsCard({
    super.key,
    required this.factors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Contributing Factors',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...factors.asMap().entries.map((entry) {
            final index = entry.key;
            final factor = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index < factors.length - 1 ? 12 : 0),
              child: _FactorBar(
                factor: factor.factor,
                contribution: factor.contribution,
                rank: index + 1,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _FactorBar extends StatelessWidget {
  final String factor;
  final double contribution;
  final int rank;

  const _FactorBar({
    required this.factor,
    required this.contribution,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$rank. $factor',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Text(
              '${contribution.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: contribution / 100,
            minHeight: 6,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.blue.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}

/// Recommendations Widget
class RecommendationsCard extends StatelessWidget {
  final List<String> recommendations;

  const RecommendationsCard({
    super.key,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.withOpacity(0.1), Colors.indigo.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 Personalized Recommendations',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          ...recommendations
              .asMap()
              .entries
              .map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key + 1}.',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
