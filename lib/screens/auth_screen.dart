// ============================================================
// RailGuide — Authentication Screen (Camera Barcode Engine)
// screens/auth_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'main_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  
  bool _isProcessingScan = false;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const MainShell(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<RailAuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Premium Dark Slate Background
      body: Stack(
        children: [
          // ── LAYER 1: LIVE HARDWARE CAMERA INTERFACE ──────────────────
          Positioned.fill(
            child: MobileScanner(
              controller: _cameraController,
              onDetect: (capture) {
                if (_isProcessingScan) return;

                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                  setState(() => _isProcessingScan = true);
                  
                  final String scannedCode = barcodes.first.rawValue!;
                  
                  // Run through the verification loop (RN, RX, or IB validation)
                  bool isLoggedOk = context.read<RailAuthProvider>().loginWithBarcode(scannedCode);

                  if (isLoggedOk) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('ID Verified! Welcome ${context.read<RailAuthProvider>().studentUsn}'),
                        backgroundColor: const Color(0xFF1B6B3A), // Campus Green
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    _navigateToDashboard();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(authProvider.error ?? 'Invalid ID barcode layout structure.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    
                    // Release the camera hold lock after 2 seconds to allow re-scans
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _isProcessingScan = false);
                    });
                  }
                }
              },
            ),
          ),

          // ── LAYER 2: TRANSLUCENT MASK & IDENTITY ALIGNMENT FRAME ─────
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.55),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'RAILGUIDE AUTHENTICATION',
                      style: GoogleFonts.rajdhani(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Scan student card barcode (RN, RX, or IB)',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 35),
                    
                    // Card Box Boundary Outline Mask
                    Container(
                      width: 310,
                      height: 190,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _isProcessingScan ? AppTheme.safetyYellow : const Color(0xFF00F0FF), 
                          width: 3.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 35),
                    if (_isProcessingScan)
                      const CircularProgressIndicator(
                        color: Color(0xFF00F0FF),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.flash_on_outlined, color: Colors.white60, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Align card profile inside the boundary lines',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}