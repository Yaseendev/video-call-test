import 'package:flutter/material.dart';

class StreamErrorView extends StatelessWidget {
  final String label;
  const StreamErrorView({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning_rounded,
            size: 32,
          ),
          const SizedBox(width: 14),
          Text(
            label,
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
