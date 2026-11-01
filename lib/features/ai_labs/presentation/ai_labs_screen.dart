import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../data/ai_labs_repository.dart';
import '../../exercises/presentation/exercise_picker_sheet.dart';
import '../../../core/models/exercise.dart';
import '../../../core/formatting/icon_utils.dart';
import 'training_analysis_view.dart';

final selectedAiExerciseProvider = StateProvider<Exercise?>((ref) => null);

final aiInsightsProvider = FutureProvider.autoDispose.family<dynamic, String>((ref, exerciseId) async {
  final repo = ref.watch(aiLabsRepositoryProvider);
  return repo.getInsights(exerciseId);
});

class AiLabsScreen extends ConsumerStatefulWidget {
  const AiLabsScreen({super.key});

  @override
  ConsumerState<AiLabsScreen> createState() => _AiLabsScreenState();
}

class _AiLabsScreenState extends ConsumerState<AiLabsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _videoUrlController = TextEditingController();
  final _imagePicker = ImagePicker();
  
  XFile? _selectedVideo;
  bool _isLoading = false;
  Map<String, dynamic>? _analysisResult;
  String? _errorFeedback;
  bool _useUrl = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        final File file = File(video.path);
        final int sizeInBytes = await file.length();
        if (sizeInBytes > 100 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Video exceeds 100 MB limit. Please select a smaller file.'), backgroundColor: Colors.red),
            );
          }
          return;
        }
        setState(() {
          _selectedVideo = video;
          _useUrl = false;
          _analysisResult = null;
          _errorFeedback = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick video: $e')));
      }
    }
  }

  Future<void> _analyzeForm() async {
    final ex = ref.read(selectedAiExerciseProvider);
    if (ex == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select an exercise first')));
      return;
    }
    
    if (_useUrl && _videoUrlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Provide a valid YouTube URL')));
      return;
    }
    
    if (!_useUrl && _selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a video file')));
      return;
    }

    setState(() {
      _isLoading = true;
      _errorFeedback = null;
      _analysisResult = null;
    });

    try {
      final repo = ref.read(aiLabsRepositoryProvider);
      final result = await repo.analyzeForm(
        ex.name, 
        videoUrl: _useUrl ? _videoUrlController.text.trim() : null,
        filePath: !_useUrl ? _selectedVideo!.path : null,
      );
      
      setState(() {
        if (result is Map<String, dynamic>) {
          _analysisResult = result;
        } else {
          _errorFeedback = result.toString();
        }
      });
    } catch (e) {
      final errorStr = e.toString();
      setState(() {
        if (errorStr.contains('413')) {
          _errorFeedback = 'Video exceeds the 100 MB limit.';
        } else if (errorStr.contains('415')) {
          _errorFeedback = 'Unsupported video format. Please upload a supported format.';
        } else if (errorStr.contains('422')) {
          _errorFeedback = 'Invalid source or private YouTube video. For private or unlisted videos, please use local file upload instead.';
        } else if (errorStr.contains('503')) {
          _errorFeedback = 'Form analysis model is not configured on the backend. (API key missing)';
        } else {
          _errorFeedback = 'Error analyzing form: $e';
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedEx = ref.watch(selectedAiExerciseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Intelligence Labs'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Form Analysis'),
            Tab(text: 'Training Analysis'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFormAnalysisTab(theme, selectedEx),
          const TrainingAnalysisView(),
        ],
      ),
    );
  }

  Widget _buildFormAnalysisTab(ThemeData theme, Exercise? selectedEx) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.purple.shade800, Colors.deepPurple]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.psychology, size: 48, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text('Computer Vision Form Kinematics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Powered by Gemini 2.5 Flash', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('1. Select Exercise', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => Container(
                    height: MediaQuery.of(ctx).size.height * 0.85,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: _AiExercisePicker(),
                  ),
                );
              },
              icon: const Icon(Icons.fitness_center),
              label: Text(selectedEx?.name ?? 'Choose Exercise'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
            const SizedBox(height: 24),
            
            if (selectedEx != null) ...[
              _AiInsightsSection(exerciseId: selectedEx.id ?? selectedEx.name),
              const SizedBox(height: 24),
            ],

            Text('2. Select Video Source', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Local File'),
                    value: false,
                    groupValue: _useUrl,
                    onChanged: (val) => setState(() => _useUrl = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('YouTube URL'),
                    value: true,
                    groupValue: _useUrl,
                    onChanged: (val) => setState(() => _useUrl = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_useUrl) ...[
              TextField(
                controller: _videoUrlController,
                decoration: InputDecoration(
                  labelText: 'Public YouTube URL',
                  hintText: 'https://youtube.com/shorts/...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Note: Private or unlisted videos cannot be analyzed via URL. Please use local upload instead.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            ] else ...[
              OutlinedButton.icon(
                onPressed: _pickVideo,
                icon: const Icon(Icons.video_library),
                label: Text(_selectedVideo != null ? 'Change Video' : 'Pick Video from Gallery'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
              ),
              if (_selectedVideo != null) ...[
                const SizedBox(height: 8),
                Text('Selected: ${_selectedVideo!.name}', style: const TextStyle(fontSize: 12, color: Colors.green)),
              ],
            ],

            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _analyzeForm,
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: _isLoading 
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                      SizedBox(width: 12),
                      Text('Analyzing with AI...', style: TextStyle(fontSize: 16)),
                    ],
                  ) 
                : const Text('Analyze Form', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 32),
            
            if (_errorFeedback != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error_outline, color: theme.colorScheme.error),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_errorFeedback!, style: TextStyle(color: theme.colorScheme.onErrorContainer))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _analyzeForm,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ],
            
            if (_analysisResult != null) ...[
              Text('Analysis Results', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_analysisResult!['form_score'] != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Form Score:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${_analysisResult!['form_score']} / 10', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 18)),
                        ],
                      ),
                      const Divider(height: 24),
                    ],
                    if (_analysisResult!['range_of_motion'] != null) ...[
                      Text('Range of Motion: ${_analysisResult!['range_of_motion']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                    ],
                    const Text('Coaching Feedback:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${_analysisResult!['feedback'] ?? _analysisResult.toString()}'),
                    if (_analysisResult!['model'] != null) ...[
                      const SizedBox(height: 16),
                      Text('Model: ${_analysisResult!['model']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ],
                ),
              ),
            ]
          ],
        ),
      );
  }
}

