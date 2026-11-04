import 'package:flutter/material.dart';

class NavButtonWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  const NavButtonWidget({
    Key? key,
    required this.label,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(backgroundColor),
          elevation: WidgetStateProperty.all<double>(0.0),
          padding:
              WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.all(8.0)),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(color: backgroundColor)))),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8.0),
          Text(
            label,
            style: TextStyle(fontSize: 14.0, color: Colors.grey.shade700),
          )
        ],
      ),
    );
  }
}
