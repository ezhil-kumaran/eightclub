import 'package:flutter/material.dart';
// removed unused import
import '../models/experience.dart';
import '../theme.dart';

class ExperienceCard extends StatefulWidget {
  final Experience experience;
  final bool isSelected;
  final VoidCallback onTap;

  const ExperienceCard({
    super.key,
    required this.experience,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<ExperienceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected
                  ? AppTheme.primaryAccent
                  : AppTheme.border1.withOpacity(0.08),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryAccent.withOpacity(0.2),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image
                _buildBackgroundImage(),

                // Gradient Overlay
                _buildGradientOverlay(),

                // Content: keep content aligned to the bottom, but show
                // icon to the left of the text (instead of above it).
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (widget.experience.iconUrl.isNotEmpty)
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: widget.isSelected
                                    ? AppTheme.primaryAccent.withOpacity(0.2)
                                    : AppTheme.surfaceWhite1.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),

                          if (widget.experience.iconUrl.isNotEmpty)
                            const SizedBox(width: 12),

                          // Title + Tagline stacked vertically, and allowed to
                          // take the remaining width.
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return ColorFiltered(
      colorFilter: widget.isSelected
          ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
          : const ColorFilter.matrix([
              0.2126, 0.7152, 0.0722, 0, 0, // Red channel
              0.2126, 0.7152, 0.0722, 0, 0, // Green channel
              0.2126, 0.7152, 0.0722, 0, 0, // Blue channel
              0, 0, 0, 1, 0, // Alpha channel
            ]),
      child: Image.network(
        widget.experience.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppTheme.surfaceBlack1,
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              color: AppTheme.text4,
              size: 40,
            ),
          ),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppTheme.surfaceBlack1,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryAccent,
                strokeWidth: 2,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(widget.isSelected ? 0.7 : 0.85),
          ],
          stops: const [0.4, 1.0],
        ),
      ),
    );
  }
}
