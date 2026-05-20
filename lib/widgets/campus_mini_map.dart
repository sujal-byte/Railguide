// ============================================================
// RailGuide — Campus Mini-Map (With Corner Compass Overlay)
// widgets/campus_mini_map.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class CampusPoint {
  final double x; 
  final double y; 
  final String label;

  const CampusPoint(this.x, this.y, this.label);
}

class CampusMiniMap extends StatelessWidget {
  final String? startNodeId;
  final String? endNodeId;
  final List<String> activePathNodes; 

  const CampusMiniMap({
    super.key,
    this.startNodeId,
    this.endNodeId,
    required this.activePathNodes,
  });

  static const Map<String, CampusPoint> _campusCoordinates = {
    'main_gate':        CampusPoint(0.65, 0.15, 'Main Gate'),
    'mechanical_block': CampusPoint(0.65, 0.40, 'Mech Block'),
    'mba_block':        CampusPoint(0.65, 0.65, 'MBA Block'),
    'temple_parking':   CampusPoint(0.65, 0.90, 'Temple Parking'),

    'food_court':       CampusPoint(0.32, 0.76, 'Food Court'),
    'library':          CampusPoint(0.12, 0.78, 'Library'),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            const Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: GridPaper(
                  color: AppTheme.railwayBlue,
                  interval: 30,
                  subdivisions: 1,
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _MapVectorPainter(
                  coordinates: _campusCoordinates,
                  activePath: activePathNodes,
                  startId: startNodeId,
                  endId: endNodeId,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapVectorPainter extends CustomPainter {
  final Map<String, CampusPoint> coordinates;
  final List<String> activePath;
  final String? startId;
  final String? endId;

  _MapVectorPainter({
    required this.coordinates,
    required this.activePath,
    required this.startId,
    required this.endId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFCBD5E1) 
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final activePathPaint = Paint()
      ..color = const Color(0xFF1B6B3A) 
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final nodePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final nodeBorderPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const connections = [
      ('main_gate', 'mechanical_block'),
      ('mechanical_block', 'mba_block'),
      ('mba_block', 'temple_parking'),
      ('mba_block', 'food_court'),
      ('food_court', 'library'),
      ('library', 'temple_parking'),
    ];

    // 1. Draw structural network path lines
    for (final connection in connections) {
      final p1 = coordinates[connection.$1];
      final p2 = coordinates[connection.$2];
      if (p1 != null && p2 != null) {
        canvas.drawLine(_getPixelPos(p1, size), _getPixelPos(p2, size), linePaint);
      }
    }

    // 2. Draw Dijkstra shortest path overlay
    if (activePath.length > 1) {
      final path = Path();
      final firstPoint = coordinates[activePath.first];
      if (firstPoint != null) {
        final startPos = _getPixelPos(firstPoint, size);
        path.moveTo(startPos.dx, startPos.dy);
        
        for (int i = 1; i < activePath.length; i++) {
          final nextPoint = coordinates[activePath[i]];
          if (nextPoint != null) {
            final nextPos = _getPixelPos(nextPoint, size);
            path.lineTo(nextPos.dx, nextPos.dy);
          }
        }
        canvas.drawPath(path, activePathPaint);
      }
    }

    // 3. Draw Nodes + Dynamically Shifted Text Labels
    coordinates.forEach((id, point) {
      final pos = _getPixelPos(point, size);
      bool isStart = id == startId;
      bool isEnd = id == endId;

      if (isStart) {
        canvas.drawCircle(pos, 7.5, Paint()..color = const Color(0xFF2E9E58));
        canvas.drawCircle(pos, 3, Paint()..color = Colors.white);
      } else if (isEnd) {
        canvas.drawCircle(pos, 7.5, Paint()..color = const Color(0xFFEF4444));
        canvas.drawCircle(pos, 3, Paint()..color = Colors.white);
      } else {
        canvas.drawCircle(pos, 5, nodePaint);
        canvas.drawCircle(pos, 5, nodeBorderPaint);
      }

      final textStyle = GoogleFonts.inter(
        color: isStart ? const Color(0xFF1B6B3A) : isEnd ? const Color(0xFFEF4444) : const Color(0xFF334155),
        fontSize: 9.5,
        fontWeight: (isStart || isEnd) ? FontWeight.bold : FontWeight.w600,
      );

      final textSpan = TextSpan(text: point.label, style: textStyle);
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();

      double offsetX;
      double offsetY;

      if (point.x > 0.50) {
        offsetX = pos.dx + 10;
        offsetY = pos.dy - (textPainter.height / 2);
      } else {
        offsetX = pos.dx - (textPainter.width / 2);
        offsetY = pos.dy + 8;
      }

      if (offsetX < 4) offsetX = 4;
      if (offsetX + textPainter.width > size.width - 4) offsetX = size.width - textPainter.width - 4;

      textPainter.paint(canvas, Offset(offsetX, offsetY));
    });

    // ── ✅ NEW: RIGHT BOTTOM CORNER COMPASS OVERLAY RENDER ──────────────────
    _drawCornerCompass(canvas, size);
  }

  void _drawCornerCompass(Canvas canvas, Size size) {
    // Define the central pivot point of our compass widget in the bottom right corner
    final double centerX = size.width - 32;
    final double centerY = size.height - 32;
    final center = Offset(centerX, centerY);

    final compassPaint = Paint()
      ..color = const Color(0xFF94A3B8) // Slate 400
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw a subtle outer ring
    canvas.drawCircle(center, 14, compassPaint);

    // Draw the northern indicator triangle arrow tip
    final arrowPath = Path()
      ..moveTo(centerX, centerY - 13) // Top Tip
      ..lineTo(centerX - 3, centerY - 2) // Bottom Left
      ..lineTo(centerX + 3, centerY - 2) // Bottom Right
      ..close();

    canvas.drawPath(arrowPath, Paint()..color = const Color(0xFFEF4444)); // Red pointing North

    // Helper to pain cardinal letter indicators
    final List<Map<String, dynamic>> cardinals = [
      {'text': 'N', 'offset': const Offset(-3.5, -24)},
      {'text': 'S', 'offset': const Offset(-3.5, 13)},
      {'text': 'E', 'offset': const Offset(14, -6)},
      {'text': 'W', 'offset': const Offset(-21, -6)},
    ];

    for (var point in cardinals) {
      final labelPainter = TextPainter(
        text: TextSpan(
          text: point['text'],
          style: GoogleFonts.inter(
            fontSize: 8.5, 
            fontWeight: FontWeight.w800, 
            color: point['text'] == 'N' ? const Color(0xFFEF4444) : const Color(0xFF64748B),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final Offset localOffset = point['offset'] as Offset;
      labelPainter.paint(canvas, center + localOffset);
    }
  }

  Offset _getPixelPos(CampusPoint point, Size size) {
    return Offset(point.x * size.width, point.y * size.height);
  }

  @override
  bool shouldRepaint(covariant _MapVectorPainter oldDelegate) => 
      oldDelegate.activePath != activePath || oldDelegate.startId != startId || oldDelegate.endId != endId;
}