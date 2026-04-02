import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:programming_learn_app/constants/colors.dart';
import 'package:programming_learn_app/constants/strings.dart';
import 'package:programming_learn_app/models/language.dart';

class LanguageSquareTab extends StatelessWidget {
  const LanguageSquareTab({super.key, required this.language});

  final Language language;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          final action = language.lessonsCompleted > 0
              ? AppStrings.continueLesson
              : AppStrings.startLesson;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$action ${language.name}'),
              duration: const Duration(milliseconds: 900),
            ),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: _buildLogo(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  language.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  language.lessonsCompleted > 0
                      ? '${language.lessonsCompleted}/${language.totalLessons} lessons'
                      : 'New track',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    if (language.logoUrl == null || language.logoUrl!.isEmpty) {
      return Text(language.emoji, style: const TextStyle(fontSize: 36));
    }

    if (language.logoUrl!.startsWith('assets/')) {
      return SvgPicture.asset(
        language.logoUrl!,
        width: 48,
        height: 48,
      );
    }

    return SvgPicture.network(
      language.logoUrl!,
      width: 48,
      height: 48,
      placeholderBuilder: (_) => Text(
        language.emoji,
        style: const TextStyle(fontSize: 36),
      ),
    );
  }
}
