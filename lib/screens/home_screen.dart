// ============================================================
// RailGuide — Home Screen (Connected Live API + Quick Actions)
// screens/home_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'navigation/campus_navigation_screen.dart';

import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/train_provider.dart';
import '../providers/navigation_provider.dart'; // ✅ Added to access the navigation router state engine
import '../services/train_service.dart';
import '../utils/app_theme.dart';
import 'navigation_screen.dart'; // ✅ Added to support navigation view redirection handshakes

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang  = context.watch<LanguageProvider>();
    final auth  = context.watch<RailAuthProvider>();
    final trains = context.watch<TrainProvider>();

    return RefreshIndicator(
      color: AppTheme.railwayBlue,
      onRefresh: trains.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeBanner(auth: auth),
            const SizedBox(height: 24),
            _QuickAccessGrid(lang: lang),
            const SizedBox(height: 28),

            // ── Train Info Header ──────────────────────────
            Row(
              children: [
                const Icon(Icons.train_rounded,
                    color: AppTheme.railwayBlue, size: 22),
                const SizedBox(width: 8),
                Text(lang.t('train_info'),
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),

                trains.isRefreshing
                    ? _RefreshingBadge()
                    : _LiveBadge(),

                const SizedBox(width: 8),

                GestureDetector(
                  onTap: trains.refresh,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.railwayBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.refresh_rounded,
                        color: AppTheme.railwayBlue, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            Text(
              'Auto-refreshes every 90s  •  Pull down to refresh',
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppTheme.textLight),
            ),
            const SizedBox(height: 14),

            // ── Train Cards ────────────────────────────────
            ...kTrackedTrains.map((t) {
              final result = trains.resultFor(t['number']!);
              return _LiveTrainCard(
                trainMeta: t,
                result: result ?? const TrainApiResult.loading(),
                lang: lang,
              );
            }),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Live Badge
// ──────────────────────────────────────────────────────────
class _LiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7, height: 7,
            decoration: const BoxDecoration(
              color: AppTheme.success, shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text('Live',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _RefreshingBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 10, height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppTheme.warning,
            ),
          ),
          const SizedBox(width: 6),
          Text('Updating',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.warning,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Live Train Card
// ──────────────────────────────────────────────────────────
class _LiveTrainCard extends StatelessWidget {
  final Map<String, String> trainMeta;
  final TrainApiResult result;
  final LanguageProvider lang;

  const _LiveTrainCard({
    required this.trainMeta,
    required this.result,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: result.isLoading
          ? _ShimmerCard()
          : result.hasError
              ? _ErrorCard(
                  trainName: trainMeta['name']!,
                  trainNumber: trainMeta['number']!,
                  platform: trainMeta['platform']!,
                  error: result.error!,
                )
              : _DataCard(
                  data: result.data!,
                  platform: trainMeta['platform']!,
                  lang: lang,
                ),
    );
  }
}

class _DataCard extends StatelessWidget {
  final LiveTrainInfo data;
  final String platform;
  final LanguageProvider lang;

  const _DataCard({
    required this.data,
    required this.platform,
    required this.lang,
  });

  Color get _statusColor {
    switch (data.status) {
      case 'On Time':   return AppTheme.success;
      case 'Delayed':   return AppTheme.warning;
      case 'Departed':  return AppTheme.railwayBlueLight;
      default:          return AppTheme.textLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.railwayBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                    child: Text('🚉', style: TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.trainName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text('# ${data.trainNumber}',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppTheme.textLight)),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.safetyYellow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${lang.t('platform')} $platform',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.railwayBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      data.status +
                          (data.delayMinutes > 0
                              ? ' (+${data.delayMinutes}m)'
                              : ''),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.scaffoldBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CURRENT LOCATION',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textLight,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.currentStation,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        data.currentStationCode,
                        style: GoogleFonts.inter(
                            fontSize: 10, color: AppTheme.textLight),
                      ),
                    ],
                  ),
                ),

                Container(
                    width: 1, height: 36,
                    color: Colors.grey.shade200,
                    margin: const EdgeInsets.symmetric(horizontal: 12)),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SCHEDULED',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textLight,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 11, color: AppTheme.textLight),
                        const SizedBox(width: 4),
                        Text(data.scheduleDeparture,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ACTUAL',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textLight,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 11, color: _statusColor),
                        const SizedBox(width: 4),
                        Text(data.actualDeparture,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _block(double w, double h) => AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Container(
          width: w, height: h,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: _anim.value),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _block(48, 48),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _block(140, 14),
                    const SizedBox(height: 6),
                    _block(80, 11),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _block(80, 26),
                  const SizedBox(height: 6),
                  _block(60, 18),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _block(double.infinity, 56),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String trainName;
  final String trainNumber;
  final String platform;
  final String error;

  const _ErrorCard({
    required this.trainName,
    required this.trainNumber,
    required this.platform,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    final isApiKeyError = error.contains('401') ||
        error.contains('API key') ||
        error.contains('YOUR_API_KEY');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppTheme.railwayBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
                child: Text('🚉', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trainName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text('# $trainNumber',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppTheme.textLight)),
                const SizedBox(height: 4),
                Text(
                  isApiKeyError
                      ? '⚠️ Add API key in train_service.dart'
                      : '⚠️ Unable to fetch live data',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.safetyYellow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Pf $platform',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.railwayBlue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Look for this widget near the bottom of lib/screens/home_screen.dart:
class _WelcomeBanner extends StatelessWidget {
  final RailAuthProvider auth;

  const _WelcomeBanner({required this.auth});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    
    // Check if a valid student identity string is registered in state
    final String identityDisplay = auth.studentUsn ?? "Guest Commuter";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.railwayBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.railwayBlue.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppTheme.railwayBlue,
            radius: 24,
            child: Icon(Icons.person, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${lang.t('welcome')},',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  identityDisplay, // Cleanly displays the student USN identifier safely
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Quick Access Grid (Smart Node Routing Engine)
// ──────────────────────────────────────────────────────────
class _QuickItem {
  final String emoji, label, targetNodeId;
  final Color color;
  final bool isCampusNode; 

  const _QuickItem(this.emoji, this.label, this.color, this.targetNodeId, {this.isCampusNode = false});
}

class _QuickAccessGrid extends StatelessWidget {
  final LanguageProvider lang;
  const _QuickAccessGrid({required this.lang});

  @override
  Widget build(BuildContext context) {
    const items = [
      _QuickItem('🚻', 'Washrooms', AppTheme.railwayBlueLight, 'washrooms', isCampusNode: false),
      _QuickItem('🎫', 'Tickets',   AppTheme.railwayBlueMid,   'ticket_counter', isCampusNode: false),
      _QuickItem('🚉', 'Platform 1', Color(0xFF374151),        'platform_1', isCampusNode: false),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: items.map((item) => _QuickTile(item: item)).toList(),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final _QuickItem item;
  const _QuickTile({required this.item});

  // ✅ FIXED: Correctly placed INSIDE the _QuickTile class scope
  void _handleQuickNavigation(BuildContext context) {
    final nav = context.read<NavigationProvider>();

    nav.reset();

    if (item.isCampusNode) {
      nav.setMode(AppNavigationMode.campus);
      nav.setCampusEnd(item.targetNodeId); 
      
      // ✅ FIXED: Target class name updated to CampusNavScreen
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CampusNavigationScreen()),
      );
    } else {
      nav.setMode(AppNavigationMode.railway);
      nav.setDestination(item.targetNodeId); 
      
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NavigationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleQuickNavigation(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} // ✅ FIXED: Class properly closed here at the very end