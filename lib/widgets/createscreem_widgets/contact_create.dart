import 'package:flutter/material.dart';

class SocialPlatform {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String hint;
  final String Function(String input) buildUrl;

  const SocialPlatform({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.hint,
    required this.buildUrl,
  });
}

final List<SocialPlatform> kSocialPlatforms = [
  SocialPlatform(
    id: 'instagram',
    name: 'Instagram',
    icon: Icons.photo_camera_outlined,
    color: const Color(0xFFE1306C),
    hint: '@username',
    buildUrl: (u) =>
        'https://instagram.com/${u.replaceFirst(RegExp(r'^@'), '')}',
  ),
  SocialPlatform(
    id: 'x',
    name: 'X / Twitter',
    icon: Icons.close,
    color: const Color(0xFF000000),
    hint: '@username',
    buildUrl: (u) => 'https://x.com/${u.replaceFirst(RegExp(r'^@'), '')}',
  ),
  SocialPlatform(
    id: 'facebook',
    name: 'Facebook',
    icon: Icons.facebook,
    color: const Color(0xFF1877F2),
    hint: 'username or page',
    buildUrl: (u) => 'https://facebook.com/$u',
  ),
  SocialPlatform(
    id: 'linkedin',
    name: 'LinkedIn',
    icon: Icons.work_outline,
    color: const Color(0xFF0A66C2),
    hint: 'your-profile-name',
    buildUrl: (u) => 'https://linkedin.com/in/$u',
  ),
  SocialPlatform(
    id: 'tiktok',
    name: 'TikTok',
    icon: Icons.music_note_outlined,
    color: const Color(0xFF010101),
    hint: '@username',
    buildUrl: (u) => 'https://tiktok.com/@${u.replaceFirst(RegExp(r'^@'), '')}',
  ),
  SocialPlatform(
    id: 'youtube',
    name: 'YouTube',
    icon: Icons.play_circle_outline,
    color: const Color(0xFFFF0000),
    hint: '@channelname',
    buildUrl: (u) =>
        'https://youtube.com/@${u.replaceFirst(RegExp(r'^@'), '')}',
  ),
  SocialPlatform(
    id: 'snapchat',
    name: 'Snapchat',
    icon: Icons.snapchat_outlined,
    color: const Color(0xFFFFFC00),
    hint: 'username',
    buildUrl: (u) => 'https://snapchat.com/add/$u',
  ),
  SocialPlatform(
    id: 'whatsapp',
    name: 'WhatsApp',
    icon: Icons.chat_outlined,
    color: const Color(0xFF25D366),
    hint: '+1234567890 (with country code)',
    buildUrl: (u) => 'https://wa.me/${u.replaceAll(RegExp(r'[^0-9]'), '')}',
  ),
  SocialPlatform(
    id: 'telegram',
    name: 'Telegram',
    icon: Icons.send_outlined,
    color: const Color(0xFF0088CC),
    hint: '@username',
    buildUrl: (u) => 'https://t.me/${u.replaceFirst(RegExp(r'^@'), '')}',
  ),
  SocialPlatform(
    id: 'github',
    name: 'GitHub',
    icon: Icons.code_outlined,
    color: const Color(0xFF6E5494),
    hint: 'username',
    buildUrl: (u) => 'https://github.com/$u',
  ),
];

class ContactCreate extends StatefulWidget {
  const ContactCreate({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<ContactCreate> createState() => _ContactCreateState();
}

class _ContactCreateState extends State<ContactCreate> {
  SocialPlatform _selected = kSocialPlatforms.first;
  final _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _notify() {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      widget.onChanged('');
      return;
    }
    widget.onChanged(_selected.buildUrl(input));
  }

  void _selectPlatform(SocialPlatform platform) {
    setState(() {
      _selected = platform;
      _inputController.clear();
    });
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Platform'.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: kSocialPlatforms.map((platform) {
              final isSelected = _selected.id == platform.id;
              return GestureDetector(
                onTap: () => _selectPlatform(platform),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isSelected
                        ? platform.color.withValues(alpha: 0.15)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: isSelected ? platform.color : Colors.grey[700]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Icon(
                    platform.icon,
                    size: 24,
                    color: isSelected ? platform.color : Colors.grey[500],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: _selected.color.withValues(alpha: 0.15),
                ),
                child: Icon(_selected.icon, size: 20, color: _selected.color),
              ),
              const SizedBox(width: 10),
              Text(
                _selected.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _inputController,
            onChanged: (_) => _notify(),
            decoration: InputDecoration(
              hintText: _selected.hint,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              filled: true,
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.grey[500]!),
              ),
              suffixIcon: Icon(
                _selected.icon,
                size: 20,
                color: _selected.color.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
