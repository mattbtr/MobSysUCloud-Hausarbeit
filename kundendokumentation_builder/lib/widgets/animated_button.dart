import 'package:flutter/material.dart';

class AnimatedHomeButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const AnimatedHomeButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<AnimatedHomeButton> createState() => _AnimatedHomeButtonState();
}

class _AnimatedHomeButtonState extends State<AnimatedHomeButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.96);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            icon: Icon(widget.icon, size: 28),
            label: Text(widget.label, style: const TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerLeft,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            onPressed: widget.onTap,
          ),
        ),
      ),
    );
  }
}