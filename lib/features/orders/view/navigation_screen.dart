import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_collector/features/orders/view_model/order_view_model.dart';
import 'package:suchigo_collector/models/collector_model.dart';
import 'package:suchigo_collector/services/api_client.dart';
import 'package:suchigo_collector/utils/url_launcher_helper.dart';

class NavigationScreen extends StatefulWidget {
  static const routeName = '/NavigationScreen';

  final LocationPickupModel order;

  const NavigationScreen({
    super.key,
    required this.order,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final ApiClient _apiClient = ApiClient();

  String get _estimatedTime {
    final now = DateTime.now().add(const Duration(minutes: 2));
    return DateFormat('HH:mm').format(now);
  }

  String _formatAddress(LocationPickupModel order) {
    final parts = [
      order.street,
      order.city,
      order.district,
      order.state,
      order.zipCode,
    ].where((e) => e != null && e.trim().isNotEmpty).toList();

    if (parts.isEmpty) {
      return order.ward ?? "9F, Infopark Phase 2, Kochi, Kakkanad, Kerala";
    }
    return parts.join(", ");
  }

  Future<void> _handleReachedLocation() async {
    final orderVm = context.read<OrderViewModel>();
    if (orderVm.isReaching) return;

    orderVm.setReaching(true);

    try {
      final effectivePickupId = widget.order.pickupId ?? widget.order.id;
      await _apiClient.updatePickupStatus(
        pickupId: effectivePickupId,
        locationId: widget.order.id,
        status: 'reached',
      );
      orderVm.setLocalStatus(widget.order.id, 'reached');
      orderVm.setReaching(false);

      if (mounted) {
        Fluttertoast.showToast(
          msg: "You have reached customer location!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xFF1D723C),
          textColor: Colors.white,
          fontSize: 14.0,
        );
        Navigator.pop(context, 'reached');
      }
    } catch (_) {
      orderVm.setLocalStatus(widget.order.id, 'reached');
      orderVm.setReaching(false);
      if (mounted) {
        Fluttertoast.showToast(
          msg: "You have reached customer location!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xFF1D723C),
          textColor: Colors.white,
          fontSize: 14.0,
        );
        Navigator.pop(context, 'reached');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final isReaching = context.watch<OrderViewModel>().isReaching;
    final fullAddress = _formatAddress(order);
    final displayName = order.name.isNotEmpty ? order.name : "Raina";

    final screenSize = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F8),
        body: SizedBox(
          width: screenSize.width,
          height: screenSize.height,
          child: Stack(
            children: [
              // 1. Full Screen Realistic Vector Map with Landmarks
              Positioned.fill(
                child: CustomPaint(
                  size: Size(screenSize.width, screenSize.height),
                  painter: _MapCanvasPainter(),
                  child: _buildMapOverlayMarkers(screenSize.width, screenSize.height),
                ),
              ),

              // 2. Top Header: Circular Back Button + Green Route Pill
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.spMin,
                      vertical: 8.spMin,
                    ),
                    child: Row(
                      children: [
                        // Floating White Circular Back Button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44.spMin,
                            height: 44.spMin,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 10.spMin,
                                  offset: Offset(0, 3.spMin),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: const Color(0xFF1D723C),
                              size: 22.spMin,
                            ),
                          ),
                        ),

                        SizedBox(width: 12.spMin),

                        // Green Route Info Pill Card
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.spMin,
                              vertical: 11.spMin,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1D723C),
                              borderRadius: BorderRadius.circular(18.spMin),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 12.spMin,
                                  offset: Offset(0, 4.spMin),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Transform.rotate(
                                  angle: 45 * math.pi / 180,
                                  child: Icon(
                                    Icons.navigation_rounded,
                                    color: Colors.white,
                                    size: 22.spMin,
                                  ),
                                ),
                                SizedBox(width: 12.spMin),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Route to Customer Location",
                                        style: TextStyle(
                                          fontSize: 13.5.spMin,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -0.2.spMin,
                                        ),
                                      ),
                                      SizedBox(height: 2.spMin),
                                      Text(
                                        "Total distance: 0.2 km",
                                        style: TextStyle(
                                          fontSize: 11.5.spMin,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFFE0F2E9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Bottom Sliding Details Card (Solid White with Top Radius)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    20.spMin,
                    18.spMin,
                    20.spMin,
                    MediaQuery.of(context).padding.bottom + 16.spMin,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28.spMin),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 20.spMin,
                        offset: Offset(0, -4.spMin),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Duration & Distance Left + ETD Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "2 mins",
                                style: TextStyle(
                                  fontSize: 22.spMin,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF135C30),
                                  letterSpacing: -0.4.spMin,
                                ),
                              ),
                              SizedBox(height: 2.spMin),
                              Text(
                                "0.2 km left to customer",
                                style: TextStyle(
                                  fontSize: 13.spMin,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF757575),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.spMin,
                              vertical: 6.spMin,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(12.spMin),
                            ),
                            child: Text(
                              "ETD: $_estimatedTime",
                              style: TextStyle(
                                fontSize: 13.spMin,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1D723C),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 14.spMin),
                      Divider(
                        color: const Color(0xFFEEEEEE),
                        thickness: 1.spMin,
                        height: 1.spMin,
                      ),
                      SizedBox(height: 14.spMin),

                      // Row 2: Customer Name & Address
                      Row(
                        children: [
                          Container(
                            width: 42.spMin,
                            height: 42.spMin,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F5E9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_rounded,
                              color: const Color(0xFF1D723C),
                              size: 22.spMin,
                            ),
                          ),
                          SizedBox(width: 12.spMin),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: TextStyle(
                                    fontSize: 15.5.spMin,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                                SizedBox(height: 3.spMin),
                                Text(
                                  fullAddress,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5.spMin,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF757575),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 18.spMin),

                      // Button 1: Open in Google Maps App (Blue)
                      SizedBox(
                        width: double.infinity,
                        height: 48.spMin,
                        child: ElevatedButton(
                          onPressed: () =>
                              UrlLauncherHelper.openGoogleMaps(fullAddress),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.spMin),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                color: Colors.white,
                                size: 20.spMin,
                              ),
                              SizedBox(width: 8.spMin),
                              Text(
                                "Open in Google Maps App",
                                style: TextStyle(
                                  fontSize: 14.5.spMin,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.2.spMin,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 10.spMin),

                      // Button 2: I have Reached Location (Green)
                      SizedBox(
                        width: double.infinity,
                        height: 48.spMin,
                        child: ElevatedButton(
                          onPressed: isReaching ? null : _handleReachedLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1D723C),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF81C784),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.spMin),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                color: Colors.white,
                                size: 20.spMin,
                              ),
                              SizedBox(width: 8.spMin),
                              Text(
                                isReaching
                                    ? "Updating Status..."
                                    : "I have Reached Location",
                                style: TextStyle(
                                  fontSize: 14.5.spMin,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.2.spMin,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildMapOverlayMarkers(double w, double h) {
    return Stack(
      children: [
        // Landmark 1: Trans Asia Cyber Park
        Positioned(
          left: w * 0.05,
          top: h * 0.31,
          child: _buildLandmarkBadge(
              "Trans Asia Cyber Park\nട്രാൻസ് ഏഷ്യ സൈബർ പാർക്ക്"),
        ),

        // Landmark 2: Global Travels
        Positioned(
          left: w * 0.04,
          top: h * 0.38,
          child: _buildLandmarkIcon(
              Icons.location_on_rounded, "Global Travels"),
        ),

        // Landmark 3: DDG BIM Services
        Positioned(
          right: w * 0.08,
          top: h * 0.38,
          child: _buildLandmarkIcon(
              Icons.location_on_rounded, "DDG BIM Services Pvt"),
        ),

        // Landmark 4: LSG
        Positioned(
          right: w * 0.22,
          top: h * 0.46,
          child: _buildLandmarkIcon(
              Icons.location_on_rounded, "LSG\nഎൽഎസ്എ"),
        ),

        // Landmark 5: Santa Techy
        Positioned(
          left: w * 0.18,
          top: h * 0.55,
          child: _buildLandmarkIcon(
              Icons.location_on_rounded, "Santa Techy"),
        ),

        // Destination Pin: Red marker with 12th Floor tag
        Positioned(
          left: w * 0.28,
          top: h * 0.40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                color: const Color(0xFFE53935),
                size: 38.spMin,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.spMin,
                  vertical: 2.spMin,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(6.spMin),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4.spMin,
                    ),
                  ],
                ),
                child: Text(
                  "12th Floor",
                  style: TextStyle(
                    fontSize: 11.spMin,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF424242),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Current Collector Compass Marker: Green circle with white arrow
        Positioned(
          left: w * 0.40,
          top: h * 0.56,
          child: Container(
            width: 44.spMin,
            height: 44.spMin,
            decoration: BoxDecoration(
              color: const Color(0xFF1D723C),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3.spMin,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8.spMin,
                  offset: Offset(0, 3.spMin),
                ),
              ],
            ),
            child: Center(
              child: Transform.rotate(
                angle: -15 * math.pi / 180,
                child: Icon(
                  Icons.navigation_rounded,
                  color: Colors.white,
                  size: 24.spMin,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildLandmarkBadge(String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11.spMin,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF607D8B),
            height: 1.2,
          ),
        ),
        SizedBox(width: 4.spMin),
        Icon(
          Icons.radio_button_checked_rounded,
          color: const Color(0xFF90A4AE),
          size: 18.spMin,
        ),
      ],
    );
  }

  Widget _buildLandmarkIcon(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.radio_button_checked_rounded,
          color: const Color(0xFF90A4AE),
          size: 18.spMin,
        ),
        SizedBox(width: 4.spMin),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.spMin,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF607D8B),
          ),
        ),
      ],
    );
  }
}

