import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
class TrailerScreen extends StatelessWidget { final String trailerKey; const TrailerScreen({super.key, required this.trailerKey}); @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: const Text('Trailer')), body: Center(child: Column(mainAxisSize: MainAxisSize.min, children:[ const Icon(Icons.play_circle_fill, size:100, color: AppColors.onSurfaceVariant), const SizedBox(height:16), Text('Trailer Key: $trailerKey'), const SizedBox(height:24), const Text('Video player integration coming in Week 7-8'), ]))); }
}
