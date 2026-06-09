import 'package:flutter/material.dart';

class ContentFlowBrand extends StatelessWidget {
  const ContentFlowBrand({
    super.key,
    this.logoSize = 48,
    this.showTagline = true,
    this.centered = false,
    this.light = false,
  });

  final double logoSize;
  final bool showTagline;
  final bool centered;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final foreground = light ? Colors.white : null;
    final brand = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipOval(
          child: Image.asset(
            'assets/icon/contentflow_icon.png',
            width: logoSize,
            height: logoSize,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ContentFlow',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (showTagline)
              Text(
                'Plan • Create • Publish',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      foreground?.withValues(alpha: 0.82) ??
                      Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ],
    );
    return centered ? Center(child: brand) : brand;
  }
}
