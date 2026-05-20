// ============================================================
// RailGuide — Support Screen (Syntax Hierarchy Fully Verified)
// screens/support_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart'; 
import '../utils/app_theme.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.railwayBlue,
        foregroundColor: Colors.white,
        title: Text(
          lang.t('support'),
          style: GoogleFonts.rajdhani(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: AppTheme.scaffoldBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ReportIssueCard(lang: lang),
            const SizedBox(height: 20),
            _PastReportsCard(lang: lang),
            const SizedBox(height: 20),
            _EmergencyCard(lang: lang),
            const SizedBox(height: 20),
            _HowItWorksCard(lang: lang),
          ],
        ),
      ),

      // Floating Chatbot Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const _ChatbotDrawer(),
          );
        },
        backgroundColor: AppTheme.railwayBlue,
        icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
        label: Text(
          'Ask Bot',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Chatbot Sheet Drawer Implementation
// ──────────────────────────────────────────────────────────
class _ChatbotDrawer extends StatefulWidget {
  const _ChatbotDrawer();

  @override
  State<_ChatbotDrawer> createState() => _ChatbotDrawerState();
}

class _ChatbotDrawerState extends State<_ChatbotDrawer> {
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lang = context.read<LanguageProvider>();
      setState(() {
        _messages.add({
          'isBot': true,
          'text': lang.t('bot_welcome'),
        });
      });
    });
  }

void _handleOptionClick(String optionKey) {
    final lang = context.read<LanguageProvider>();
    final nav  = context.read<NavigationProvider>();

    // 1. Post dynamic localized user text bubble to stream
    setState(() {
      _messages.add({'isBot': false, 'text': lang.t(optionKey)});
    });

    // 2. Evaluate responsive chatbot track paths dynamically
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      if (optionKey == 'bot_option_lost') {
        final isCampus = nav.mode == AppNavigationMode.campus;
        final startNode = isCampus ? nav.campusStartNode : nav.startNode;
        final endNode   = isCampus ? nav.campusEndNode : nav.endNode;

        String answer;
        if (startNode == null && endNode == null) {
          // ✅ TRANSLATED: Fallback response when no active route exists
          answer = lang.t('bot_uninitialized_route');
        } else {
          // ✅ TRANSLATED: Node tracking response labels
          answer = "${lang.t('bot_lost_response')}\n\n"
              "📍 ${lang.t('start_node')}: ${startNode != null ? lang.t(startNode.id) : '---'}\n"
              "🎯 ${lang.t('select_destination')}: ${endNode != null ? lang.t(endNode.id) : '---'}";
        }

        setState(() {
          _messages.add({'isBot': true, 'text': answer});
        });

      } else if (optionKey == 'bot_option_helpdesk') {
        setState(() {
          _messages.add({
            'isBot': true, 
            // ✅ TRANSLATED: Help Desk route matches your string perfectly in all languages
            'text': lang.t('bot_helpdesk_final_response')
          });
        });

      } else if (optionKey == 'bot_option_emergency') {
        setState(() {
          _messages.add({
            'isBot': true,
            'text': "${lang.t('bot_emergency_prompt')}\n\n"
                "🚔 Railway Police (RPF): 1800-111-322\n"
                "🚑 Medical Emergency: 108"
          });
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.50,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40, height: 5,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 12),
                  Text('RailGuide Assistant', 
                    style: GoogleFonts.rajdhani(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context), 
                    icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final msg = _messages[i];
                  return _ChatBubble(isBot: msg['isBot'], text: msg['text']);
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white, 
                border: Border(top: BorderSide(color: Color(0xFFEDF2F7))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('CHOOSE A PROMPT:', 
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textLight, letterSpacing: 0.6)),
                  const SizedBox(height: 10),
                  _BotOptionChip(label: '🔍  ${lang.t('bot_option_lost')}', onTap: () => _handleOptionClick('bot_option_lost')),
                  const SizedBox(height: 6),
                  _BotOptionChip(label: 'ℹ️  ${lang.t('bot_option_helpdesk')}', onTap: () => _handleOptionClick('bot_option_helpdesk')),
                  const SizedBox(height: 6),
                  _BotOptionChip(label: '🚨  ${lang.t('bot_option_emergency')}', onTap: () => _handleOptionClick('bot_option_emergency')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotOptionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _BotOptionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.railwayBlue,
        elevation: 0,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), 
          side: BorderSide(color: AppTheme.railwayBlue.withValues(alpha: 0.18)),
        ),
      ),
      onPressed: onTap,
      child: Text(label, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600)),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final bool isBot;
  final String text;
  const _ChatBubble({required this.isBot, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isBot ? Colors.white : AppTheme.railwayBlue,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isBot ? 4 : 16),
            bottomRight: Radius.circular(isBot ? 16 : 4),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 13.5, 
            fontWeight: isBot ? FontWeight.w500 : FontWeight.w600, 
            color: isBot ? AppTheme.textPrimary : Colors.white, 
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Issue Reporting Card Module
// ──────────────────────────────────────────────────────────
class _ReportIssueCard extends StatefulWidget {
  final LanguageProvider lang;
  const _ReportIssueCard({required this.lang});
  @override
  State<_ReportIssueCard> createState() => _ReportIssueCardState();
}

class _ReportIssueCardState extends State<_ReportIssueCard> {
  final _formKey   = GlobalKey<FormState>();
  final _issueCtrl = TextEditingController();
  String? _category;
  bool _submitted  = false;
  bool _isLoading  = false;

  final categories = ['Navigation Error', 'Dirty Facility', 'Safety Concern', 'QR Code Damaged', 'Missing Signage', 'Other'];

  @override
  void dispose() {
    _issueCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    context.read<RailAuthProvider>().addReport(category: _category!, issue: _issueCtrl.text.trim());
    setState(() { _submitted = true; _isLoading = false; });
    _issueCtrl.clear(); _category = null;
    Future.delayed(const Duration(seconds: 4), () { if (mounted) setState(() => _submitted = false); });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 3))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [const Text('🚨', style: TextStyle(fontSize: 22)), const SizedBox(width: 10), Expanded(child: Text(widget.lang.t('report_issue'), style: Theme.of(context).textTheme.titleLarge, overflow: TextOverflow.ellipsis))]),
          const SizedBox(height: 16),
          if (_submitted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: AppTheme.success.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.success.withValues(alpha: 0.30))),
              child: Row(children: [const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 20), const SizedBox(width: 10), Expanded(child: Text("Report submitted successfully! We'll look into it.", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.success)))]),
            )
          else
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    hint: const Text('Select issue category'),
                    decoration: InputDecoration(prefixIcon: const Icon(Icons.category_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                    isExpanded: true,
                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.inter(fontSize: 14)))).toList(),
                    onChanged: (v) => setState(() => _category = v),
                    validator: (v) => v == null ? 'Please select a category' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _issueCtrl, maxLines: 3,
                    decoration: InputDecoration(hintText: 'Describe the issue in detail...', prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 40), child: Icon(Icons.edit_note_rounded)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please describe the issue' : null,
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(onPressed: _isLoading ? null : _submit, icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.railwayBlue)) : const Icon(Icons.send_rounded), label: Text(_isLoading ? 'Submitting...' : 'Submit Report')),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// History Log Module
// ──────────────────────────────────────────────────────────
class _PastReportsCard extends StatelessWidget {
  final LanguageProvider lang; const _PastReportsCard({required this.lang});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<RailAuthProvider>(); final reports = auth.reports;
    if (reports.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Text('📋', style: TextStyle(fontSize: 20)), const SizedBox(width: 10), Text('My Reports (${reports.length})', style: Theme.of(context).textTheme.titleMedium)]), const SizedBox(height: 14), ...reports.reversed.map((r) => _ReportTile(report: r))]),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final Map<String, String> report; const _ReportTile({required this.report});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: AppTheme.scaffoldBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppTheme.railwayBlue.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(6)), child: Text(report['category'] ?? 'Other', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.railwayBlue))), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(report['issue'] ?? '', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 4), Text(report['time'] ?? '', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLight))])), const Icon(Icons.circle, color: AppTheme.warning, size: 8)]),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Emergency Contact Directory Module
