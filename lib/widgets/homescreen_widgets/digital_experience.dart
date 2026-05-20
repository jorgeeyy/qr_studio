import 'package:flutter/material.dart';

class DigitalExperience extends StatelessWidget {
  const DigitalExperience({super.key, required this.onStartScanning});

  final VoidCallback onStartScanning;

  @override
  Widget build(BuildContext context) {
    return Card(
      // color: Colors.grey[900],
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unlock \nDigital \nExperiences',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create high-precision, \ncustomized QR codes \nfor your brand in \nseconds.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onStartScanning,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Start Scanning',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // SizedBox(width: 20),
            Transform.rotate(
              angle: 0.25, // Adjust the rotation angle as needed
              child: Container(
                width: 100,
                height: 100,
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Image.asset('assets/images/DemoQR.png'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
