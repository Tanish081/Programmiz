import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_learn_app/data/models/roadmap_model.dart';
import 'package:programming_learn_app/data/models/user_profile_model.dart';
import 'package:programming_learn_app/data/repositories/roadmap_repository.dart';

final roadmapRepositoryProvider = Provider<RoadmapRepository>((ref) {
  return RoadmapRepository();
});

class RoadmapState {
  const RoadmapState({
    this.roadmap,
    this.isLoading = false,
    this.isStreaming = false,
    this.streamingText = '',
    this.error,
  });

  final RoadmapModel? roadmap;
  final bool isLoading;
  final bool isStreaming;
  final String streamingText;
  final String? error;

  RoadmapState copyWith({
    RoadmapModel? roadmap,
    bool? isLoading,
    bool? isStreaming,
    String? streamingText,
    String? error,
    bool clearError = false,
  }) {
    return RoadmapState(
      roadmap: roadmap ?? this.roadmap,
      isLoading: isLoading ?? this.isLoading,
      isStreaming: isStreaming ?? this.isStreaming,
      streamingText: streamingText ?? this.streamingText,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class RoadmapNotifier extends StateNotifier<RoadmapState> {
  RoadmapNotifier(this._ref) : super(const RoadmapState());

  final Ref _ref;
  Timer? _typingTimer;

  Future<void> loadOrGenerate(String language, UserProfile profile) async {
    state = state.copyWith(
      isLoading: true,
      isStreaming: true,
      streamingText: '',
      clearError: true,
    );

    _startTypingAnimation('🦉 Building your personalised roadmap...');

    try {
      final repository = _ref.read(roadmapRepositoryProvider);
      final roadmap = await repository.generateRoadmap(
        language: language,
        profile: profile,
      );

      _typingTimer?.cancel();
      state = state.copyWith(
        roadmap: roadmap,
        isLoading: false,
        isStreaming: false,
      );
    } catch (e) {
      _typingTimer?.cancel();
      state = state.copyWith(
        isLoading: false,
        isStreaming: false,
        error: e.toString(),
      );
    }
  }

  Future<void> markTopicComplete(String topicId) async {
    final roadmap = state.roadmap;
    if (roadmap == null) {
      return;
    }

    final repository = _ref.read(roadmapRepositoryProvider);
    await repository.markTopicComplete(roadmap.id, topicId);

    final refreshed = await repository.getCachedRoadmap(roadmap.language);
    if (refreshed != null) {
      state = state.copyWith(roadmap: refreshed);
    }
  }

  Future<void> regenerate(
    String language,
    UserProfile profile,
    String? feedback,
  ) async {
    state = state.copyWith(
      isLoading: true,
      isStreaming: true,
      streamingText: '',
      clearError: true,
    );

    _startTypingAnimation('🧠 Regenerating your roadmap with your feedback...');

    try {
      final repository = _ref.read(roadmapRepositoryProvider);
      final roadmap = await repository.generateRoadmap(
        language: language,
        profile: profile,
        forceRegenerate: true,
      );

      _typingTimer?.cancel();
      state = state.copyWith(
        roadmap: roadmap,
        isLoading: false,
        isStreaming: false,
      );
    } catch (e) {
      _typingTimer?.cancel();
      state = state.copyWith(
        isLoading: false,
        isStreaming: false,
        error: e.toString(),
      );
    }
  }

  void _startTypingAnimation(String text) {
    _typingTimer?.cancel();
    var index = 0;

    _typingTimer = Timer.periodic(const Duration(milliseconds: 45), (timer) {
      if (index >= text.length) {
        timer.cancel();
        return;
      }

      index += 1;
      state = state.copyWith(streamingText: text.substring(0, index));
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }
}

final roadmapProvider = StateNotifierProvider<RoadmapNotifier, RoadmapState>((ref) {
  return RoadmapNotifier(ref);
});
