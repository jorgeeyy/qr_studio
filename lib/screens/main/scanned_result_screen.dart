import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi_iot/wifi_iot.dart';

// ── Content type detection ──────────────────────────────────────────────────

enum ScannedContentType { url, email, phone, wifi, text }

class _ContentInfo {
  final ScannedContentType type;
  final String label;
  final IconData icon;
  final Color accentColor;

  const _ContentInfo({
    required this.type,
    required this.label,
    required this.icon,
    required this.accentColor,
  });
}

_ContentInfo _classify(String data) {
  final trimmed = data.trim();

  // URL
  if (RegExp(r'^https?://', caseSensitive: false).hasMatch(trimmed) ||
      RegExp(r'^www\.', caseSensitive: false).hasMatch(trimmed)) {
    return const _ContentInfo(
      type: ScannedContentType.url,
      label: 'Website',
      icon: Icons.language_rounded,
      accentColor: Color(0xFF4A90D9),
    );
  }

  // Email  (mailto: prefix or bare email)
  if (trimmed.startsWith('mailto:') ||
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed)) {
    return const _ContentInfo(
      type: ScannedContentType.email,
      label: 'Email',
      icon: Icons.email_rounded,
      accentColor: Color(0xFFE57373),
    );
  }

  // Phone  (tel: prefix or number-like)
  if (trimmed.startsWith('tel:') ||
      RegExp(r'^\+?[\d\s\-().]{7,}$').hasMatch(trimmed)) {
    return const _ContentInfo(
      type: ScannedContentType.phone,
      label: 'Phone Number',
      icon: Icons.phone_rounded,
      accentColor: Color(0xFF66BB6A),
    );
  }

  // WiFi (WIFI:S:…)
  if (trimmed.toUpperCase().startsWith('WIFI:')) {
    return const _ContentInfo(
      type: ScannedContentType.wifi,
      label: 'Wi-Fi Network',
      icon: Icons.wifi_rounded,
      accentColor: Color(0xFFAB47BC),
    );
  }

  // Fallback
  return const _ContentInfo(
    type: ScannedContentType.text,
    label: 'Text',
    icon: Icons.text_snippet_rounded,
    accentColor: Color(0xFF78909C),
  );
}

// ── WiFi field parser ───────────────────────────────────────────────────────

Map<String, String> _parseWifi(String raw) {
  // WIFI:S:<ssid>;T:<type>;P:<password>;H:<hidden>;;
  final fields = <String, String>{};
  final body = raw.replaceFirst(RegExp(r'^WIFI:', caseSensitive: false), '');
  for (final part in body.split(';')) {
    final idx = part.indexOf(':');
    if (idx > 0) {
      fields[part.substring(0, idx).toUpperCase()] = part.substring(idx + 1);
    }
  }
  return fields;
}

// ── Social native app URI resolver ─────────────────────────────────────────

Uri? _socialNativeUri(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return null;
  final host = uri.host.replaceFirst('www.', '');
  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  final handle = segments.isNotEmpty ? segments.last : '';

  if (host == 'instagram.com' && handle.isNotEmpty) {
    return Uri.parse('instagram://user?username=$handle');
  }
  if (host == 'x.com' || host == 'twitter.com') {
    if (handle.isNotEmpty) {
      return Uri.parse('twitter://user?screen_name=$handle');
    }
  }
  if (host == 'tiktok.com') {
    final user = handle.startsWith('@') ? handle.substring(1) : handle;
    if (user.isNotEmpty) return Uri.parse('snssdk1233://user/@$user');
  }
  if (host == 'snapchat.com') {
    if (segments.length >= 2 && segments[0] == 'add') {
      return Uri.parse('snapchat://add/${segments[1]}');
    }
  }
  if (host == 'wa.me' && handle.isNotEmpty) {
    return Uri.parse('whatsapp://send?phone=$handle');
  }
  if (host == 't.me' && handle.isNotEmpty) {
    return Uri.parse('tg://resolve?domain=$handle');
  }
  if (host == 'youtube.com' || host == 'youtu.be') {
    return Uri.parse('vnd.youtube:${uri.path}');
  }
  if (host == 'linkedin.com') {
    return Uri.parse('linkedin://');
  }
  return null;
}

