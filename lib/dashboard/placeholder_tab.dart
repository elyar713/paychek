import 'package:flutter/material.dart';

class DashboardPlaceholderTab extends StatelessWidget {
  const DashboardPlaceholderTab({super.key, required this.title, required this.emoji});

  final String title;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            '$emoji $title',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
