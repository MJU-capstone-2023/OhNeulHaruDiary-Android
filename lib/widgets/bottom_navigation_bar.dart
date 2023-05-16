import 'package:flutter/material.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTap;

  BottomNavigationBarWidget({required this.selectedIndex, required this.onTap});

  @override
  _BottomNavigationBarWidgetState createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_stories),
          label: 'Diary',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'My',
        ),
      ],
      currentIndex: widget.selectedIndex,
      onTap: widget.onTap,
      unselectedItemColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
    );
  }
}
