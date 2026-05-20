// ============================================================
// RailGuide — Language Provider (Fully Localized Build)
// providers/language_provider.dart
// ============================================================

import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  Locale get currentLocale => _currentLocale;

  // Static tracking variable to allow background classes to check the active language
  static String _staticLanguageCode = 'en';

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('kn'),
  ];

  static const Map<String, String> languageLabels = {
    'en': 'English',
    'hi': 'हिन्दी',
    'kn': 'ಕನ್ನಡ',
  };

  String get currentLanguageLabel =>
      languageLabels[_currentLocale.languageCode] ?? 'English';

  void setLanguage(String languageCode) {
    _currentLocale = Locale(languageCode);
    _staticLanguageCode = languageCode; // Sync static tracker
    notifyListeners();
  }

  /// Global Static Translation Hook
  /// Allows background math/logic classes to translate strings without BuildContext
  static String translate(String key) {
    return _strings[_staticLanguageCode]?[key] ?? _strings['en']?[key] ?? key;
  }

  /// Normal instance-based translation method for UI widgets
  String t(String key) {
    return _strings[_currentLocale.languageCode]?[key] ?? _strings['en']?[key] ?? key;
  }

  // ── Localised Strings Dictionary ─────────────────────────
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'app_title': 'RailGuide',
      'home': 'Home',
      'navigate': 'Navigate',
      'support': 'Support',
      'scan_qr': 'Scan QR Code',
      'select_destination': 'Select Destination',
      'find_path': 'Find Shortest Path',
      'train_info': 'Train Information',
      'platform': 'Platform',
      'arrival': 'Arrival',
      'on_time': 'On Time',
      'delayed': 'Delayed',
      'shortest_path': 'Shortest Path',
      'step_instructions': 'Step-by-Step',
      'report_issue': 'Report an Issue',
      'help_center': 'Help Center',
      'emergency': 'Emergency Contacts',
      'login': 'Login',
      'signup': 'Sign Up',
      'guest': 'Continue as Guest',
      'email': 'Email Address',
      'password': 'Password',
      'start_node': 'Start Location',
      'not_scanned': 'Not scanned yet',

      // Campus Nodes
      'main_gate': 'Main Gate',
      'mechanical_block': 'Mechanical Block',
      'mba_block': 'MBA Block',
      'food_court': 'Food Court',
      'library': 'Library',
      'temple_parking': 'Temple / Parking',

      // Station Nodes
      'parking': 'Parking',
      'entrance': 'Entrance',
      'ticket_counter': 'Ticket Counter',
      'washrooms': 'Washrooms',
      'platform_1': 'Platform 1',
      'platform_2': 'Platform 2',
      'bridge_start': 'Bridge Start',
      'bridge_end': 'Bridge End',

      // Cardinal Directions
      'North': 'North', 'South': 'South', 'East': 'East', 'West': 'West',
      'North-East': 'North-East', 'North-West': 'North-West',
      'South-East': 'South-East', 'South-West': 'South-West',

      // Compass Turning Commands
      'Continue straight ahead': 'Continue straight ahead',
      'Bear right': 'Bear right', 'Turn right': 'Turn right', 'Turn sharp right': 'Turn sharp right',
      'Bear left': 'Bear left', 'Turn left': 'Turn left', 'Turn sharp left': 'Turn sharp left',

      // Instruction Core Fragments
      'start_at': '📍 Start at',
      'arrived_at': '✅ Arrived at',
      'cross_bridge': '🌉 Cross the foot-over bridge',
      'head_direction': 'Head',
      'to_node': 'to',
      'point_found': 'Point found. Move forward',
      'toward': 'toward',
      'less_than_one_meter': 'less than one meter',
      'meters': 'meters',
      'in_10_meters': 'In 10 meters',
      'then': 'then',

      // ChatBot
      'bot_welcome': 'Hello! How can I help you today?',
      'bot_option_lost': '🔍 Lost path / Find nearest nodes',
      'bot_option_helpdesk': 'ℹ️ Help Desk info',
      'bot_option_emergency': '🚨 Emergency numbers',
      'bot_lost_response': 'Don\'t worry! Here are your navigation session nodes:',
      'bot_helpdesk_response': 'You can visit the main Help Desk at the Station Entrance or call us at +91-80-2220-0000.',
      'bot_emergency_prompt': 'Which emergency service do you need?',
      'bot_helpdesk_final_response': 'Next to ticket counter please scan nearest qr code and go to ticket counter.',
      'bot_uninitialized_route': 'You haven\'t calculated a direction route yet. Please visit the front dashboard and scan a matching QR code checkpoint to map your path.',
    },
    'hi': {
      'app_title': 'रेलगाइड',
      'home': 'होम',
      'navigate': 'नेविगेट',
      'support': 'सहायता',
      'scan_qr': 'QR कोड स्कैन करें',
      'select_destination': 'गंतव्य चुनें',
      'find_path': 'सबसे छोटा रास्ता खोजें',
      'train_info': 'ट्रेन जानकारी',
      'platform': 'प्लेटफॉर्म',
      'arrival': 'आगमन',
      'on_time': 'समय पर',
      'delayed': 'विलंबित',
      'shortest_path': 'सबसे छोटा रास्ता',
      'step_instructions': 'कदम-दर-कदम',
      'report_issue': 'समस्या रिपोर्ट करें',
      'help_center': 'सहायता केंद्र',
      'emergency': 'आपातकालीन संपर्क',
      'login': 'लॉग इन',
      'signup': 'साइन अप',
      'guest': 'अतिथि के रूप में जारी रखें',
      'email': 'ईमेल पता',
      'password': 'पासवर्ड',
      'start_node': 'प्रारंभ स्थान',
      'not_scanned': 'अभी तक स्कैन नहीं किया',

      // Campus Nodes
      'main_gate': 'मुख्य द्वार (Main Gate)',
      'mechanical_block': 'मैकेनिकल ब्लॉक (Mechanical Block)',
      'mba_block': 'एमबीए ब्लॉक (MBA Block)',
      'food_court': 'फूड कोर्ट (Food Court)',
      'library': 'पुस्तकालय (Library)',
      'temple_parking': 'मंदिर / पार्किंग (Temple/Parking)',

      // Station Nodes
      'parking': 'पार्किंग क्षेत्र',
      'entrance': 'प्रवेश द्वार',
      'ticket_counter': 'टिकट काउंटर',
      'washrooms': 'शौचालय',
      'platform_1': 'प्लेटफॉर्म 1',
      'platform_2': 'प्लेटफॉर्म 2',
      'bridge_start': 'पुल की शुरुआत',
      'bridge_end': 'पुल का अंत',

      // Cardinal Directions
      'North': 'उत्तर', 'South': 'दक्षिण', 'East': 'पूर्व', 'West': 'पश्चिम',
      'North-East': 'उत्तर-पूर्व', 'North-West': 'उत्तर-पश्चिम',
      'South-East': 'दक्षिण-पूर्व', 'South-West': 'दक्षिण-पश्चिम',

      // Compass Turning Commands
      'Continue straight ahead': 'सीधे आगे बढ़ें',
      'Bear right': 'हल्का दाएँ मुड़ें', 'Turn right': 'दाएँ मुड़ें', 'Turn sharp right': 'तेजी से दाएँ मुड़ें',
      'Bear left': 'हल्का बाएँ मुड़ें', 'Turn left': 'बाएँ मुड़ें', 'Turn sharp left': 'तेजी से बाएँ मुड़ें',

      // Instruction Core Fragments
      'start_at': '📍 शुरुआत करें:',
      'arrived_at': '✅ पहुँच गए:',
      'cross_bridge': '🌉 पैदल चलने वाले पुल को पार करें',
      'head_direction': 'दिशा में जाएँ:',
      'to_node': 'से',
      'point_found': 'स्थान मिल गया। आगे बढ़ें',
      'toward': 'की ओर',
      'less_than_one_meter': 'एक मीटर से कम',
      'meters': 'मीटर',
      'in_10_meters': '10 मीटर के बाद',
      'then': 'फिर',

      // ChatBot
      'bot_welcome': 'नमस्ते! आज मैं आपकी क्या सहायता कर सकता हूँ?',
      'bot_option_lost': '🔍 रास्ता खो गया / नजदीकी नोड्स खोजें',
      'bot_option_helpdesk': 'ℹ️ हेल्प डेस्क की जानकारी',
      'bot_option_emergency': '🚨 आपातकालीन नंबर',
      'bot_lost_response': 'चिंता न करें! यहाँ आपके नेविगेशन सत्र के नोड्स हैं:',
      'bot_helpdesk_response': 'आप स्टेशन प्रवेश द्वार पर मुख्य हेल्प डेस्क पर जा सकते हैं या +91-80-2220-0000 पर कॉल कर सकते हैं।',
      'bot_emergency_prompt': 'आपको कौन सी आपातकालीन सेवा की आवश्यकता है?',
      'bot_helpdesk_final_response': 'टिकट काउंटर के बगल में, कृपया निकटतम क्यूआर कोड को स्कैन करें और टिकट काउंटर पर जाएं।',
      'bot_uninitialized_route': 'आपने अभी तक कोई नेविगेशन मार्ग निर्धारित नहीं किया है। कृपया मुख्य डैशबोर्ड पर जाएं और अपना रास्ता खोजने के लिए क्यूआर कोड स्कैन करें।',
    },
    'kn': {
      'app_title': 'ರೈಲ್‌ಗೈಡ್',
      'home': 'ಮನೆ',
      'navigate': 'ನ್ಯಾವಿಗೇಟ್',
      'support': 'ಬೆಂಬಲ',
      'scan_qr': 'QR ಕೋಡ್ ಸ್ಕ್ಯಾನ್ ಮಾಡಿ',
      'select_destination': 'ಗಮ್ಯಸ್ಥಾನ ಆಯ್ಕೆಮಾಡಿ',
      'find_path': 'ಅತ್ಯಂತ ಚಿಕ್ಕ ಮಾರ್ಗ ಹುಡುಕಿ',
      'train_info': 'ರೈಲು ಮಾಹಿತಿ',
      'platform': 'ಪ್ಲಾಟ್‌ಫಾರ್ಮ್',
      'arrival': 'ಆಗಮನ',
      'on_time': 'ಸಮಯಕ್ಕೆ',
      'delayed': 'ವಿಳಂಬ',
      'shortest_path': 'ಅತ್ಯಂತ ಚಿಕ್ಕ ಮಾರ್ಗ',
      'step_instructions': 'ಹಂತ-ಹಂತ',
      'report_issue': 'ಸಮಸ್ಯೆ ವರದಿ ಮಾಡಿ',
      'help_center': 'ಸಹಾಯ ಕೇಂದ್ರ',
      'emergency': 'ತುರ್ತು ಸಂಪರ್ಕಗಳು',
      'login': 'ಲಾಗಿನ್',
      'signup': 'ಸೈನ್ ಅಪ್',
      'guest': 'ಅತಿಥಿಯಾಗಿ ಮುಂದುವರಿಯಿರಿ',
      'email': 'ಇಮೇಲ್ ವಿಳಾಸ',
      'password': 'ಪಾಸ್‌ವರ್ಡ್',
      'start_node': 'ಪ್ರಾರಂಭ ಸ್ಥಳ',
      'not_scanned': 'ಇನ್ನೂ ಸ್ಕ್ಯಾನ್ ಮಾಡಿಲ್ಲ',

      // Campus Nodes
      'main_gate': 'ಮುಖ್ಯ ದ್ವಾರ (Main Gate)',
      'mechanical_block': 'ಮೆಕ್ಯಾನಿಕಲ್ ಬ್ಲಾಕ್ (Mechanical Block)',
      'mba_block': 'ಎಂಬಿಎ ಬ್ಲಾಕ್ (MBA Block)',
      'food_court': 'ಫುಡ್ ಕೋರ್ಟ್ (Food Court)',
      'library': 'ಗ್ರಂಥಾಲಯ (Library)',
      'temple_parking': 'ದೇವಸ್ಥಾನ / ಪಾರ್ಕಿಂಗ್ (Temple/Parking)',

      // Station Nodes
      'parking': 'ಪಾರ್ಕಿಂಗ್',
      'entrance': 'ಪ್ರವೇಶ ದ್ವಾರ',
      'ticket_counter': 'ಟಿಕೆಟ್ ಕೌಂಟರ್',
      'washrooms': 'ಶೌಚಾಲಯಗಳು',
      'platform_1': 'ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ 1',
      'platform_2': 'ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ 2',
      'bridge_start': 'ಸೇತುವೆಯ ಪ್ರಾರಂಭ',
      'bridge_end': 'ಸೇತುವೆಯ ಕೊನೆ',

      // Cardinal Directions
      'North': 'ಉತ್ತರ', 'South': 'ದಕ್ಷಿಣ', 'East': 'ಪೂರ್ವ', 'West': 'ಪಶ್ಚಿಮ',
      'North-East': 'ಈಶಾನ್ಯ', 'North-West': 'ವಾಯುವ್ಯ',
      'South-East': 'ಆಗ್ನೇಯ', 'South-West': 'ನೈರುತ್ಯ',

      // Compass Turning Commands
      'Continue straight ahead': 'ನೇರವಾಗಿ ಮುಂದುವರಿಯಿರಿ',
      'Bear right': 'ಸ್ವಲ್ಪ ಬಲಕ್ಕೆ ತಿರುಗಿ', 'Turn right': 'ಬಲಕ್ಕೆ ತಿರುಗಿ', 'Turn sharp right': 'ತೀಕ್ಷ್ಣವಾಗಿ ಬಲಕ್ಕೆ ತಿರುಗಿ',
      'Bear left': 'ಸ್ವಲ್ಪ ಎಡಕ್ಕೆ ತಿರುಗಿ', 'Turn left': 'ಎಡಕ್ಕೆ ತಿರುಗಿ', 'Turn sharp left': 'ತೀಕ್ಷ್ಣವಾಗಿ ಎಡಕ್ಕೆ ತಿರುಗಿ',

      // Instruction Core Fragments
      'start_at': '📍 ಇಲ್ಲಿಂದ ಪ್ರಾರಂಭಿಸಿ:',
      'arrived_at': '✅ ತಲುಪಿದ್ದೀರಿ:',
      'cross_bridge': '🌉 ಪಾದಚಾರಿ ಸೇತುವೆಯನ್ನು ದಾಟಿ',
      'head_direction': 'ಚಲಿಸಿ',
      'to_node': 'ಗೆ',
      'point_found': 'ಸ್ಥಳ ಪತ್ತೆಯಾಗಿದೆ. ಮುಂದೆ ಹೋಗಿ',
      'toward': 'ಕಡೆಗೆ',
      'less_than_one_meter': 'ಒಂದು ಮೀಟರ್‌ಗಿಂತ ಕಡಿಮೆ',
      'meters': 'ಮೀಟರ್',
      'in_10_meters': '10 ಮೀಟರ್‌ಗಳ ನಂತರ',
      'then': 'ನಂತರ',

      // ChatBot
      'bot_welcome': 'ನಮಸ್ಕಾರ! ಇಂದು ನಾನು ನಿಮಗೆ ಹೇಗೆ ಸಹಾಯ ಮಾಡಲಿ?',
      'bot_option_lost': '🔍 ಮಾರ್ಗ ಕಳೆದುಹೋಗಿದೆ / ಹತ್ತಿರದ ನೋಡ್‌ಗಳನ್ನು ಹುಡುಕಿ',
      'bot_option_helpdesk': 'ℹ️ ಸಹಾಯ ಕೇಂದ್ರದ ಮಾಹಿತಿ',
      'bot_option_emergency': '🚨 ತುರ್ತು ಸಂಖ್ಯೆಗಳು',
      'bot_lost_response': 'ಚಿಂತಿಸಬೇಡಿ! ನಿಮ್ಮ ನ್ಯಾವಿಗೇಶನ್ ನೋಡ್‌ಗಳು ಇಲ್ಲಿವೆ:',
      'bot_helpdesk_response': 'ನೀವು ನಿಲ್ದಾಣದ ಪ್ರವೇಶದ್ವಾರದಲ್ಲಿರುವ ಮುಖ್ಯ ಸಹಾಯ ಕೇಂದ್ರಕ್ಕೆ ಭೇಟಿ ನೀಡಬಹುದು ಅಥವಾ +91-80-2220-0000 ಗೆ ಕರೆ ಮಾಡಬಹುದು.',
      'bot_emergency_prompt': 'ನಿಮಗೆ ಯಾವ ತುರ್ತು ಸೇವೆಯ ಅಗತ್ಯವಿದೆ?',
      'bot_helpdesk_final_response': 'ಟಿಕೆಟ್ ಕೌಂಟರ್ ಪಕ್ಕದಲ್ಲಿ, ದಯವಿಟ್ಟು ಹತ್ತಿರದ ಕ್ಯೂಆರ್ ಕೋಡ್ ಅನ್ನು ಸ್ಕ್ಯಾನ್ ಮಾಡಿ ಮತ್ತು ಟಿಕೆಟ್ ಕೌಂಟರ್‌ಗೆ ಹೋಗಿ.',
      'bot_uninitialized_route': 'ನೀವು ಇನ್ನು ಯಾವುದೇ ನ್ಯಾವಿಗೇಶನ್ ಮಾರ್ಗವನ್ನು ಆಯ್ಕೆ ಮಾಡಿಲ್ಲ. ದಯವಿಟ್ಟು ಮುಖ್ಯ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್‌ಗೆ ಹೋಗಿ ಹತ್ತಿರದ ಕ್ಯೂಆರ್ ಕೋಡ್ ಅನ್ನು ಸ್ಕ್ಯಾನ್ ಮಾಡಿ.',
    },
  };
}