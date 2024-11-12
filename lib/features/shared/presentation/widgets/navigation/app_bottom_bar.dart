// lib/features/shared/presentation/widgets/navigation/app_bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../../config/routes/app_router.dart';

enum AppBottomBarItem {
  treatments(icon: Icons.medical_services, label: 'Treatments'),
  home(icon: Icons.home, label: 'Home'),
  journals(icon: Icons.pie_chart, label: 'Journals');

  final IconData icon;
  final String label;

  const AppBottomBarItem({required this.icon, required this.label});
}

class AppBottomBar extends StatelessWidget {
  final AppBottomBarItem currentItem;
  final ValueChanged<AppBottomBarItem>? onItemSelected;

  const AppBottomBar({
    super.key,
    required this.currentItem,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF2A2D30),
      selectedItemColor: const Color(0xFF2691A5),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      currentIndex: AppBottomBarItem.values.indexOf(currentItem),
      items: AppBottomBarItem.values.map((item) {
        return BottomNavigationBarItem(
          icon: Icon(item.icon),
          label: item.label,
        );
      }).toList(),
      onTap: (index) {
        final selectedItem = AppBottomBarItem.values[index];
        onItemSelected?.call(selectedItem);
        _handleNavigation(context, selectedItem);
      },
    );
  }

  void _handleNavigation(BuildContext context, AppBottomBarItem item) {
    switch (item) {
      case AppBottomBarItem.home:
        context.router.replace(const HomeRoute());
        break;
      case AppBottomBarItem.journals:
        context.router.push(const JournalRoute());
        break;
      case AppBottomBarItem.treatments:
        // Will be implemented when treatments feature is added
        break;
    }
  }
}
