// lib/features/shared/presentation/widgets/navigation/app_top_bar.dart
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/routes/app_router.dart';
import '../../../../my_device/presentation/bloc/my_device_bloc.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? additionalActions;
  final bool showBluetoothIcon;
  final bool showNotifications;
  final bool showProfile;
  final bool showLogout;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogoutTap;
  final String? title;
  final bool showBackButton;
  final Color backgroundColor;
  final Widget? titleWidget;

  const AppTopBar({
    super.key,
    this.additionalActions,
    this.showBluetoothIcon = true,
    this.showNotifications = true,
    this.showProfile = true,
    this.showLogout = true,
    this.onNotificationTap,
    this.onProfileTap,
    this.onLogoutTap,
    this.title,
    this.showBackButton = false,
    this.backgroundColor = const Color(0xFF1F2225),
    this.titleWidget,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.router.back(),
            )
          : null,
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: const TextStyle(color: Colors.white),
                )
              : null),
      centerTitle: title != null,
      actions: [
        if (showBluetoothIcon)
          BlocBuilder<MyDeviceBloc, MyDeviceState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  Icons.bluetooth,
                  color: state is MyDeviceConnected ? Colors.blue : Colors.grey,
                ),
                onPressed: () => context.router.push(const MyDeviceRoute()),
              );
            },
          ),
        if (showNotifications)
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: onNotificationTap,
          ),
        if (showProfile)
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: onProfileTap,
          ),
        if (showLogout)
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: onLogoutTap ??
                () {
                  context.router.replaceAll([const LoginRoute()]);
                },
          ),
        ...?additionalActions,
      ],
    );
  }
}
