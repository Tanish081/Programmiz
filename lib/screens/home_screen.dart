import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:programming_learn_app/constants/colors.dart';
import 'package:programming_learn_app/constants/strings.dart';
import 'package:programming_learn_app/models/language.dart';
import 'package:programming_learn_app/widgets/language_square_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Sample data
  final List<Language> myLanguages = [
    Language(
      id: 'python',
      name: AppStrings.python,
      emoji: '🐍',
      logoUrl: 'assets/logos/python.svg',
      description: 'Start with the fundamentals',
      lessonsCompleted: 12,
      totalLessons: 50,
      xpEarned: 3240,
    ),
    Language(
      id: 'javascript',
      name: AppStrings.javascript,
      emoji: '⚙️',
      logoUrl: 'assets/logos/javascript.svg',
      description: 'Master JavaScript',
      lessonsCompleted: 8,
      totalLessons: 50,
      xpEarned: 2160,
    ),
  ];

  final List<Language> availableLanguages = [
    Language(
      id: 'java',
      name: AppStrings.java,
      emoji: '☕',
      logoUrl: 'assets/logos/java.svg',
      description: 'Java Fundamentals',
      lessonsCompleted: 0,
      totalLessons: 50,
      xpEarned: 0,
    ),
    Language(
      id: 'cpp',
      name: AppStrings.cpp,
      emoji: '⚡',
      logoUrl: 'assets/logos/cplusplus.svg',
      description: 'C++ Programming',
      lessonsCompleted: 0,
      totalLessons: 50,
      xpEarned: 0,
    ),
    Language(
      id: 'golang',
      name: AppStrings.golang,
      emoji: '🐹',
      logoUrl: 'assets/logos/go.svg',
      description: 'Go Programming',
      lessonsCompleted: 0,
      totalLessons: 50,
      xpEarned: 0,
    ),
    Language(
      id: 'rust',
      name: AppStrings.rust,
      emoji: '🦀',
      logoUrl: 'assets/logos/rust.svg',
      description: 'Rust Programming',
      lessonsCompleted: 0,
      totalLessons: 50,
      xpEarned: 0,
    ),
  ];

  int totalStreak = 5;
  int totalXP = 5400;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeTitle),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Chip(
                backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                label: Text(
                  '🔥 $totalStreak',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _buildXPCard(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _buildSectionTitle(AppStrings.myLanguages),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          _buildLanguagesGridSliver(myLanguages),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _buildSectionTitle(AppStrings.availableLanguages),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          _buildLanguagesGridSliver(availableLanguages),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildXPCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen,
            AppColors.primaryGreen.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total XP',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textWhite.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalXP',
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Keep learning to earn more points!',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textWhite.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagesGridSliver(List<Language> languages) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => LanguageSquareTab(language: languages[index]),
          childCount: languages.length,
        ),
      ),
    );
  }
}