// ──────────────────────────────────────────────────────────
class _Contact { final String icon, name, number; final Color color; _Contact(this.icon, this.name, this.number, this.color); }

class _EmergencyCard extends StatelessWidget {
  final LanguageProvider lang; const _EmergencyCard({required this.lang});
  @override
  Widget build(BuildContext context) {
    final contacts = [_Contact('🚔', 'Railway Police (RPF)', '1800-111-322', AppTheme.error), _Contact('📷', 'Medical Emergency', '108', AppTheme.error), _Contact('🔧', 'Station Master', '+91-80-2220-0000', AppTheme.railwayBlue), _Contact('ℹ️', 'Enquiry Helpline', '139', AppTheme.railwayBlueMid)];
    return Container(
      padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Text('📞', style: TextStyle(fontSize: 22)), const SizedBox(width: 10), Text(lang.t('emergency'), style: Theme.of(context).textTheme.titleLarge)]), const SizedBox(height: 16), ...contacts.map((c) => _ContactTile(contact: c))]),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final _Contact contact; const _ContactTile({required this.contact});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: contact.color.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: contact.color.withValues(alpha: 0.20))),
      child: Row(children: [Text(contact.icon, style: const TextStyle(fontSize: 20)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(contact.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)), Text(contact.number, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary))])), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: contact.color, borderRadius: BorderRadius.circular(8)), child: Text('Call', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)))]),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Tutorial Informational Step Deck Card
// ──────────────────────────────────────────────────────────
class _HowItWorksCard extends StatelessWidget {
  final LanguageProvider lang;
  const _HowItWorksCard({required this.lang});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('📍', 'Find a QR code', 'Locate a QR code placard near your current position.'),
      ('📷', 'Scan the QR', 'Tap Scan QR Code and point your camera at the placard.'),
      ('🎯', 'Choose destination', 'Select where you want to go from the dropdown list.'),
      ('🗺️', 'Follow the path', "RailGuide runs Dijkstra's algorithm and shows directions.")
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('❓', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                'How It Works',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...steps.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.safetyYellow.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(step.$1, style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.$2,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step.$3,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}