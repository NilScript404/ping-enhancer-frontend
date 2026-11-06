import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds & Surfaces
  static const bunkerBg = Color(
    0xFF0B0E15,
  ); // #0B0E15 (Main app bg & inner stat boxes)
  static const vulcanCard = Color(0xFF121620); // #121620 (Main section cards)
  static const vulcanInnerCard = Color(
    0xFF0E121B,
  ); // #0E121B (ICMP unselected server card)
  static const mirageButtonBg = Color(0xFF191E2B); // #191E2B (ICMP ⚡ button bg)
  static const navBarBg = Color(0xFF10141E); // #10141E (Bottom navigation bar)
  static const blackPearl = Color(
    0xFF020618,
  ); // #020618 (Dark text/icon on green buttons)

  // Borders & Dividers
  static const mirageBorder = Color(0xFF1D293D); // #1D293D (100%)
  static const mirageBorder90 = Color(
    0xE61D293D,
  ); // rgba(29, 41, 61, 0.9) (Search & Top Pill)
  static const mirageBorder80 = Color(
    0xCC1D293D,
  ); // rgba(29, 41, 61, 0.8) (Main cards & Nav border)
  static const mirageBorder70 = Color(
    0xB31D293D,
  ); // rgba(29, 41, 61, 0.7) (ICMP Min/Avg/Max boxes)
  static const mirageBorder60 = Color(
    0x991D293D,
  ); // rgba(29, 41, 61, 0.6) (Card internal divider)
  static const pickledBluewood80 = Color(
    0xCC314158,
  ); // rgba(49, 65, 88, 0.8) (ICMP ⚡ button border)
  static const fiord = Color(
    0xFF45556C,
  ); // #45556C (Unselected radio circle & middle dots)

  // Accents & Status Colors
  static const caribbeanGreen = Color(
    0xFF00D492,
  ); // #00D492 (Primary green, IR Relay, Min ping, 0% loss)
  static const turquoiseBlue = Color(
    0xFF5EE9B5,
  ); // #5EE9B5 ("Connected", "+Ad", active sort/badge text)
  static const dodgerBlue = Color(0xFF00BCFF); // #00BCFF ("Direct" route text)
  static const sunglowYellow = Color(0xFFFFD230); // #FFD230 (Max ping text)
  static const watermelonRed = Color(
    0xFFFF637E,
  ); // #FF637E (Packet loss > 0% text)

  // Translucent Green Fills & Borders
  static const jade10 = Color(
    0x1A00BC7D,
  ); // rgba(0, 188, 125, 0.1) (Selected row/card bg)
  static const jade15 = Color(
    0x2600BC7D,
  ); // rgba(0, 188, 125, 0.15) ("+Ad" & active sort pill bg)
  static const jade35 = Color(
    0x5900BC7D,
  ); // rgba(0, 188, 125, 0.35) ("+Ad" border)
  static const jade40 = Color(
    0x6600BC7D,
  ); // rgba(0, 188, 125, 0.4) (ICMP selected card border)
  static const caribbeanGreen20 = Color(
    0x3300D492,
  ); // rgba(0, 212, 146, 0.2) (Nav indicator & active [TR] box)
  static const caribbeanGreen50 = Color(
    0x8000D492,
  ); // rgba(0, 212, 146, 0.5) (Active [TR] & sort pill border)

  // Typography
  static const textPrimary = Color(
    0xFFF1F5F9,
  ); // #F1F5F9 (Catskill White - Titles, server names, Avg ping)
  static const textSecondary = Color(
    0xFFE2E8F0,
  ); // #E2E8F0 (Mystic - Plan name, ICMP country codes)
  static const textLightSlate = Color(
    0xFFCAD5E2,
  ); // #CAD5E2 (Botticelli - Sort button text, Home country codes)
  static const textMuted = Color(
    0xFF90A1B9,
  ); // #90A1B9 (Bali Hai - Subtitles, inactive tabs, Min/Avg labels)
  static const textPlaceholder = Color(
    0xFF62748E,
  ); // #62748E (Lynch - Search placeholder)
}