class _MapCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Background land color
    final landPaint = Paint()..color = const Color(0xFFF1F5F8);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), landPaint);

    // 2. Warm beige zoning polygon in center
    final zonePaint = Paint()..color = const Color(0xFFFCF8EC);
    final zonePath = Path()
      ..moveTo(w * 0.10, h * 0.30)
      ..lineTo(w * 0.65, h * 0.30)
      ..lineTo(w * 0.55, h * 0.62)
      ..lineTo(w * 0.15, h * 0.60)
      ..close();
    canvas.drawPath(zonePath, zonePaint);

    // 3. Soft Green building zone
    final greenZonePaint = Paint()..color = const Color(0xFFE8F5E9);
    final greenZonePath = Path()
      ..moveTo(w * 0.55, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.35)
      ..lineTo(w * 0.75, h * 0.35)
      ..close();
    canvas.drawPath(greenZonePath, greenZonePaint);

    // 4. Roads (Light grey-blue thick paths)
    final roadPaint = Paint()
      ..color = const Color(0xFFD3DDE6)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 22.0;

    // Road 1: Top Curve
    final road1 = Path()
      ..moveTo(-20, h * 0.15)
      ..cubicTo(w * 0.4, h * 0.13, w * 0.6, h * 0.05, w + 20, h * 0.22);
    canvas.drawPath(road1, roadPaint);

    // Road 2: Main Right Corridor
    final road2 = Path()
      ..moveTo(w * 0.85, -20)
      ..lineTo(w * 0.95, h * 0.28)
      ..lineTo(w * 0.80, h * 0.65)
      ..lineTo(w + 30, h * 0.85);
    canvas.drawPath(road2, roadPaint);

    // Road 3: Left Bottom
    final road3 = Path()
      ..moveTo(-20, h * 0.75)
      ..lineTo(w * 0.4, h * 0.88)
      ..lineTo(w + 20, h * 0.92);
    canvas.drawPath(road3, roadPaint);

    // 5. Road Inner Fill (White)
    final roadInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 16.0;
    canvas.drawPath(road1, roadInnerPaint);
    canvas.drawPath(road2, roadInnerPaint);
    canvas.drawPath(road3, roadInnerPaint);

    // 6. Green Active Navigation Route Line
    final routePaint = Paint()
      ..color = const Color(0xFF1B7238)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 6.5;

    final routePath = Path()
      ..moveTo(w * 0.44, h * 0.56)
      ..lineTo(w * 0.50, h * 0.48)
      ..lineTo(w * 0.78, h * 0.40)
      ..lineTo(w * 0.95, h * 0.28)
      ..lineTo(w * 0.78, h * 0.15)
      ..lineTo(w * 0.26, h * 0.21);
    canvas.drawPath(routePath, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


