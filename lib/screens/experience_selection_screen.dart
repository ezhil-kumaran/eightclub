import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/experience.dart';
import '../providers/experience_provider.dart';
import '../theme.dart';
import '../widgets/experience_card.dart';
import 'question_screen.dart';

class ExperienceSelectionScreen extends ConsumerWidget {
  const ExperienceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experiencesAsync = ref.watch(experiencesProvider);
    final selectionState = ref.watch(experienceSelectionProvider);

    return Scaffold(
      backgroundColor: AppTheme.base2Dark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.text1),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildProgressIndicator(),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppTheme.text1),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: experiencesAsync.when(
        data: (experiences) =>
            _buildContent(context, ref, experiences, selectionState),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryAccent),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading experiences',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(experiencesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      height: 4,
      width: 200,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.text4.withOpacity(0.24),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<Experience> experiences,
    ExperienceSelectionState selectionState,
  ) {
    // Reorder experiences: selected ones first
    final orderedExperiences = _reorderExperiences(
      experiences,
      selectionState.selectedIds,
    );

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'What kind of hotspots do you want to host?',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 32),
                _buildExperienceGrid(
                  context,
                  ref,
                  orderedExperiences,
                  selectionState.selectedIds,
                ),
                const SizedBox(height: 24),
                _buildDescriptionField(context, ref, selectionState),
              ],
            ),
          ),
        ),
        _buildNextButton(context, ref, selectionState),
      ],
    );
  }

  List<Experience> _reorderExperiences(
    List<Experience> experiences,
    List<int> selectedIds,
  ) {
    final selected = experiences
        .where((e) => selectedIds.contains(e.id))
        .toList();
    final unselected = experiences
        .where((e) => !selectedIds.contains(e.id))
        .toList();
    return [...selected, ...unselected];
  }

  Widget _buildExperienceGrid(
    BuildContext context,
    WidgetRef ref,
    List<Experience> experiences,
    List<int> selectedIds,
  ) {
    // Make the experiences scroll horizontally instead of vertically.
    // Constrain the height so the horizontal ListView doesn't cause unbounded
    // height inside the parent SingleChildScrollView and to avoid overflow.
    const double cardWidth = 120; // adjust as needed
    const double cardHeight = 120; // adjust as needed

    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: experiences.length,
        separatorBuilder: (context, index) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          final experience = experiences[index];
          final isSelected = selectedIds.contains(experience.id);

          return SizedBox(
            width: cardWidth,
            child: ExperienceCard(
              experience: experience,
              isSelected: isSelected,
              onTap: () {
                ref
                    .read(experienceSelectionProvider.notifier)
                    .toggleExperience(experience.id);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDescriptionField(
    BuildContext context,
    WidgetRef ref,
    ExperienceSelectionState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          maxLines: 4,
          maxLength: 250,
          style: const TextStyle(color: AppTheme.text1),
          decoration: InputDecoration(
            hintText: '/ Describe your perfect hotspot',
            hintStyle: TextStyle(color: AppTheme.text3.withOpacity(0.46)),
            counterStyle: TextStyle(color: AppTheme.text4.withOpacity(0.24)),
          ),
          onChanged: (value) {
            ref
                .read(experienceSelectionProvider.notifier)
                .updateDescription(value);
          },
        ),
      ],
    );
  }

  Widget _buildNextButton(
    BuildContext context,
    WidgetRef ref,
    ExperienceSelectionState state,
  ) {
    final canProceed = state.selectedIds.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.base2Dark,
        border: Border(
          top: BorderSide(color: AppTheme.border1.withOpacity(0.08), width: 1),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: canProceed
                ? () {
                    // Log the state
                    print('Selected IDs: ${state.selectedIds}');
                    print('Description: ${state.description}');

                    // Navigate to question screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuestionScreen(),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canProceed
                  ? AppTheme.primaryAccent
                  : AppTheme.surfaceWhite1.withOpacity(0.05),
              foregroundColor: AppTheme.text1,
              disabledBackgroundColor: AppTheme.surfaceWhite1.withOpacity(0.05),
              disabledForegroundColor: AppTheme.text4.withOpacity(0.24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: canProceed ? AppTheme.text1 : AppTheme.text4,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  color: canProceed ? AppTheme.text1 : AppTheme.text4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
