import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Consumer<AppState>(
      builder: (context, state, _) {
        return Container(
          width: 256,
          decoration: BoxDecoration(
            color: colors.sidebarBackground,
            border: Border(
              right: BorderSide(color: colors.border),
            ),
          ),
          child: Column(
            children: [
              // Logo
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: SvgPicture.asset(
                        'AppLogo/Task Flow.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Taskflow',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          'Premium Plan',
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Navigation Items
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _NavItem(
                        icon: Icons.dashboard_outlined,
                        activeIcon: Icons.dashboard,
                        label: 'Dashboard',
                        index: 0,
                        currentIndex: state.currentNavIndex,
                        onTap: () => state.setNavIndex(0),
                      ),
                      _NavItem(
                        icon: Icons.check_circle_outline,
                        activeIcon: Icons.check_circle,
                        label: 'Tasks',
                        index: 1,
                        currentIndex: state.currentNavIndex,
                        onTap: () => state.setNavIndex(1),
                      ),
                      _NavItem(
                        icon: Icons.calendar_today_outlined,
                        activeIcon: Icons.calendar_today,
                        label: 'Calendar',
                        index: 2,
                        currentIndex: state.currentNavIndex,
                        onTap: () => state.setNavIndex(2),
                      ),
                      _NavItem(
                        icon: Icons.bar_chart_outlined,
                        activeIcon: Icons.bar_chart,
                        label: 'Analytics',
                        index: 3,
                        currentIndex: state.currentNavIndex,
                        onTap: () => state.setNavIndex(3),
                      ),
                      const SizedBox(height: 16),
                      Divider(color: colors.border),
                      const SizedBox(height: 8),
                      _NavItem(
                        icon: Icons.settings_outlined,
                        activeIcon: Icons.settings,
                        label: 'Settings',
                        index: 4,
                        currentIndex: state.currentNavIndex,
                        onTap: () => state.setNavIndex(4),
                      ),
                    ],
                  ),
                ),
              ),

              // User Profile
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: colors.border)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primary.withValues(alpha: 0.2),
                      ),
                      child: const Center(
                        child: Text(
                          'A',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alex Smith',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          Text(
                            'Pro Plan Member',
                            style: TextStyle(
                              fontSize: 10,
                              color: colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.logout, size: 18, color: colors.textSecondary),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  bool get isActive => index == currentIndex;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive
                  ? colors.navItemActive
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 20,
                  color: isActive
                      ? colors.navItemActiveText
                      : colors.navItemInactiveText,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? colors.navItemActiveText
                        : colors.navItemInactiveText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
