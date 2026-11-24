import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_collector/features/orders/view_model/order_view_model.dart';
import 'package:suchigo_collector/models/collector_model.dart';
import 'package:suchigo_collector/utils/suchigo_colors.dart';
import 'package:suchigo_collector/utils/url_launcher_helper.dart';

class OrdersMapScreen extends StatefulWidget {
  static const routeName = '/OrdersMapScreen';

  const OrdersMapScreen({super.key});

  @override
  State<OrdersMapScreen> createState() => _OrdersMapScreenState();
}

class _OrdersMapScreenState extends State<OrdersMapScreen> {
  GoogleMapController? _mapController;
  LocationPickupModel? _selectedOrder;
  StreamSubscription<Position>? _positionSubscription;

  static const LatLng _keralaDefault = LatLng(10.0218, 76.2905);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final orderVm = context.read<OrderViewModel>();
        // Ensure all active bookings are loaded
        if (orderVm.orders.isEmpty) {
          orderVm.fetchActiveOrders();
        }
        orderVm.fetchCurrentLocation();
        _listenLocationUpdates();
      }
    });
  }

  void _listenLocationUpdates() {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 8,
      ),
    ).listen((pos) {
      if (mounted) {
        context.read<OrderViewModel>().setCurrentPosition(pos);
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        final orderVm = context.read<OrderViewModel>();
        _fitAllMarkers(orderVm);
      }
    });
  }

  /// Fits all booking points + collector position into map viewport
  void _fitAllMarkers(OrderViewModel orderVm) {
    final points = <LatLng>[];

    if (orderVm.currentPosition != null) {
      points.add(LatLng(
        orderVm.currentPosition!.latitude,
        orderVm.currentPosition!.longitude,
      ));
    }

    final orders = orderVm.filteredOrders.isNotEmpty
        ? orderVm.filteredOrders
        : orderVm.orders;
    for (final order in orders) {
      final coords = orderVm.getOrderCoordinates(order);
      if (coords != null) {
        points.add(LatLng(coords.$1, coords.$2));
      }
    }

    if (points.isEmpty) return;

    if (points.length == 1) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 15),
      );
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    try {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 70),
      );
    } catch (_) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 13),
      );
    }
  }

  void _selectOrder(LocationPickupModel order) {
    setState(() {
      _selectedOrder = order;
    });

    final orderVm = context.read<OrderViewModel>();
    final coords = orderVm.getOrderCoordinates(order);
    if (coords != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(coords.$1, coords.$2), 16),
      );
    }
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
      return order.ward ?? "No address specified";
    }
    return parts.join(", ");
  }

  /// Displays the full bottom sheet listing out all booking locations based on distance
  void _showAllBookingsList(
    BuildContext context,
    List<LocationPickupModel> orders,
    OrderViewModel orderVm,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20.spMin,
                offset: Offset(0, -4.spMin),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(height: 10.spMin),
              // Drag Handle
              Container(
                width: 40.spMin,
                height: 4.spMin,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2.spMin),
                ),
              ),
              SizedBox(height: 12.spMin),

              // Sheet Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.spMin),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "All Booking Locations",
                          style: TextStyle(
                            fontSize: 17.spMin,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          "Sorted by distance (${orders.length} bookings plotted)",
                          style: TextStyle(
                            fontSize: 12.spMin,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1D723C),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: EdgeInsets.all(6.spMin),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18.spMin,
                          color: const Color(0xFF555555),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10.spMin),
              Divider(
                color: const Color(0xFFEEEEEE),
                thickness: 1.spMin,
                height: 1.spMin,
              ),

              // List of all bookings sorted by distance
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.spMin,
                    vertical: 12.spMin,
                  ),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.spMin),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final distanceText = orderVm.getFormattedDistance(order);
                    final isSelected = _selectedOrder?.id == order.id;
                    final fullAddress = _formatAddress(order);
                    final coords = orderVm.getOrderCoordinates(order);

                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _selectOrder(order);
                      },
                      child: Container(
                        padding: EdgeInsets.all(12.spMin),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(16.spMin),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF81C784)
                                : const Color(0xFFE0E0E0),
                            width: 1.spMin,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Point Number Pill
                                Container(
                                  width: 32.spMin,
                                  height: 32.spMin,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF1D723C)
                                        : const Color(0xFF2E7D32),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "#${index + 1}",
                                      style: TextStyle(
                                        fontSize: 11.spMin,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(width: 10.spMin),

                                // Order Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              order.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14.5.spMin,
                                                fontWeight: FontWeight.w800,
                                                color: const Color(0xFF1A1A1A),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 7.spMin,
                                              vertical: 3.spMin,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE8F5E9),
                                              borderRadius:
                                                  BorderRadius.circular(6.spMin),
                                            ),
                                            child: Text(
                                              "ORD-${order.id}",
                                              style: TextStyle(
                                                fontSize: 10.5.spMin,
                                                fontWeight: FontWeight.w800,
                                                color: const Color(0xFF1D723C),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 4.spMin),

                                      // Address
                                      Text(
                                        fullAddress,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11.5.spMin,
                                          color: const Color(0xFF616161),
                                          height: 1.25,
                                        ),
                                      ),

                                      SizedBox(height: 6.spMin),

                                      // Distance
                                      if (distanceText != null) ...[
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.near_me_rounded,
                                              size: 12.spMin,
                                              color: const Color(0xFF1D723C),
                                            ),
                                            SizedBox(width: 3.spMin),
                                            Text(
                                              distanceText,
                                              style: TextStyle(
                                                fontSize: 11.5.spMin,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF1D723C),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6.spMin),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 6.spMin),

                            // Action buttons: WhatsApp, Phone, Navigate
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // WhatsApp
                                GestureDetector(
                                  onTap: () => UrlLauncherHelper.openWhatsApp(
                                    order.contactNumber,
                                  ),
                                  child: Container(
                                    width: 32.spMin,
                                    height: 32.spMin,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE8F5E9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      color: const Color(0xFF1D723C),
                                      size: 16.spMin,
                                    ),
                                  ),
                                ),

                                SizedBox(width: 8.spMin),

                                // Phone Call
                                GestureDetector(
                                  onTap: () => UrlLauncherHelper.openDialer(
                                    order.contactNumber,
                                  ),
                                  child: Container(
                                    width: 32.spMin,
                                    height: 32.spMin,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE8F5E9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.phone_rounded,
                                      color: const Color(0xFF1D723C),
                                      size: 16.spMin,
                                    ),
                                  ),
                                ),

                                SizedBox(width: 8.spMin),

                                // Google Maps Navigation
                                GestureDetector(
                                  onTap: () => UrlLauncherHelper.openGoogleMaps(
                                    fullAddress,
                                    latitude: coords?.$1,
                                    longitude: coords?.$2,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.spMin,
                                      vertical: 6.spMin,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE3F2FD),
                                      borderRadius:
                                          BorderRadius.circular(12.spMin),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.directions_rounded,
                                          color: const Color(0xFF1976D2),
                                          size: 15.spMin,
                                        ),
                                        SizedBox(width: 4.spMin),
                                        Text(
                                          "Navigate",
                                          style: TextStyle(
                                            fontSize: 11.spMin,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1976D2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderVm = context.watch<OrderViewModel>();
    // Fetch all active orders (unfiltered) so all 9 bookings are plotted
    final allOrders = orderVm.filteredOrders.isNotEmpty
        ? orderVm.filteredOrders
        : orderVm.orders;

    final markers = <Marker>{};
    final circles = <Circle>{};

    // 1. Plot Collector's Live GPS Current Location
    if (orderVm.currentPosition != null) {
      final curPos = LatLng(
        orderVm.currentPosition!.latitude,
        orderVm.currentPosition!.longitude,
      );

      markers.add(
        Marker(
          markerId: const MarkerId('current_collector_location'),
          position: curPos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          zIndex: 1000.0,
          infoWindow: const InfoWindow(
            title: '📍 Your Location (Collector)',
            snippet: 'Collector live GPS position',
          ),
        ),
      );

      circles.add(
        Circle(
          circleId: const CircleId('current_collector_accuracy'),
          center: curPos,
          radius: 70,
          fillColor: const Color(0xFF1976D2).withValues(alpha: 0.22),
          strokeColor: const Color(0xFF1976D2),
          strokeWidth: 2,
        ),
      );
    }

    // 2. Plot ALL Bookings (Preventing coordinate overlaps so all 9 markers are clearly visible)
    final plottedPositions = <LatLng>[];

    for (int i = 0; i < allOrders.length; i++) {
      final order = allOrders[i];
      final coords = orderVm.getOrderCoordinates(order);
      if (coords == null) continue;

      double finalLat = coords.$1;
      double finalLng = coords.$2;

      // Check if another marker is placed at or very close to this position
      int overlapCount = 0;
      for (final prev in plottedPositions) {
        if ((prev.latitude - finalLat).abs() < 0.0004 &&
            (prev.longitude - finalLng).abs() < 0.0004) {
          overlapCount++;
        }
      }

      if (overlapCount > 0) {
        // Spread in a small cluster ring around the base point so every pin is distinct
        final angle = (overlapCount * 2 * math.pi) / 6;
        final radius = 0.00045 * (1 + (overlapCount ~/ 6));
        finalLat += radius * math.cos(angle);
        finalLng += radius * math.sin(angle);
      }

      final pos = LatLng(finalLat, finalLng);
      plottedPositions.add(pos);

      final isSelected = _selectedOrder?.id == order.id;
      final distanceText = orderVm.getFormattedDistance(order);
      final fullAddress = _formatAddress(order);

      markers.add(
        Marker(
          markerId: MarkerId('order_${order.id}_$i'),
          position: pos,
          icon: isSelected
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: '#${i + 1}: ${order.name}',
            snippet:
                'ORD-${order.id} • ${distanceText ?? ''} • Tap to Navigate',
            onTap: () => UrlLauncherHelper.openGoogleMaps(
              fullAddress,
              latitude: pos.latitude,
              longitude: pos.longitude,
            ),
          ),
          onTap: () => _selectOrder(order),
        ),
      );
    }

    // Initial Camera Position (Collector location if available, otherwise first booking)
    LatLng initialPos = _keralaDefault;
    if (orderVm.currentPosition != null) {
      initialPos = LatLng(
        orderVm.currentPosition!.latitude,
        orderVm.currentPosition!.longitude,
      );
    } else if (allOrders.isNotEmpty) {
      final c = orderVm.getOrderCoordinates(allOrders.first);
      if (c != null) {
        initialPos = LatLng(c.$1, c.$2);
      }
    }

    final bookingCount = allOrders.length;
    final hasCurrentLocation = orderVm.currentPosition != null;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Full-screen Google Map pointing out all bookings + current location
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPos,
              zoom: 13.0,
            ),
            markers: markers,
            circles: circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            onMapCreated: _onMapCreated,
          ),

          // 2. Top Header Bar: Back Button, Title Pill, List View & Fit All Button
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.spMin,
                vertical: 10.spMin,
              ),
              child: Row(
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42.spMin,
                      height: 42.spMin,
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

                  SizedBox(width: 8.spMin),

                  // Title Pill with Count
                  Expanded(
                    child: Container(
                      height: 42.spMin,
                      padding: EdgeInsets.symmetric(horizontal: 12.spMin),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22.spMin),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 10.spMin,
                            offset: Offset(0, 3.spMin),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: const Color(0xFF1D723C),
                            size: 18.spMin,
                          ),
                          SizedBox(width: 6.spMin),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Booking Locations",
                                  style: TextStyle(
                                    fontSize: 13.spMin,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                                Text(
                                  hasCurrentLocation
                                      ? "📍 You + $bookingCount bookings"
                                      : "$bookingCount bookings plotted",
                                  style: TextStyle(
                                    fontSize: 10.5.spMin,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1D723C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 8.spMin),

                  // "List (X)" Button: Lists out all booking locations based on distance
                  GestureDetector(
                    onTap: () =>
                        _showAllBookingsList(context, allOrders, orderVm),
                    child: Container(
                      height: 42.spMin,
                      padding: EdgeInsets.symmetric(horizontal: 12.spMin),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22.spMin),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 10.spMin,
                            offset: Offset(0, 3.spMin),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.format_list_bulleted_rounded,
                            color: const Color(0xFF1D723C),
                            size: 17.spMin,
                          ),
                          SizedBox(width: 4.spMin),
                          Text(
                            "List ($bookingCount)",
                            style: TextStyle(
                              fontSize: 12.spMin,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1D723C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 8.spMin),

                  // Fit All Markers Button
                  GestureDetector(
                    onTap: () => _fitAllMarkers(orderVm),
                    child: Container(
                      width: 42.spMin,
                      height: 42.spMin,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D723C),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1D723C)
                                .withValues(alpha: 0.35),
                            blurRadius: 10.spMin,
                            offset: Offset(0, 3.spMin),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.crop_free_rounded,
                        color: Colors.white,
                        size: 20.spMin,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Current Location Floating Button (Jumps directly to collector location)
          Positioned(
            right: 16.spMin,
            bottom: 24.spMin,
            child: GestureDetector(
              onTap: () async {
                await orderVm.fetchCurrentLocation();
                if (orderVm.currentPosition != null) {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(
                        orderVm.currentPosition!.latitude,
                        orderVm.currentPosition!.longitude,
                      ),
                      16.0,
                    ),
                  );
                }
              },
              child: Container(
                width: 48.spMin,
                height: 48.spMin,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12.spMin,
                      offset: Offset(0, 3.spMin),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.my_location_rounded,
                  color: const Color(0xFF1D723C),
                  size: 24.spMin,
                ),
              ),
            ),
          ),

          // 4. Empty State Message if no bookings available
          if (allOrders.isEmpty)
            Center(
              child: Container(
                margin: EdgeInsets.all(24.spMin),
                padding: EdgeInsets.all(18.spMin),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.spMin),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 14.spMin,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_off_rounded,
                      size: 40.spMin,
                      color: const Color(0xFF9E9E9E),
                    ),
                    SizedBox(height: 10.spMin),
                    Text(
                      "No active bookings available",
                      style: TextStyle(
                        fontSize: 15.spMin,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