class _AiExercisePicker extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AiExercisePicker> createState() => _AiExercisePickerState();
}

class _AiExercisePickerState extends ConsumerState<_AiExercisePicker> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercisesAsync = ref.watch(exerciseListProvider);
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Select Exercise', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            onChanged: (val) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                ref.read(exerciseSearchProvider.notifier).state = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search library...', prefixIcon: const Icon(Icons.search), filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: exercisesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(e.toString()),
                  TextButton(
                    onPressed: () => ref.invalidate(exerciseListProvider),
                    child: const Text('Retry'),
                  )
                ],
              ),
            ),
            data: (exercises) => ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (ctx, i) {
                final ex = exercises[i];
                return ListTile(
                  leading: Icon(getIconForExercise(ex.name), color: theme.colorScheme.primary),
                  title: Text(ex.name),
                  subtitle: Text(ex.muscleGroup),
                  onTap: () {
                    ref.read(selectedAiExerciseProvider.notifier).state = ex;
                    Navigator.pop(ctx);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _AiInsightsSection extends ConsumerWidget {
  final String exerciseId;

  const _AiInsightsSection({required this.exerciseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final insightsAsync = ref.watch(aiInsightsProvider(exerciseId));

    return insightsAsync.when(
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())),
      error: (e, st) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: theme.colorScheme.errorContainer, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Text('Error loading insights: $e', style: TextStyle(color: theme.colorScheme.onErrorContainer)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(aiInsightsProvider(exerciseId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (data) {
        if (data == null) return const SizedBox.shrink();
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, size: 20, color: theme.colorScheme.secondary),
                  const SizedBox(width: 8),
                  Text('Overall Workout Insights', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Text(data.toString(), style: theme.textTheme.bodyMedium),
            ],
          ),
        );
      },
    );
  }
}

