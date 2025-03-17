import 'package:flutter/material.dart';

enum PageTurnDirection {
  previous,
  next,
}

class PageTurnButton extends StatelessWidget {
  final PageTurnDirection direction;
  final VoidCallback onTap;
  final bool enabled;

  const PageTurnButton({
    super.key,
    required this.direction,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isNext = direction == PageTurnDirection.next;
    
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: enabled 
              ? Theme.of(context).colorScheme.primary 
              : Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: Icon(
          isNext ? Icons.arrow_forward : Icons.arrow_back,
          color: enabled ? Colors.white : Colors.grey[500],
        ),
      ),
    );
  }
}

