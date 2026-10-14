import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherHelper {
  /// Opens WhatsApp directly or falls back to api.whatsapp.com / wa.me
  static Future<void> openWhatsApp(String? rawPhoneNumber, {String? text}) async {
    if (rawPhoneNumber == null || rawPhoneNumber.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Phone number not available");
      return;
    }

    // Clean phone number: keep only digits
    String digits = rawPhoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 10) {
      digits = '91$digits';
    }

    final queryParam =
        text != null && text.isNotEmpty ? '?text=${Uri.encodeComponent(text)}' : '';

    final Uri whatsappNative =
        Uri.parse("whatsapp://send?phone=$digits$queryParam");
    final Uri apiWhatsapp =
        Uri.parse("https://api.whatsapp.com/send?phone=$digits$queryParam");
    final Uri waMe = Uri.parse("https://wa.me/$digits$queryParam");

    try {
      final launched = await launchUrl(
        whatsappNative,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (!launched) {
        final launched2 = await launchUrl(
          apiWhatsapp,
          mode: LaunchMode.externalApplication,
        );
        if (!launched2) {
          await launchUrl(
            waMe,
            mode: LaunchMode.externalApplication,
          );
        }
      }
    } catch (_) {
      try {
        final launched2 = await launchUrl(
          apiWhatsapp,
          mode: LaunchMode.externalApplication,
        );
        if (!launched2) {
          await launchUrl(
            waMe,
            mode: LaunchMode.externalApplication,
          );
        }
      } catch (_) {
        try {
          await launchUrl(
            waMe,
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          debugPrint('[UrlLauncherHelper] WhatsApp failed: $e');
          Fluttertoast.showToast(msg: "Could not open WhatsApp");
        }
      }
    }
  }

  /// Opens Google Maps Navigation directly
  static Future<void> openGoogleMaps(String address) async {
    if (address.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Address not available");
      return;
    }

    final encoded = Uri.encodeComponent(address.trim());
    // Direct Google Maps turn-by-turn navigation intent
    final Uri googleMapsNavUri =
        Uri.parse("google.navigation:q=$encoded&mode=d");
    final Uri googleMapsDirUri =
        Uri.parse("https://www.google.com/maps/dir/?api=1&destination=$encoded");
    final Uri googleMapsSearchUri =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$encoded");

    try {
      final launched = await launchUrl(
        googleMapsNavUri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (!launched) {
        final launched2 = await launchUrl(
          googleMapsDirUri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched2) {
          await launchUrl(
            googleMapsSearchUri,
            mode: LaunchMode.externalApplication,
          );
        }
      }
    } catch (_) {
      try {
        final launched2 = await launchUrl(
          googleMapsDirUri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched2) {
          await launchUrl(
            googleMapsSearchUri,
            mode: LaunchMode.externalApplication,
          );
        }
      } catch (_) {
        try {
          await launchUrl(
            googleMapsSearchUri,
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          debugPrint('[UrlLauncherHelper] Maps launch error: $e');
          Fluttertoast.showToast(msg: "Could not open Google Maps");
        }
      }
    }
  }

  /// Opens Phone Dialer directly
  static Future<void> openDialer(String? rawPhoneNumber) async {
    if (rawPhoneNumber == null || rawPhoneNumber.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Phone number not available");
      return;
    }

    final cleanPhone = rawPhoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri telUri = Uri(scheme: 'tel', path: cleanPhone);

    try {
      final launched = await launchUrl(
        telUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(telUri);
      }
    } catch (e) {
      debugPrint('[UrlLauncherHelper] Dialer failed: $e');
      Fluttertoast.showToast(msg: "Could not open phone dialer");
    }
  }
}
