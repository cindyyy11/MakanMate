import 'package:flutter/material.dart';
import 'package:makan_mate/core/ml/model_tester.dart';
import 'package:makan_mate/ai_engine/recommendation_engine.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Developer screen for testing and validating the TFLite recommendation model
///
/// This screen provides comprehensive testing capabilities to ensure
/// the model is working correctly before using it in production
class ModelTestingScreen extends StatefulWidget {
  const ModelTestingScreen({super.key});

  @override
  State<ModelTestingScreen> createState() => _ModelTestingScreenState();
}

class _ModelTestingScreenState extends State<ModelTestingScreen> {
  final ModelTester _tester = ModelTester();
  final RecommendationEngine _engine = RecommendationEngine();

  bool _isRunningTests = false;
  ModelTestResult? _testResult;
  bool _isGeneratingRecs = false;
  int _recommendationCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeEngine();
  }

  Future<void> _initializeEngine() async {
    try {
      await _engine.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing engine: $e');
    }
  }

  Future<void> _runModelTests() async {
    setState(() {
      _isRunningTests = true;
      _testResult = null;
    });

    try {
      final result = await _tester.runTests();
      setState(() {
        _testResult = result;
        _isRunningTests = false;
      });

      if (result.passed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('All tests passed! ${result.summary}'),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isRunningTests = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test execution failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateTestRecommendations() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to test recommendations'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingRecs = true;
      _recommendationCount = 0;
    });

    try {
      await _tester.generateTestRecommendations(user.uid);

      // Get actual recommendations to count
      final recs = await _engine.getRecommendations(
        userId: user.uid,
        limit: 10,
      );

      setState(() {
        _recommendationCount = recs.length;
        _isGeneratingRecs = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white),
                const SizedBox(width: 8),
                Text('Generated ${recs.length} recommendations'),
              ],
            ),
            backgroundColor: Colors.purple,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGeneratingRecs = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate recommendations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Testing & Validation'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStatusCard(),
            _buildTestSection(),
            if (_testResult != null) _buildResultsSection(),
            _buildRecommendationTestSection(),
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.aiGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.aiShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _engine.isModelLoaded ? Icons.check_circle : Icons.pending,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Model Status',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _engine.isModelLoaded ? 'Loaded & Ready' : 'Not Loaded',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_engine.isModelLoaded) ...[
            const Divider(color: Colors.white38, height: 32),
            _buildInfoRow('Input Shape', '${_engine.inputShapes}'),
            const SizedBox(height: 8),
            _buildInfoRow('Output Shape', '${_engine.outputShapes}'),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTestSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.science, color: AppColors.aiAccent),
                const SizedBox(width: 12),
                const Text(
                  'Model Validation Tests',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Run comprehensive tests to validate model functionality',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isRunningTests ? null : _runModelTests,
                icon: _isRunningTests
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(
                  _isRunningTests ? 'Running Tests...' : 'Run All Tests',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.aiSecondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _testResult!.passed ? Icons.check_circle : Icons.error,
                  color: _testResult!.passed
                      ? AppColors.success
                      : AppColors.error,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _testResult!.passed
                            ? 'All Tests Passed'
                            : 'Tests Failed',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _testResult!.passed
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      Text(
                        _testResult!.summary,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...(_testResult!.messages.map(
              (msg) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      msg.startsWith('✓')
                          ? Icons.check_circle_outline
                          : msg.startsWith('✗')
                          ? Icons.error_outline
                          : Icons.info_outline,
                      size: 18,
                      color: msg.startsWith('✓')
                          ? AppColors.success
                          : msg.startsWith('✗')
                          ? AppColors.error
                          : AppColors.info,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        msg,
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationTestSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.aiAccent),
                const SizedBox(width: 12),
                const Text(
                  'Live Recommendation Test',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Generate actual recommendations using your profile',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            if (_recommendationCount > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.aiPrimary.withOpacity(0.1),
                  borderRadius: UIConstants.borderRadiusSm,
                  border: Border.all(color: AppColors.aiAccent),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: AppColors.aiPrimary,
                      size: UIConstants.iconSizeMd,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Successfully generated $_recommendationCount personalized recommendations',
                        style: const TextStyle(
                          color: AppColors.aiPrimary,
                          fontSize: UIConstants.fontSizeSm,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGeneratingRecs
                    ? null
                    : _generateTestRecommendations,
                icon: _isGeneratingRecs
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.stars),
                label: Text(
                  _isGeneratingRecs
                      ? 'Generating...'
                      : 'Generate Test Recommendations',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.aiPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: AppColors.infoLight),
                const SizedBox(width: 12),
                const Text(
                  'About the Model',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoTile(
              'Algorithm',
              'Hybrid Recommendation System',
              Icons.merge_type,
            ),
            _buildInfoTile(
              'Approach',
              'Collaborative + Content-Based + Contextual',
              Icons.layers,
            ),
            _buildInfoTile(
              'Model Type',
              'TensorFlow Lite Neural Network',
              Icons.hub,
            ),
            _buildInfoTile(
              'Features',
              '${RecommendationEngine.USER_FEATURE_DIM} user + ${RecommendationEngine.ITEM_FEATURE_DIM} item dimensions',
              Icons.view_module,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: UIConstants.borderRadiusSm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    color: AppColors.infoDark,
                    size: UIConstants.iconSizeMd,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This model learns from user interactions to provide increasingly accurate recommendations over time.',
                      style: const TextStyle(
                        color: AppColors.infoDark,
                        fontSize: UIConstants.fontSizeSm,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: UIConstants.iconSizeMd,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
