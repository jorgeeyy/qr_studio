import 'package:flutter/material.dart';

enum WifiSecurity { wpa, wep, none }

class WifiCreate extends StatefulWidget {
  const WifiCreate({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<WifiCreate> createState() => _WifiCreateState();
}

class _WifiCreateState extends State<WifiCreate> {
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  WifiSecurity _security = WifiSecurity.wpa;
  bool _isHidden = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _notify() {
    final ssid = _escape(_ssidController.text);
    final pass = _escape(_passwordController.text);
    final sec = _security == WifiSecurity.none
        ? 'nopass'
        : _security.name.toUpperCase();
    widget.onChanged(
      'WIFI:T:$sec;S:$ssid;P:$pass;H:${_isHidden ? 'true' : 'false'};;',
    );
  }

  String _escape(String s) => s
      .replaceAll(r'\', r'\\')
      .replaceAll(';', r'\;')
      .replaceAll(',', r'\,')
      .replaceAll('"', r'\"');

  InputDecoration _fieldDecoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
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
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WiFi Network Details'.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Security type
          Text(
            'Security Type',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: WifiSecurity.values.map((sec) {
              final selected = _security == sec;
              final label = sec == WifiSecurity.none
                  ? 'None'
                  : sec.name.toUpperCase();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _security = sec);
                    _notify();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: selected
                          ? Colors.green
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                      border: Border.all(
                        color: selected ? Colors.green : Colors.grey[700]!,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // SSID
          Text(
            'Network Name (SSID)',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ssidController,
            onChanged: (_) => _notify(),
            decoration: _fieldDecoration(
              'e.g. HomeNetwork',
              suffix: Icon(Icons.wifi, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 16),

          // Password (hidden for nopass)
          if (_security != WifiSecurity.none) ...[
            Text(
              'Password',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              onChanged: (_) => _notify(),
              decoration: _fieldDecoration(
                'Enter password',
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[500],
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Hidden network toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hidden Network',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Switch(
                value: _isHidden,
                activeThumbColor: Colors.green,
                onChanged: (v) {
                  setState(() => _isHidden = v);
                  _notify();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
