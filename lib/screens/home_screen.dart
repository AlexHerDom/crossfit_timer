import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'timer_screen.dart';
import 'config_screen.dart';
import 'history_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';
import 'achievements_screen.dart';
import '../theme_provider.dart';
import '../language_provider.dart';
import '../services/ad_service.dart';
import '../services/gamification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabataWorkSeconds = 20;
  int _tabataRestSeconds = 10;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadTabataConfig();
  }

  void _loadTabataConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tabataWorkSeconds = prefs.getInt('tabata_work') ?? 20;
      _tabataRestSeconds = prefs.getInt('tabata_rest') ?? 10;
    });
  }

  String _getTabataSubtitle(LanguageProvider languageProvider) {
    final subtitle =
        '${_tabataWorkSeconds}s ${languageProvider.getText('work').toLowerCase()} / ${_tabataRestSeconds}s ${languageProvider.getText('rest').toLowerCase()}';
    return subtitle;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: themeProvider.isDarkMode ? Colors.white : Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        ),
      ),
      drawer: const AppDrawer(),
      body: Consumer<AdService>(
        builder: (context, adService, _) => Column(
          children: [
            Expanded(
              child: Stack(
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
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 56), // Space for AppBar
                            // Título de bienvenida
                            Column(
                              children: [
                                Text(
                                  languageProvider.getText('workout_timer'),
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                                    letterSpacing: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  languageProvider.getText('time_train'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: themeProvider.isDarkMode
                                        ? Colors.white.withOpacity(0.6)
                                        : Colors.black.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 50.ms)
                                .slideY(begin: -0.2, end: 0),

                            const SizedBox(height: 40),

                            // Botón AMRAP
                            _buildTimerButton(
                              context,
                              title: languageProvider.getText('amrap_title'),
                              subtitle: languageProvider.getText('amrap_subtitle'),
                              icon: Icons.all_inclusive,
                              color: Colors.orange,
                              onTap: () => _navigateToTimer(context, 'AMRAP'),
                              isDarkMode: themeProvider.isDarkMode,
                            ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.15, end: 0),

                            const SizedBox(height: 16),

                            // Botón EMOM
                            _buildTimerButton(
                              context,
                              title: languageProvider.getText('emom_title'),
                              subtitle: languageProvider.getText('emom_subtitle'),
                              icon: Icons.access_time,
                              color: Colors.blue,
                              onTap: () => _navigateToTimer(context, 'EMOM'),
                              isDarkMode: themeProvider.isDarkMode,
                            ).animate().fadeIn(duration: 400.ms, delay: 175.ms).slideY(begin: 0.15, end: 0),

                            const SizedBox(height: 16),

                            // Botón Tabata
                            _buildTimerButton(
                              context,
                              title: languageProvider.getText('tabata_title'),
                              subtitle: _getTabataSubtitle(languageProvider),
                              icon: Icons.flash_on,
                              color: Colors.red,
                              onTap: () => _navigateToTimer(context, 'TABATA'),
                              isDarkMode: themeProvider.isDarkMode,
                            ).animate().fadeIn(duration: 400.ms, delay: 250.ms).slideY(begin: 0.15, end: 0),

                            const SizedBox(height: 16),

                            // Botón Countdown
                            _buildTimerButton(
                              context,
                              title: languageProvider.getText('countdown_title'),
                              subtitle: languageProvider.getText('countdown_subtitle'),
                              icon: Icons.timer,
                              color: Colors.green,
                              onTap: () => _navigateToTimer(context, 'COUNTDOWN'),
                              isDarkMode: themeProvider.isDarkMode,
                            ).animate().fadeIn(duration: 400.ms, delay: 325.ms).slideY(begin: 0.15, end: 0),

                            const SizedBox(height: 16),

                            // Botón Running
                            _buildTimerButton(
                              context,
                              title: languageProvider.getText('running_title'),
                              subtitle: languageProvider.getText('running_subtitle'),
                              icon: Icons.directions_run,
                              color: Colors.purple,
                              onTap: () => _navigateToTimer(context, 'RUNNING'),
                              isDarkMode: themeProvider.isDarkMode,
                            ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.15, end: 0),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!adService.adsRemoved && adService.isBannerAdReady)
              SizedBox(
                height: adService.bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: adService.bannerAd!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode
        ? Colors.white.withOpacity(0.65)
        : Colors.black.withOpacity(0.7);
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.12)
        : Colors.black.withOpacity(0.1);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.2),
              ],
            ),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              splashColor: color.withOpacity(0.1),
              highlightColor: color.withOpacity(0.05),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    child: Icon(icon, size: 34, color: textColor),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            title,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: subtitleColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _openConfigScreen(context, title),
                    icon: const Icon(Icons.settings_outlined, size: 22),
                    color: subtitleColor,
                    splashRadius: 22,
                    tooltip: 'Configurar',
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: textColor,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToTimer(BuildContext context, String timerType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimerScreen(timerType: timerType),
      ),
    );
  }

  void _openConfigScreen(BuildContext context, String timerType) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfigScreen(timerType: timerType),
      ),
    );

    if (timerType == 'TABATA') {
      _loadTabataConfig();
    }
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _showAboutDialog(BuildContext context) {
    // ... (This function remains unchanged)
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    final menuItems = [
      _DrawerMenuItem(
        icon: Icons.emoji_events_rounded,
        text: languageProvider.getText('achievements_title'),
        color: Colors.amber,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AchievementsScreen())),
      ),
      _DrawerMenuItem(
        icon: Icons.history_rounded,
        text: languageProvider.getText('history'),
        color: Colors.blue,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen())),
      ),
      _DrawerMenuItem(
        icon: Icons.insert_chart_rounded,
        text: languageProvider.getText('stats'),
        color: Colors.teal,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StatsScreen())),
      ),
      _DrawerMenuItem(
        icon: Icons.settings_rounded,
        text: languageProvider.getText('settings'),
        color: Colors.indigo,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
      ),
    ];

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      const Color(0xFF1E2030).withOpacity(0.92),
                      const Color(0xFF2A2A38).withOpacity(0.92),
                    ]
                  : [
                      Colors.white.withOpacity(0.92),
                      const Color(0xFFF5F5F5).withOpacity(0.92),
                    ],
            ),
          ),
          child: Column(
            children: [
              _buildDrawerHeader(context, isDarkMode, languageProvider),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Column(
                          children: [
                            for (int index = 0; index < menuItems.length; index++)
                              _buildDrawerItem(
                                context: context,
                                icon: menuItems[index].icon,
                                text: menuItems[index].text,
                                color: menuItems[index].color,
                                onTap: menuItems[index].onTap,
                                isDarkMode: isDarkMode,
                                textColor: textColor,
                              ).animate().fadeIn(
                                duration: 300.ms,
                                delay: Duration(milliseconds: 80 + (index * 60)),
                              ).slideX(begin: -0.15, end: 0),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Divider(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.06),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: _buildDrawerItem(
                          context: context,
                          icon: Icons.info_outline_rounded,
                          text: languageProvider.getText('about'),
                          color: Colors.blueGrey,
                          onTap: () => _showAboutDialog(context),
                          isDarkMode: isDarkMode,
                          textColor: textColor,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, bool isDarkMode, LanguageProvider languageProvider) {
    final gamification = Provider.of<GamificationService>(context);
    final level = gamification.currentLevel;
    final progress = gamification.levelProgress;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.55);

    final topPadding = MediaQuery.of(context).padding.top;

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AchievementsScreen()));
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              level.color.withOpacity(0.3),
              level.color.withOpacity(0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border(
            bottom: BorderSide(
              color: isDarkMode ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        level.color.withOpacity(0.3),
                        level.color.withOpacity(0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: level.color.withOpacity(0.6), width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: level.color.withOpacity(0.2),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(level.icon, style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        languageProvider.getText(level.titleKey),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        gamification.isMaxLevel
                            ? languageProvider.getText('level_max')
                            : '${languageProvider.getText('level_label')} ${level.level}',
                        style: TextStyle(
                          fontSize: 13,
                          color: gamification.isMaxLevel ? level.color : subtitleColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: subtitleColor,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: level.color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(level.color),
                  minHeight: 7,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms, delay: 50.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
    required bool isDarkMode,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            onTap();
          },
          borderRadius: BorderRadius.circular(14),
          splashColor: color.withOpacity(0.1),
          highlightColor: color.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: color.withOpacity(isDarkMode ? 0.15 : 0.1),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
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

class _DrawerMenuItem {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onTap;

  _DrawerMenuItem({
    required this.icon,
    required this.text,
    required this.color,
    required this.onTap,
  });
}
