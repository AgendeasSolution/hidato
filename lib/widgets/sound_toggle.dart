import 'package:flutter/material.dart';
import '../services/audio_service.dart';

/// A widget to toggle sound on/off
class SoundToggle extends StatefulWidget {
  const SoundToggle({super.key});

  @override
  State<SoundToggle> createState() => _SoundToggleState();
}

class _SoundToggleState extends State<SoundToggle> {
  late bool _isSoundEnabled;

  @override
  void initState() {
    super.initState();
    _isSoundEnabled = AudioService.instance.isSoundEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await AudioService.instance.toggleSound();
        setState(() {
          _isSoundEnabled = AudioService.instance.isSoundEnabled;
        });
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          _isSoundEnabled ? Icons.volume_up : Icons.volume_off,
          color: Colors.black,
          size: 18,
        ),
      ),
    );
  }
}
