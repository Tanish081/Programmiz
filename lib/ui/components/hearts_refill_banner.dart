import 'dart:async';
import 'package:flutter/material.dart';
import 'package:programming_learn_app/data/services/preferences_service.dart';

class HeartsRefillBanner extends StatefulWidget {
  final VoidCallback? onClose;

  const HeartsRefillBanner({
    super.key,
    this.onClose,
  });

  @override
  State<HeartsRefillBanner> createState() => _HeartsRefillBannerState();
}

class _HeartsRefillBannerState extends State<HeartsRefillBanner> {
  late Timer _timer;
  String _countdownText = '';

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  Future<void> _updateCountdown() async {
    final prefsService = PreferencesService();
    final emptySince = await prefsService.getHeartsEmptySince();

    if (emptySince == null) {
      if (mounted) {
        widget.onClose?.call();
      }
      return;
    }

    final now = DateTime.now();
    final refillAt = emptySince.add(const Duration(minutes: 30));
    final remaining = refillAt.difference(now);

    if (remaining.isNegative) {
      // Refill ready
      await prefsService.setLives(5);
      await prefsService.restoreHeartsIfReady();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your hearts have been restored! ❤️'),
            duration: Duration(seconds: 2),
          ),
        );
        widget.onClose?.call();
      }
      return;
    }

    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    final time = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    if (mounted) {
      setState(() {
        _countdownText = time;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _showGetHeartsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => GetHeartsBottomSheet(
        onRefillReview: _updateCountdown,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF4B4B), width: 2),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const Text('❤️', style: TextStyle(fontSize: 28)),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4B4B),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "You're out of hearts!",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Refills in $_countdownText',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFFF4B4B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: ElevatedButton(
              onPressed: _showGetHeartsSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58CC02),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Get Hearts',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GetHeartsBottomSheet extends StatelessWidget {
  final VoidCallback onRefillReview;

  const GetHeartsBottomSheet({
    super.key,
    required this.onRefillReview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Get more hearts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Wait option
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('⏱', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wait 30 minutes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Refill time resets daily',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7FFB8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'FREE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF58CC02),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Practice option
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              // Navigate to home and let user select a lesson
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]!, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('📚', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Review a completed lesson',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Reviewing restores 1 heart',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7FFB8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'FREE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF58CC02),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Maybe later',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
