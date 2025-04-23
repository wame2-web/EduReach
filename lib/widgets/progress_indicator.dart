import 'package:flutter/material.dart';

class XpProgressIndicator extends StatelessWidget {
  final int currentXp;
  final int xpToNextLevel;
  final int level;

  const XpProgressIndicator({
    super.key,
    required this.currentXp,
    required this.xpToNextLevel,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = xpToNextLevel > 0 ? currentXp / xpToNextLevel : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level $level',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              '$currentXp/$xpToNextLevel XP',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          color: Theme.of(context).colorScheme.primary,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }
}