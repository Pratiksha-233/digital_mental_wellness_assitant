import 'package:flutter/material.dart';
import '../models/stress_model.dart';
import '../widgets/stress_widgets.dart';
import '../widgets/app_section_card.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class StressAnalyzerScreenNew extends StatefulWidget {
  final int userId;
  const StressAnalyzerScreenNew({super.key, required this.userId});

  @override
  State<StressAnalyzerScreenNew> createState() =>
      _StressAnalyzerScreenNewState();
}

class _StressAnalyzerScreenNewState extends State<StressAnalyzerScreenNew>
    with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  StressData? _currentStress;
  List<StressHistoryRecord>? _stressHistory;
  StressStats? _stressStats;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedTab = 0; // 0: Current, 1: History, 2: Stats

  StressData _stressDataFromHistory(StressHistoryRecord record) {
    return StressData(
      stressLevel: record.stressLevel,
      stressCategory: record.stressCategory,
      primaryEmotion: record.primaryEmotion,
      energyLevel: record.energyLevel,
      moodPattern: record.moodPattern,
      recommendations: const [],
      contributingFactors: const [],
      componentScores: ComponentScores(
        emotionScore: 0,
        moodScore: 0,
        energyScore: 0,
        activityScore: 0,
        trendScore: 0,
      ),
      timestamp: record.timestamp,
    );
  }

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
    _fetchStressData();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchStressData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = ApiService();

      // Fetch history first (DB-backed). This keeps the screen useful even if
      // stress calculation fails (e.g., missing ML deps, no recent mood data).
      final historyJson = await api.get(
        '/stress/history?user_id=${widget.userId}&days=30&limit=100',
      );
      final historyRows = (historyJson?['data'] is List)
          ? (historyJson!['data'] as List)
          : const <dynamic>[];
      final history = historyRows
          .whereType<Map>()
          .map(
            (h) => StressHistoryRecord.fromJson(
              h.map((k, v) => MapEntry(k.toString(), v)),
            ),
          )
          .toList();
      history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _stressHistory = history;

      // Try fetching current stress (also saves DB). If it fails, fall back to
      // latest historical DB record.
      final stressJson = await api.get(
        '/stress/calculate?user_id=${widget.userId}',
      );
      if (stressJson != null && stressJson['data'] is Map) {
        _currentStress = StressData.fromJson(
          (stressJson['data'] as Map).map((k, v) => MapEntry(k.toString(), v)),
        );
      } else if (_stressHistory != null && _stressHistory!.isNotEmpty) {
        _currentStress = _stressDataFromHistory(_stressHistory!.first);
      } else {
        // No DB history and couldn't calculate.
        _currentStress = null;
      }

      // Fetch stats (optional; may be 404 if no history)
      final statsJson = await api.get('/stress/stats?user_id=${widget.userId}');
      _stressStats = statsJson == null ? null : StressStats.fromJson(statsJson);

      setState(() {
        _isLoading = false;
        if (_currentStress == null &&
            (_stressHistory == null || _stressHistory!.isEmpty)) {
          _errorMessage =
              'No stress data available yet. Add a stress entry (questionnaire) or try Calculate.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load stress data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stress Level Analysis'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
          ? _buildErrorState()
          : _buildMainContent(),
    );
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Analyzing your stress level...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('❌', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: _fetchStressData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    if (_currentStress == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.insights, size: 44),
              const SizedBox(height: 12),
              const Text(
                'No stress record yet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'This screen shows stress records saved in the database.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: _fetchStressData,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabButton(0, 'Current'),
                _buildTabButton(1, 'History'),
                _buildTabButton(2, 'Stats'),
              ],
            ),
          ),

          // Tab content
          if (_selectedTab == 0) ...[
            // Current stress display
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: StressLevelGauge(
                stressLevel: _currentStress!.stressLevel,
                stressCategory: _currentStress!.stressCategory,
              ),
            ),
            StressCategoryBanner(
              category: _currentStress!.stressCategory,
              emotion: _currentStress!.primaryEmotion,
              energyLevel: _currentStress!.energyLevel,
              moodPattern: _currentStress!.moodPattern,
            ),
            if (_currentStress!.contributingFactors.isNotEmpty)
              ContributingFactorsCard(
                factors: _currentStress!.contributingFactors,
              ),
            if (_currentStress!.recommendations.isNotEmpty)
              RecommendationsCard(
                recommendations: _currentStress!.recommendations,
              ),
            const SizedBox(height: 20),
          ],
          if (_selectedTab == 1) ...[
            // History tab
            _buildHistoryTab(),
          ],
          if (_selectedTab == 2) ...[
            // Stats tab
            _buildStatsTab(),
          ],
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTab == index;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    if (_stressHistory == null || _stressHistory!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Text('📋', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'No history available yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        AppSectionCard(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          gradient: AppSectionCard.gradientFromScheme(
            cs,
            a: cs.surfaceContainerHighest,
            b: cs.surface,
            aAlpha: 0.82,
            bAlpha: 0.62,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last 30 Days',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(height: 150, child: _buildSimpleChart(_stressHistory!)),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _stressHistory!.length,
            itemBuilder: (context, index) {
              final record = _stressHistory![index];
              return _buildHistoryItem(record);
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHistoryItem(StressHistoryRecord record) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getStressColor(record.stressLevel).withOpacity(0.2),
            ),
            child: Center(
              child: Text(
                record.stressLevel.toStringAsFixed(0),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getStressColor(record.stressLevel),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.stressCategory,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Emotion: ${record.primaryEmotion}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(record.timestamp),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    if (_stressStats == null) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Text('Stats not available'),
      );
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final stats = _stressStats!;
    return Column(
      children: [
        // Key metrics grid
        Container(
          margin: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildStatCard(
                'Average',
                stats.averageStress.toStringAsFixed(1),
                cs.primary,
              ),
              _buildStatCard(
                'Current',
                stats.currentStress.toStringAsFixed(1),
                _getStressColor(stats.currentStress),
              ),
              _buildStatCard(
                'Min',
                stats.minStress.toStringAsFixed(1),
                cs.tertiary,
              ),
              _buildStatCard(
                'Max',
                stats.maxStress.toStringAsFixed(1),
                cs.error,
              ),
            ],
          ),
        ),
        // Trend indicator
        AppSectionCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.all(16),
          gradient: AppSectionCard.gradientFromScheme(
            cs,
            a: cs.surfaceContainerHighest,
            b: cs.surface,
            aAlpha: 0.82,
            bAlpha: 0.62,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Trend',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Row(
                children: [
                  Text(stats.trendEmoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    stats.trend.replaceAll('_', ' ').toUpperCase(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Category distribution
        AppSectionCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.all(16),
          gradient: AppSectionCard.gradientFromScheme(
            cs,
            a: cs.surfaceContainerHighest,
            b: cs.surface,
            aAlpha: 0.82,
            bAlpha: 0.62,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Distribution (Last ${30} Days)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              _buildDistributionBar('LOW', stats.lowCount, Colors.green),
              _buildDistributionBar(
                'MODERATE',
                stats.moderateCount,
                Colors.amber,
              ),
              _buildDistributionBar('HIGH', stats.highCount, Colors.orange),
              _buildDistributionBar(
                'CRITICAL',
                stats.criticalCount,
                Colors.red,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppSectionCard(
      padding: const EdgeInsets.all(16),
      gradient: AppSectionCard.gradientFromScheme(
        cs,
        a: cs.surfaceContainerHighest,
        b: cs.surface,
        aAlpha: 0.82,
        bAlpha: 0.62,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionBar(String category, int count, Color color) {
    final total = (_stressStats?.totalRecords ?? 1).toDouble();
    final percentage = (count / total) * 100;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '$count (${percentage.toStringAsFixed(1)}%)',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: count / (total > 0 ? total : 1),
              minHeight: 8,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleChart(List<StressHistoryRecord> records) {
    if (records.isEmpty) return const SizedBox.shrink();

    // Simple bar chart representation. Use layout constraints (not screen
    // width) to avoid RenderFlex overflow inside padded cards.
    final sorted = List<StressHistoryRecord>.from(records)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final chartRecords = sorted.length > 30
        ? sorted.sublist(sorted.length - 30)
        : sorted;

    final maxValue = chartRecords
        .map((r) => r.stressLevel)
        .fold<double>(0.0, (prev, v) => v > prev ? v : prev);
    final safeMax = maxValue <= 0 ? 100.0 : maxValue;
    const barSpacing = 3.0;
    const maxBarHeight = 110.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final bars = chartRecords.length;
        final totalSpacing = barSpacing * (bars - 1).clamp(0, 999);
        final barWidth = bars == 0
            ? 0.0
            : ((availableWidth - totalSpacing) / bars).clamp(2.0, 40.0);

        return Align(
          alignment: Alignment.bottomLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(bars, (index) {
              final record = chartRecords[index];
              final barHeight = ((record.stressLevel / safeMax) * maxBarHeight)
                  .clamp(2.0, maxBarHeight);
              return Padding(
                padding: EdgeInsets.only(
                  right: index == bars - 1 ? 0 : barSpacing,
                ),
                child: Container(
                  width: barWidth,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: _getStressColor(record.stressLevel),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Color _getStressColor(double value) {
    if (value < 25) return Colors.green;
    if (value < 50) return Colors.amber;
    if (value < 75) return Colors.orange;
    return Colors.red;
  }
}
