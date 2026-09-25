import 'package:flutter/material.dart';

class DraftTile extends StatelessWidget {
  final String title;
  final Widget? subtitle;
  final IconData? icon;
  final FontWeight fontWeight;
  final Color? iconColor;
  final VoidCallback? onTap;

  const DraftTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.fontWeight,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(title, style: TextStyle(fontWeight: fontWeight)),
        subtitle: subtitle,
        leading: icon != null
            ? Icon(icon, color: Theme.of(context).colorScheme.primary)
            : null,
        onTap: onTap,
      ),
    );
  }
}
