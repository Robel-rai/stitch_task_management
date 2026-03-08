import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Consumer<AppState>(
      builder: (context, state, _) {
        final isDark = state.isDarkMode;

        return Column(
          children: [
            // Header
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: colors.background,
                border: Border(
                  bottom: BorderSide(color: colors.border),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.settings, size: 22, color: colors.textPrimary),
                  const SizedBox(width: 12),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Appearance Section
                    Text(
                      'APPEARANCE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: colors.textTertiary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Theme Toggle Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.surfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.border),
                      ),
                      child: Row(
                        children: [
                          // Theme icon
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.primary.withValues(alpha: 0.15)
                                  : colors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isDark ? Icons.dark_mode : Icons.light_mode,
                              color: isDark ? AppTheme.primary : const Color(0xFFF59E0B),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dark Mode',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isDark
                                      ? 'Switch to light mode for a brighter look'
                                      : 'Switch to dark mode for a darker look',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isDark,
                            onChanged: (_) => state.toggleTheme(),
                            activeColor: AppTheme.primary,
                            activeTrackColor:
                                AppTheme.primary.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Theme Preview Cards
                    Row(
                      children: [
                        // Dark theme preview
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (!isDark) state.toggleTheme();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF101022),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? AppTheme.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E293B),
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        width: 12,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Dark',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Light theme preview
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (isDark) state.toggleTheme();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: !isDark
                                      ? AppTheme.primary
                                      : const Color(0xFFE2E8F0),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE2E8F0),
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        width: 12,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Light',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: !isDark
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // About Section
                    Text(
                      'ABOUT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: colors.textTertiary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.surfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        children: [
                          _infoRow('App Name', 'Taskflow', colors),
                          Divider(color: colors.border, height: 24),
                          _infoRow('Version', '1.2.0', colors),
                          Divider(color: colors.border, height: 24),
                          _infoRow('Platform', 'Windows Desktop', colors),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _infoRow(String label, String value, AppThemeColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: colors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
