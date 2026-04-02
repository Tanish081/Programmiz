import 'package:flutter/material.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/ui/components/duo_button.dart';

class ProfileEditResult {
  const ProfileEditResult({
    required this.name,
    required this.avatarId,
    required this.dailyGoalXP,
  });

  final String name;
  final String avatarId;
  final int dailyGoalXP;
}

Future<ProfileEditResult?> showEditProfileBottomSheet({
  required BuildContext context,
  required String initialName,
  required String initialAvatarId,
  required int initialDailyGoalXP,
}) {
  return showModalBottomSheet<ProfileEditResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.background,
    builder: (context) {
      return _EditProfileSheet(
        initialName: initialName,
        initialAvatarId: initialAvatarId,
        initialDailyGoalXP: initialDailyGoalXP,
      );
    },
  );
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({
    required this.initialName,
    required this.initialAvatarId,
    required this.initialDailyGoalXP,
  });

  final String initialName;
  final String initialAvatarId;
  final int initialDailyGoalXP;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  static const List<String> _avatars = ['🦊', '🐼', '🦁', '🐸', '🐧', '🤖'];

  late final TextEditingController _nameController;
  late String _avatarId;
  late double _goalXp;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _avatarId = widget.initialAvatarId;
    _goalXp = widget.initialDailyGoalXP.toDouble();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _avatarEmoji(String avatarId) {
    switch (avatarId) {
      case 'avatar_1':
        return _avatars[0];
      case 'avatar_2':
        return _avatars[1];
      case 'avatar_3':
        return _avatars[2];
      case 'avatar_4':
        return _avatars[3];
      case 'avatar_5':
        return _avatars[4];
      default:
        return _avatars[5];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              maxLength: 20,
            ),
            const SizedBox(height: 4),
            const Text('Avatar', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List<Widget>.generate(_avatars.length, (index) {
                final id = 'avatar_${index + 1}';
                final selected = _avatarId == id;
                return InkWell(
                  onTap: () => setState(() => _avatarId = id),
                  child: Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: selected ? AppColors.primary : AppColors.outline, width: selected ? 2.5 : 1),
                      color: Colors.white,
                    ),
                    child: Text(_avatarEmoji(id), style: const TextStyle(fontSize: 28)),
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),
            Text('Daily Goal XP: ${_goalXp.round()}', style: const TextStyle(fontWeight: FontWeight.w800)),
            Slider(
              value: _goalXp,
              min: 10,
              max: 120,
              divisions: 11,
              activeColor: AppColors.primary,
              label: _goalXp.round().toString(),
              onChanged: (value) => setState(() => _goalXp = value),
            ),
            const SizedBox(height: 6),
            DuoButton(
              label: 'Save Profile',
              onPressed: () {
                final name = _nameController.text.trim();
                if (name.isEmpty) {
                  return;
                }
                Navigator.pop(
                  context,
                  ProfileEditResult(
                    name: name,
                    avatarId: _avatarId,
                    dailyGoalXP: _goalXp.round(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}