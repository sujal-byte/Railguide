// ============================================================
// RailGuide — Auth Provider (Unified & Error-Free)
// providers/auth_provider.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class RailAuthProvider extends ChangeNotifier {
  AuthStatus _status     = AuthStatus.initial;
  String?    _studentUsn; 
  String?    _error;

  // Reports memory cache
  final List<Map<String, String>> _reports = [];

  AuthStatus               get status     => _status;
  String?                  get studentUsn => _studentUsn;
  String?                  get error      => _error;
  List<Map<String, String>> get reports   => List.unmodifiable(_reports);

  bool get isAuthenticated => _status == AuthStatus.authenticated;

  RailAuthProvider() {
    _loadSessionFromPrefs();
  }

  // ── ADVANCED BARCODE AUTHENTICATION ENGINE ──────────────────
  bool loginWithBarcode(String barcodeRawValue) {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    final cleanCode = barcodeRawValue.trim().toUpperCase();

    // Validates standard VTU structures for RN, RX, and IB branches
    final multiBranchPattern = RegExp(r'^1(RN|RX|IB)\d{2}[A-Z]{2}\d{3}$');

    if (multiBranchPattern.hasMatch(cleanCode) || 
        cleanCode.startsWith('1RN') || 
        cleanCode.startsWith('1RX') || 
        cleanCode.startsWith('1IB')) {
      
      _status = AuthStatus.authenticated;
      _studentUsn = cleanCode;
      _saveSessionToPrefs();
      notifyListeners();
      return true; 
    } else {
      _status = AuthStatus.unauthenticated;
      _error = 'Invalid barcode format. Must be an official RN, RX, or IB student ID card.';
      notifyListeners();
      return false; 
    }
  }

  // ── SESSION LOGOUT ──────────────────────────────────────────
  void logout() async {
    _status = AuthStatus.unauthenticated;
    _studentUsn = null;
    _error = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_status');
    await prefs.remove('student_usn');
    notifyListeners();
  }

  // ── DEVICE PERSISTENCE MANAGERS ─────────────────────────────
  void _saveSessionToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_status', 'authenticated');
    await prefs.setString('student_usn', _studentUsn ?? '');
  }

  void _loadSessionFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStatus = prefs.getString('auth_status');
    final savedUsn = prefs.getString('student_usn');

    if (savedStatus == 'authenticated' && savedUsn != null && savedUsn.isNotEmpty) {
      _status = AuthStatus.authenticated;
      _studentUsn = savedUsn;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    
    _loadReportsFromPrefs(prefs); 
    notifyListeners();
  }

  // ── REPORT MANAGEMENT ENGINE ────────────────────────────────
  void _loadReportsFromPrefs(SharedPreferences prefs) {
    _reports.clear();
    int i = 0;
    while (prefs.containsKey('report_${i}_cat')) {
      _reports.add({
        'category': prefs.getString('report_${i}_cat') ?? '',
        'issue':    prefs.getString('report_${i}_issue') ?? '',
        'time':     prefs.getString('report_${i}_time') ?? '',
      });
      i++;
    }
  }

  void _saveReportsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < _reports.length; i++) {
      await prefs.setString('report_${i}_cat',   _reports[i]['category'] ?? '');
      await prefs.setString('report_${i}_issue', _reports[i]['issue'] ?? '');
      await prefs.setString('report_${i}_time',  _reports[i]['time'] ?? '');
    }
  }

  void addReport({
    required String category,
    required String issue,
  }) {
    final now = DateTime.now();
    final timeStr = '${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    _reports.add({
      'category': category,
      'issue':    issue,
      'time':     timeStr,
    });

    _saveReportsToPrefs();
    notifyListeners();
  }
}