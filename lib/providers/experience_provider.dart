import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/experience.dart';
import '../services/api_service.dart';

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Experience List Provider
final experiencesProvider = FutureProvider<List<Experience>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  final response = await apiService.getExperiences();
  return response.experiences;
});

// Selected Experiences State
class ExperienceSelectionState {
  final List<int> selectedIds;
  final String description;

  ExperienceSelectionState({
    this.selectedIds = const [],
    this.description = '',
  });

  ExperienceSelectionState copyWith({
    List<int>? selectedIds,
    String? description,
  }) {
    return ExperienceSelectionState(
      selectedIds: selectedIds ?? this.selectedIds,
      description: description ?? this.description,
    );
  }
}

class ExperienceSelectionNotifier
    extends StateNotifier<ExperienceSelectionState> {
  ExperienceSelectionNotifier() : super(ExperienceSelectionState());

  void toggleExperience(int id) {
    final currentIds = List<int>.from(state.selectedIds);
    if (currentIds.contains(id)) {
      currentIds.remove(id);
    } else {
      currentIds.add(id);
    }
    state = state.copyWith(selectedIds: currentIds);
  }

  void updateDescription(String description) {
    if (description.length <= 250) {
      state = state.copyWith(description: description);
    }
  }

  void reset() {
    state = ExperienceSelectionState();
  }
}

final experienceSelectionProvider =
    StateNotifierProvider<
      ExperienceSelectionNotifier,
      ExperienceSelectionState
    >((ref) => ExperienceSelectionNotifier());

// Question Answer State
class QuestionAnswerState {
  final String textAnswer;
  final String? audioPath;
  final String? videoPath;

  QuestionAnswerState({this.textAnswer = '', this.audioPath, this.videoPath});

  QuestionAnswerState copyWith({
    String? textAnswer,
    String? audioPath,
    String? videoPath,
  }) {
    return QuestionAnswerState(
      textAnswer: textAnswer ?? this.textAnswer,
      audioPath: audioPath,
      videoPath: videoPath,
    );
  }
}

class QuestionAnswerNotifier extends StateNotifier<QuestionAnswerState> {
  QuestionAnswerNotifier() : super(QuestionAnswerState());

  void updateTextAnswer(String text) {
    if (text.length <= 600) {
      state = state.copyWith(textAnswer: text);
    }
  }

  void setAudioPath(String? path) {
    state = state.copyWith(audioPath: path);
  }

  void setVideoPath(String? path) {
    state = state.copyWith(videoPath: path);
  }

  void clearAudio() {
    state = state.copyWith(audioPath: null);
  }

  void clearVideo() {
    state = state.copyWith(videoPath: null);
  }

  void reset() {
    state = QuestionAnswerState();
  }
}

final questionAnswerProvider =
    StateNotifierProvider<QuestionAnswerNotifier, QuestionAnswerState>(
      (ref) => QuestionAnswerNotifier(),
    );