// ── Screen ──────────────────────────────────────────────────────────────────

class ScannedResultScreen extends StatelessWidget {
  final String data;
  const ScannedResultScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final info = _classify(data);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan Result',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              // ── Hero badge ────────────────────────────────────────────────
              _HeroBadge(info: info),
              const SizedBox(height: 28),

              // ── Content card ──────────────────────────────────────────────
              _ContentCard(data: data, info: info, theme: theme),
              const SizedBox(height: 20),

              // ── WiFi details (if applicable) ──────────────────────────────
              if (info.type == ScannedContentType.wifi)
                _WifiDetailsCard(data: data, theme: theme),

              // ── Action buttons ────────────────────────────────────────────
              const SizedBox(height: 8),
              _ActionSection(data: data, info: info, theme: theme),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero badge ──────────────────────────────────────────────────────────────

class _HeroBadge extends StatelessWidget {
  final _ContentInfo info;
  const _HeroBadge({required this.info});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                info.accentColor,
                info.accentColor.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: info.accentColor.withValues(alpha: 0.35),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(info.icon, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 14),
        Text(
          info.label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: info.accentColor,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ── Content card ────────────────────────────────────────────────────────────

class _ContentCard extends StatelessWidget {
  final String data;
  final _ContentInfo info;
  final ThemeData theme;
  const _ContentCard({
    required this.data,
    required this.info,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Content',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          SelectableText(
            data,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── WiFi details card ───────────────────────────────────────────────────────

class _WifiDetailsCard extends StatefulWidget {
  final String data;
  final ThemeData theme;
  const _WifiDetailsCard({required this.data, required this.theme});

  @override
  State<_WifiDetailsCard> createState() => _WifiDetailsCardState();
}

class _WifiDetailsCardState extends State<_WifiDetailsCard> {
  bool _showPassword = false;
  bool _connecting = false;
  String? _connectResult; // 'connected' | 'failed' | null

  Future<void> _connect(BuildContext context) async {
    final fields = _parseWifi(widget.data);
    final ssid = fields['S'] ?? '';
    final password = fields['P'] ?? '';
    final securityRaw = (fields['T'] ?? 'WPA').toUpperCase();

    if (!Platform.isAndroid) {
      // iOS: copy password then open Wi-Fi settings
      if (password.isNotEmpty) {
        await Clipboard.setData(ClipboardData(text: password));
      }
      final settingsUri = Uri.parse('App-Prefs:WIFI');
      if (await canLaunchUrl(settingsUri)) {
        await launchUrl(settingsUri);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              password.isNotEmpty
                  ? 'Password copied — select "$ssid" in Wi-Fi settings'
                  : 'Opening Wi-Fi settings…',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
      return;
    }

    // Android: request location permission (required by OS for WiFi APIs)
    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Location permission is required to connect to Wi-Fi',
            ),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
      return;
    }

    setState(() {
      _connecting = true;
      _connectResult = null;
    });

    try {
      final security = switch (securityRaw) {
        'WEP' => NetworkSecurity.WEP,
        'NOPASS' || '' => NetworkSecurity.NONE,
        _ => NetworkSecurity.WPA,
      };

      final ok = await WiFiForIoTPlugin.connect(
        ssid,
        password: password.isEmpty ? null : password,
        security: security,
        joinOnce: false,
        withInternet: true,
      );

      if (!context.mounted) return;
      setState(() {
        _connecting = false;
        _connectResult = ok ? 'connected' : 'failed';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok ? 'Connected to "$ssid"' : 'Could not connect to "$ssid"',
          ),
          backgroundColor: ok ? Colors.green[700] : Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      setState(() => _connecting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = _parseWifi(widget.data);
    final ssid = fields['S'] ?? 'Unknown';
    final password = fields['P'] ?? '';
    final security = fields['T'] ?? 'Open';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.theme.colorScheme.outlineVariant,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wi-Fi Details',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.5),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 14),
          _wifiRow(Icons.wifi_rounded, 'Network', ssid),
          const SizedBox(height: 10),
          _wifiRow(Icons.lock_outline_rounded, 'Security', security),
          if (password.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.key_rounded,
                  size: 18,
                  color: widget.theme.colorScheme.onSurface.withValues(
                    alpha: 0.5,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Password: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.theme.colorScheme.onSurface.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _showPassword
                        ? password
                        : '•' * password.length.clamp(0, 16),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.theme.colorScheme.onSurface,
                      fontFamily: _showPassword ? null : 'monospace',
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showPassword = !_showPassword),
                  child: Icon(
                    _showPassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 20,
                    color: widget.theme.colorScheme.onSurface.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: password));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Password copied!'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: widget.theme.colorScheme.onSurface.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _connecting ? null : () => _connect(context),
              icon: _connecting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      _connectResult == 'connected'
                          ? Icons.check_circle_rounded
                          : Icons.wifi_rounded,
                      color: Colors.white,
                    ),
              label: Text(
                _connecting
                    ? 'Connecting…'
                    : _connectResult == 'connected'
                    ? 'Connected!'
                    : Platform.isAndroid
                    ? 'Connect to Wi-Fi'
                    : 'Open Wi-Fi Settings',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _connectResult == 'connected'
                    ? Colors.green[700]
                    : const Color(0xFFAB47BC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wifiRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Action buttons section ──────────────────────────────────────────────────

class _ActionSection extends StatelessWidget {
  final String data;
  final _ContentInfo info;
  final ThemeData theme;
  const _ActionSection({
    required this.data,
    required this.info,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Primary action (open / call / email) ────────────────────────────
        if (info.type != ScannedContentType.text &&
            info.type != ScannedContentType.wifi)
          _PrimaryActionButton(data: data, info: info),

        const SizedBox(height: 14),

        // ── Secondary row: Copy · Share ─────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _SecondaryButton(
                icon: Icons.copy_rounded,
                label: 'Copy',
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: data));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Copied to clipboard'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                },
                theme: theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SecondaryButton(
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: () async {
                  await SharePlus.instance.share(ShareParams(text: data));
                },
                theme: theme,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Primary action button ───────────────────────────────────────────────────

class _PrimaryActionButton extends StatelessWidget {
  final String data;
  final _ContentInfo info;
  const _PrimaryActionButton({required this.data, required this.info});

  String get _label {
    switch (info.type) {
      case ScannedContentType.url:
        return 'Open in Browser';
      case ScannedContentType.email:
        return 'Send Email';
      case ScannedContentType.phone:
        return 'Call Number';
      default:
        return 'Open';
    }
  }

  IconData get _icon {
    switch (info.type) {
      case ScannedContentType.url:
        return Icons.open_in_browser_rounded;
      case ScannedContentType.email:
        return Icons.send_rounded;
      case ScannedContentType.phone:
        return Icons.call_rounded;
      default:
        return Icons.open_in_new_rounded;
    }
  }

  Future<void> _launch(BuildContext context) async {
    Uri? uri;
    final trimmed = data.trim();

    switch (info.type) {
      case ScannedContentType.url:
        // Try native social app first
        final nativeUri = _socialNativeUri(trimmed);
        if (nativeUri != null) {
          try {
            if (await canLaunchUrl(nativeUri)) {
              await launchUrl(nativeUri);
              return;
            }
          } catch (_) {}
        }
        var url = trimmed;
        if (url.startsWith('www.')) url = 'https://$url';
        uri = Uri.tryParse(url);
        break;
      case ScannedContentType.email:
        final address = trimmed.startsWith('mailto:')
            ? trimmed
            : 'mailto:$trimmed';
        uri = Uri.tryParse(address);
        break;
      case ScannedContentType.phone:
        final number = trimmed.startsWith('tel:') ? trimmed : 'tel:$trimmed';
        uri = Uri.tryParse(number);
        break;
      default:
        break;
    }

    if (uri == null) return;

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open: $trimmed'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open: $trimmed'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => _launch(context),
        icon: Icon(_icon, color: Colors.white),
        label: Text(
          _label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: info.accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// ── Secondary button ────────────────────────────────────────────────────────

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ThemeData theme;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1.2),
        ),
      ),
    );
  }
}
