import 'package:flutter/material.dart';

class StreamPlaceholder extends StatelessWidget {
  final String label;
  const StreamPlaceholder({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator.adaptive(),
          const SizedBox(width: 18),
          Text(
            '$label...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}
