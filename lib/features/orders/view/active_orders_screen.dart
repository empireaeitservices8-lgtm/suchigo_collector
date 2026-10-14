import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_collector/features/home/view/home_screen.dart';
import 'package:suchigo_collector/features/orders/view/update_status_screen.dart';
import 'package:suchigo_collector/features/orders/view_model/order_view_model.dart';
import 'package:suchigo_collector/models/collector_model.dart';
import 'package:suchigo_collector/utils/suchigo_colors.dart';
import 'package:suchigo_collector/utils/url_launcher_helper.dart';

class ActiveOrdersScreen extends StatefulWidget {
  static const routeName = '/ActiveOrdersScreen';

  final String? filterWard;

  const ActiveOrdersScreen({super.key, this.filterWard});

  @override
  State<ActiveOrdersScreen> createState() => _ActiveOrdersScreenState();
}

class _ActiveOrdersScreenState extends State<ActiveOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final orderVm = context.read<OrderViewModel>();
        orderVm.setWardFilter(widget.filterWard);
        orderVm.fetchActiveOrders();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openDialer(String? phoneNumber) async {
    await UrlLauncherHelper.openDialer(phoneNumber);
  }

  Future<void> _openWhatsApp(String? phoneNumber) async {
    await UrlLauncherHelper.openWhatsApp(phoneNumber);
  }

  Future<void> _openGoogleMaps(String address) async {
    await UrlLauncherHelper.openGoogleMaps(address);
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

  @override
  Widget build(BuildContext context) {
    final orderVm = context.watch<OrderViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF2),
      body: Stack(
        children: [
          // Background organic curved light green circle at top right
          Positioned(
            top: -120.spMin,
            right: -80.spMin,
            child: Container(
              width: 320.spMin,
              height: 320.spMin,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE4F2DF),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 6.spMin),

                // Top Header: Back Button + Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.spMin),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(4.spMin),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: const Color(0xFF1D723C),
                            size: 24.spMin,
                          ),
                        ),
                      ),
                      SizedBox(width: 14.spMin),
                      Text(
                        "Active Orders",
                        style: TextStyle(
                          fontSize: 20.spMin,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF135C30),
                          letterSpacing: -0.3.spMin,
                        ),
                      ),
                      if (orderVm.wardFilter != null &&
                          orderVm.wardFilter!.trim().isNotEmpty) ...[
                        SizedBox(width: 8.spMin),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.spMin,
                            vertical: 3.spMin,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12.spMin),
                            border: Border.all(
                              color: const Color(0xFF81C784),
                              width: 1.spMin,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                orderVm.wardFilter!,
                                style: TextStyle(
                                  fontSize: 11.spMin,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1D723C),
                                ),
                              ),
                              SizedBox(width: 4.spMin),
                              GestureDetector(
                                onTap: () => orderVm.setWardFilter(null),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 13.spMin,
                                  color: const Color(0xFF1D723C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 14.spMin),

                // Search Bar Card
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.spMin),
                  child: Container(
                    height: 50.spMin,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18.spMin),
                      border: Border.all(
                        color: const Color(0xFFC8E6C9),
                        width: 1.spMin,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10.spMin,
                          offset: Offset(0, 3.spMin),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) =>
                          context.read<OrderViewModel>().setSearchQuery(val),
                      style: TextStyle(
                        fontSize: 14.spMin,
                        color: SuchigoColors.textDark,
                      ),
                      decoration: InputDecoration(
                        filled: false,
                        fillColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hintText: "Search by name, ward, ID or phone...",
                        hintStyle: TextStyle(
                          color: const Color(0xFF9E9E9E),
                          fontSize: 13.5.spMin,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: const Color(0xFF1D723C),
                          size: 22.spMin,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 14.spMin,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 14.spMin),

                // Orders List
                Expanded(
                  child: orderVm.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              SuchigoColors.collectorGreen,
                            ),
                          ),
                        )
                      : orderVm.filteredOrders.isEmpty
                          ? Center(
                              child: Text(
                                "No active orders found",
                                style: TextStyle(
                                  fontSize: 14.spMin,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF9E9E9E),
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              color: SuchigoColors.collectorGreen,
                              onRefresh: () => context
                                  .read<OrderViewModel>()
                                  .fetchActiveOrders(),
                              child: ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.spMin,
                                  vertical: 4.spMin,
                                ),
                                itemCount: orderVm.filteredOrders.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 14.spMin),
                                itemBuilder: (context, index) {
                                  final order = orderVm.filteredOrders[index];
                                  return _buildOrderCard(order);
                                },
                              ),
                            ),
                ),

                // Bottom Floating Home Navigation
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.spMin),
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        HomeScreen.routeName,
                        (route) => false,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 26.spMin,
                        vertical: 8.spMin,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(24.spMin),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.home_rounded,
                            color: const Color(0xFF1D723C),
                            size: 20.spMin,
                          ),
                          SizedBox(width: 8.spMin),
                          Text(
                            "Home",
                            style: TextStyle(
                              color: const Color(0xFF1D723C),
                              fontSize: 13.5.spMin,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(LocationPickupModel order) {
    final fullAddress = _formatAddress(order);
    final itemsDesc = order.itemsDescription?.isNotEmpty == true
        ? order.itemsDescription!
        : (order.wasteType?.isNotEmpty == true
            ? order.wasteType!
            : "General household waste");

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          UpdateStatusScreen.routeName,
          arguments: order,
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.spMin),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.spMin),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14.spMin,
              offset: Offset(0, 4.spMin),
            ),
          ],
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Name + Order ID Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.name,
                style: TextStyle(
                  fontSize: 16.spMin,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.spMin,
                  vertical: 4.spMin,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8.spMin),
                ),
                child: Text(
                  "ORD-${order.id}",
                  style: TextStyle(
                    fontSize: 11.5.spMin,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1D723C),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.spMin),

          // Row 2: Phone Number
          if (order.contactNumber != null &&
              order.contactNumber!.trim().isNotEmpty) ...[
            _buildDetailRow(
              icon: Icons.phone_android_rounded,
              text: order.contactNumber!,
            ),
            SizedBox(height: 8.spMin),
          ],

          // Row 3: Ward
          if (order.ward != null && order.ward!.trim().isNotEmpty) ...[
            _buildDetailRow(
              icon: Icons.grid_view_rounded,
              text: "Ward: ${WardModel.formatWardName(order.ward!)}",
            ),
            SizedBox(height: 8.spMin),
          ],

          // Row 4: Full Address
          _buildDetailRow(
            icon: Icons.map_outlined,
            text: fullAddress,
          ),
          SizedBox(height: 8.spMin),

          // Row 5: Items & Bags
          _buildDetailRow(
            icon: Icons.shopping_bag_outlined,
            text: "Items: $itemsDesc • Bags: 0",
          ),

          SizedBox(height: 14.spMin),

          // Divider
          Divider(
            color: const Color(0xFFF5F5F5),
            thickness: 1.spMin,
            height: 1.spMin,
          ),

          SizedBox(height: 12.spMin),

          // Row 6: Today Pill + 3 Action Buttons (Chat, Map, Phone)
          Row(
            children: [
              // Today Pill
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.spMin,
                  vertical: 6.spMin,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10.spMin),
                ),
                child: Text(
                  "Today",
                  style: TextStyle(
                    fontSize: 12.5.spMin,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1D723C),
                  ),
                ),
              ),

              const Spacer(),

              // Button 1: WhatsApp
              GestureDetector(
                onTap: () => _openWhatsApp(order.contactNumber),
                child: Container(
                  width: 38.spMin,
                  height: 38.spMin,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: const Color(0xFF1D723C),
                    size: 18.spMin,
                  ),
                ),
              ),

              SizedBox(width: 8.spMin),

              // Button 2: Map Location (Google Maps)
              GestureDetector(
                onTap: () => _openGoogleMaps(fullAddress),
                child: Container(
                  width: 38.spMin,
                  height: 38.spMin,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE3F2FD),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: const Color(0xFF1976D2),
                    size: 18.spMin,
                  ),
                ),
              ),

              SizedBox(width: 8.spMin),

              // Button 3: Call Customer (Dialer)
              GestureDetector(
                onTap: () => _openDialer(order.contactNumber),
                child: Container(
                  width: 38.spMin,
                  height: 38.spMin,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone_rounded,
                    color: const Color(0xFF1D723C),
                    size: 18.spMin,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2.spMin),
          child: Icon(
            icon,
            size: 16.spMin,
            color: const Color(0xFF757575),
          ),
        ),
        SizedBox(width: 10.spMin),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.spMin,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF555555),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
