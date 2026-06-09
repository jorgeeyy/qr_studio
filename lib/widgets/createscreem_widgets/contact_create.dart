import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class SocialPlatform {
  final String id;
  final String name;
  final Widget Function(Color color, double size) icon;
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

const double kSocialIconSize = 24.0;

final List<SocialPlatform> kSocialPlatforms = [
  SocialPlatform(
    id: 'instagram',
    name: 'Instagram',
    icon: (color, size) => HugeIcon(
      icon: HugeIcons.strokeRoundedInstagram,
      color: color,
      size: size,
    ),
    color: const Color(0xFFE1306C),
    hint: '@username',
    buildUrl: (u) =>
        'https://instagram.com/${u.replaceFirst(RegExp(r'^@'), '')}',
  ),
  SocialPlatform(
    id: 'x',
    name: 'X / Twitter',
    icon: (color, size) => HugeIcon(
      icon: HugeIcons.strokeRoundedNewTwitter,
      color: color,
      size: size,
    ),
    color: const Color(0xFF000000),
    hint: '@username',
    buildUrl: (u) => 'https://x.com/${u.replaceFirst(RegExp(r'^@'), '')}',
  ),
  SocialPlatform(
    id: 'facebook',
    name: 'Facebook',
    icon: (color, size) => HugeIcon(
      icon: HugeIcons.strokeRoundedFacebook01,
      color: color,
      size: size,
    ),
    color: const Color(0xFF1877F2),
    hint: 'username or page',
    buildUrl: (u) => 'https://facebook.com/$u',
  ),
  SocialPlatform(
    id: 'linkedin',
    name: 'LinkedIn',
    icon: (color, size) => HugeIcon(
      icon: HugeIcons.strokeRoundedLinkedin01,
      color: color,
      size: size,
    ),
    color: const Color(0xFF0A66C2),
    hint: 'your-profile-name',
    buildUrl: (u) => 'https://linkedin.com/in/$u',
  ),
  SocialPlatform(
    id: 'tiktok',
    name: 'TikTok',
    icon: (color, size) =>
        HugeIcon(icon: HugeIcons.strokeRoundedTiktok, color: color, size: size),
    color: const Color(0xFF010101),
    hint: '@username',
    buildUrl: (u) => 'https://tiktok.com/@${u.replaceFirst(RegExp(r'^@'), '')}',
  ),
  SocialPlatform(
    id: 'youtube',
    name: 'YouTube',
    icon: (color, size) => HugeIcon(
      icon: HugeIcons.strokeRoundedYoutube,
      color: color,
      size: size,
    ),
    color: const Color(0xFFFF0000),
    hint: '@channelname',
    buildUrl: (u) =>
        'https://youtube.com/@${u.replaceFirst(RegExp(r'^@'), '')}',
  ),
  SocialPlatform(
    id: 'snapchat',
    name: 'Snapchat',
    icon: (color, size) => HugeIcon(
      icon: HugeIcons.strokeRoundedSnapchat,
      color: color,
      size: size,
    ),
    color: const Color(0xFFFFFC00),
    hint: 'username',
    buildUrl: (u) => 'https://snapchat.com/add/$u',
  ),
  SocialPlatform(
    id: 'whatsapp',
    name: 'WhatsApp',
    icon: (color, size) => HugeIcon(
      icon: HugeIcons.strokeRoundedWhatsapp,
      color: color,
      size: size,
    ),
    color: const Color(0xFF25D366),
    hint: '+1234567890 (with country code)',
    buildUrl: (u) => 'https://wa.me/${u.replaceAll(RegExp(r'[^0-9]'), '')}',
  ),
  SocialPlatform(
    id: 'telegram',
    name: 'Telegram',
    icon: (color, size) => HugeIcon(
      icon: HugeIcons.strokeRoundedTelegram,
      color: color,
      size: size,
    ),
    color: const Color(0xFF0088CC),
    hint: '@username',
    buildUrl: (u) => 'https://t.me/${u.replaceFirst(RegExp(r'^@'), '')}',
  ),
  SocialPlatform(
    id: 'github',
    name: 'GitHub',
    icon: (color, size) =>
        HugeIcon(icon: HugeIcons.strokeRoundedGithub, color: color, size: size),
    color: const Color(0xFF6E5494),
    hint: 'username',
    buildUrl: (u) => 'https://github.com/$u',
  ),
];

// Reusable helper to render a sized, centered HugeIcon
Widget _buildIcon(
  Widget Function(Color, double) iconBuilder,
  Color color,
  double size,
) {
  return Center(
    child: SizedBox(width: size, height: size, child: iconBuilder(color, size)),
  );
}

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
                  alignment: Alignment.center, // ← ensures icon is centered
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
                  child: _buildIcon(
                    platform.icon,
                    isSelected ? platform.color : Colors.grey[500]!,
                    kSocialIconSize,
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
                alignment: Alignment.center, // ← same fix
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: _selected.color.withValues(alpha: 0.15),
                ),
                child: _buildIcon(
                  _selected.icon,
                  _selected.color,
                  kSocialIconSize,
                ),
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
            ),
          ),
        ],
      ),
    );
  }
}
