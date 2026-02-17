import 'package:flutter/material.dart';
import '../models/stress_model.dart';
import '../widgets/stress_widgets.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class StressAnalyzerScreenNew extends StatefulWidget {
  final int userId;
  const StressAnalyzerScreenNew({super.key, required this.userId});

  @override
  State<StressAnalyzerScreenNew> createState() => _StressAnalyzerScreenNewState();
}

class _StressAnalyzerScreenNewState extends State<StressAnalyzerScreenNew> with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  StressData? _currentStress;
  List<StressHistoryRecord>? _stressHistory;
  StressStats? _stressStats;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedTab = 0; // 0: Current, 1: History, 2: Stats

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat(reverse: true);
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
      
      // Fetch current stress level
      final stressJson = await api.get('/stress/calculate?user_id=${widget.userId}');
      if (stressJson == null) throw Exception('Failed to fetch stress data');
      
      _currentStress = StressData.fromJson(stressJson['data']);

      // Fetch history
      final historyJson = await api.get('/stress/history?user_id=${widget.userId}&days=30');
      if (historyJson != null && historyJson['data'] != null) {
        _stressHistory = (historyJson['data'] as List)
            .map((h) => StressHistoryRecord.fromJson(h))
            .toList();
      }

      // Fetch stats
      final statsJson = await api.get('/stress/stats?user_id=${widget.userId}');
      if (statsJson != null) {
        _stressStats = StressStats.fromJson(statsJson);
      }

      setState(() {
        _isLoading = false;
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Analyzing your stress level...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('❌', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchStressData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_currentStress == null) return const SizedBox.shrink();

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
            ContributingFactorsCard(
              factors: _currentStress!.contributingFactors,
            ),
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
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_stressHistory == null || _stressHistory!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Text('📋', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'No history available yet',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Last 30 Days',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: _buildSimpleChart(_stressHistory!),
              ),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
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
                '${record.stressLevel.toStringAsFixed(0)}',
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Emotion: ${record.primaryEmotion}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(record.timestamp),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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
              _buildStatCard('Average', stats.averageStress.toStringAsFixed(1), Colors.blue),
              _buildStatCard('Current', stats.currentStress.toStringAsFixed(1), _getStressColor(stats.currentStress)),
              _buildStatCard('Min', stats.minStress.toStringAsFixed(1), Colors.green),
              _buildStatCard('Max', stats.maxStress.toStringAsFixed(1), Colors.red),
            ],
          ),
        ),
        // Trend indicator
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Trend',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Row(
                children: [
                  Text(
                    stats.trendEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    stats.trend.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Category distribution
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Distribution (Last ${30} Days)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 16),
              _buildDistributionBar('LOW', stats.lowCount, Colors.green),
              _buildDistributionBar('MODERATE', stats.moderateCount, Colors.amber),
              _buildDistributionBar('HIGH', stats.highCount, Colors.orange),
              _buildDistributionBar('CRITICAL', stats.criticalCount, Colors.red),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              Text('$count (${percentage.toStringAsFixed(1)}%)', style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: count / (total > 0 ? total : 1),
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleChart(List<StressHistoryRecord> records) {
    if (records.isEmpty) return const SizedBox.shrink();

    // Simple bar chart representation
    final maxValue = records.map((r) => r.stressLevel).reduce((a, b) => a > b ? a : b);
    final width = MediaQuery.of(context).size.width - 32;
    final barWidth = width / records.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: records.map((record) {
        final height = (record.stressLevel / maxValue) * 100;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: barWidth - 4,
              height: height,
              decoration: BoxDecoration(
                color: _getStressColor(record.stressLevel),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getStressColor(double value) {
    if (value < 25) return Colors.green;
    if (value < 50) return Colors.amber;
    if (value < 75) return Colors.orange;
    return Colors.red;
  }
}
