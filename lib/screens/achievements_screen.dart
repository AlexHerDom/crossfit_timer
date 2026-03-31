
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:share_plus/share_plus.dart';
import '../services/gamification_service.dart';
import '../language_provider.dart';
import '../theme_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  void _shareAchievements(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final gamification = Provider.of<GamificationService>(context, listen: false);
    final level = gamification.currentLevel;
    final unlocked = gamification.unlockedBadges;
    final allBadges = GamificationService.allBadges;

    final text = StringBuffer();
    text.writeln(languageProvider.getText('share_achievements'));
    text.writeln('');
    text.writeln('${level.icon} ${languageProvider.getText(level.titleKey)} — ${languageProvider.getText('level_label')} ${level.level}');
    text.writeln('🏅 ${unlocked.length}/${allBadges.length}');
    text.writeln('');

    // List unlocked badges with their emojis
    for (final badge in allBadges) {
      if (unlocked.contains(badge.id)) {
        final name = languageProvider.getText('badge_${badge.id}');
        text.writeln('${badge.icon} $name');
      }
    }

    text.writeln('');
    text.writeln('#CrossFit #WOD #CrossFitTimerPro');

    Share.share(text.toString());
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final gamification = Provider.of<GamificationService>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;

    final unlocked = gamification.unlockedBadges;
    final allBadges = GamificationService.allBadges;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
        actions: [
          if (unlocked.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: () => _shareAchievements(context),
              tooltip: languageProvider.getText('share'),
            ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: themeProvider.isDarkMode
                    ? const [Color(0xFF1E2030), Color(0xFF2A2A38), Color(0xFF1E2030)]
                    : const [Color(0xFFE0F7FA), Color(0xFFFCE4EC), Color(0xFFE8EAF6)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  languageProvider.getText('achievements_title'),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  gamification.isMaxLevel && unlocked.length == allBadges.length
                      ? languageProvider.getText('all_badges_unlocked')
                      : languageProvider.getText('achievements_subtitle'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: gamification.isMaxLevel && unlocked.length == allBadges.length
                        ? gamification.currentLevel.color
                        : textColor.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 10),
                // Progress counter
                Text(
                  '${unlocked.length} / ${allBadges.length}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: allBadges.length,
                    itemBuilder: (context, index) {
                      final badge = allBadges[index];
                      final isUnlocked = unlocked.contains(badge.id);
                      return _buildBadgeItem(
                        context: context,
                        badge: badge,
                        isUnlocked: isUnlocked,
                        isDark: isDark,
                        textColor: textColor,
                        lang: languageProvider,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem({
    required BuildContext context,
    required AchievementBadge badge,
    required bool isUnlocked,
    required bool isDark,
    required Color textColor,
    required LanguageProvider lang,
  }) {
    final name = lang.getText('badge_${badge.id}');
    final borderColor =
        isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);

    return GestureDetector(
      onTap: () => _showBadgeDetail(context, badge, isUnlocked, isDark, textColor, lang),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.3),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isUnlocked
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              badge.color.withOpacity(0.4),
                              badge.color.withOpacity(0.2),
                            ],
                          )
                        : null,
                    color: isUnlocked
                        ? null
                        : (isDark
                            ? Colors.white.withOpacity(0.06)
                            : Colors.black.withOpacity(0.06)),
                    border: Border.all(
                      color: isUnlocked
                          ? badge.color.withOpacity(0.5)
                          : (isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1)),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: isUnlocked
                        ? Text(badge.icon, style: const TextStyle(fontSize: 28))
                        : Icon(
                            Icons.lock_outline,
                            size: 26,
                            color: textColor.withOpacity(0.25),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    isUnlocked ? name : '???',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isUnlocked ? textColor : textColor.withOpacity(0.4),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBadgeDetail(BuildContext context, AchievementBadge badge, bool isUnlocked, bool isDark,
      Color textColor, LanguageProvider lang) {
    final name = lang.getText('badge_${badge.id}');
    final desc = lang.getText('badge_${badge.id}_desc');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF2A2A38) : Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isUnlocked
                    ? LinearGradient(
                        colors: [
                          badge.color.withOpacity(0.4),
                          badge.color.withOpacity(0.2),
                        ],
                      )
                    : null,
                color: isUnlocked
                    ? null
                    : (isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.grey.withOpacity(0.15)),
              ),
              child: Center(
                child: isUnlocked
                    ? Text(badge.icon, style: const TextStyle(fontSize: 40))
                    : Icon(Icons.lock_outline,
                        size: 36,
                        color: textColor.withOpacity(0.3)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isUnlocked ? name : lang.getText('badge_locked'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (isUnlocked) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  final text = StringBuffer();
                  text.writeln('${badge.icon} ${lang.getText('badge_unlocked_title')}');
                  text.writeln('');
                  text.writeln(lang.getText('badge_${badge.id}'));
                  text.writeln(lang.getText('badge_${badge.id}_desc'));
                  text.writeln('');
                  text.writeln('#CrossFit #WOD #CrossFitTimerPro');
                  Share.share(text.toString());
                },
                icon: const Icon(Icons.share_rounded, size: 18),
                label: Text(lang.getText('share')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: badge.color,
                  side: BorderSide(color: badge.color.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              lang.getText('close'),
              style: const TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}
