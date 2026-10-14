import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suchigo_collector/models/collector_model.dart';
import 'package:suchigo_collector/services/api_client.dart';
import 'package:suchigo_collector/utils/suchigo_colors.dart';

class ManageBagsScreen extends StatefulWidget {
  static const routeName = '/ManageBagsScreen';

  const ManageBagsScreen({super.key});

  @override
  State<ManageBagsScreen> createState() => _ManageBagsScreenState();
}

class _ManageBagsScreenState extends State<ManageBagsScreen> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();

  List<BagModel> _bags = [];
  bool _isLoading = true;

  final List<BagModel> _defaultBags = [
    BagModel(
      id: 1,
      size: "large",
      price: 10.00,
      description: "Small waste bag",
      isActive: true,
    ),
    BagModel(
      id: 2,
      size: "medium",
      price: 7.00,
      description: "Medium waste bag",
      isActive: true,
    ),
    BagModel(
      id: 3,
      size: "small",
      price: 5.00,
      description: "Small waste bag",
      isActive: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchBags();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBags() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final remoteBags = await _apiClient.getBags();
      if (mounted) {
        setState(() {
          _bags = remoteBags.isNotEmpty ? remoteBags : _defaultBags;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _bags = _defaultBags;
          _isLoading = false;
        });
      }
    }
  }

  List<BagModel> get _filteredBags {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _bags;
    return _bags.where((b) {
      final size = b.size.toLowerCase();
      final desc = (b.description ?? '').toLowerCase();
      final price = b.price.toString();
      return size.contains(query) ||
          desc.contains(query) ||
          price.contains(query);
    }).toList();
  }

  void _showAddBagDialog() {
    final sizeController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.spMin)),
        ),
        padding: EdgeInsets.fromLTRB(
          20.spMin,
          16.spMin,
          20.spMin,
          MediaQuery.of(context).viewInsets.bottom + 24.spMin,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44.spMin,
                height: 4.spMin,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6D6D6),
                  borderRadius: BorderRadius.circular(2.spMin),
                ),
              ),
            ),
            SizedBox(height: 16.spMin),
            Text(
              "Add New Bag Specification",
              style: TextStyle(
                fontSize: 18.spMin,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B4D3E),
              ),
            ),
            SizedBox(height: 16.spMin),
            TextField(
              controller: sizeController,
              decoration: InputDecoration(
                labelText: "Bag Size (e.g. Extra Large, 60L)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.spMin),
                ),
              ),
            ),
            SizedBox(height: 12.spMin),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Price (₹)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.spMin),
                ),
              ),
            ),
            SizedBox(height: 12.spMin),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.spMin),
                ),
              ),
            ),
            SizedBox(height: 20.spMin),
            SizedBox(
              width: double.infinity,
              height: 48.spMin,
              child: ElevatedButton(
                onPressed: () {
                  if (sizeController.text.trim().isNotEmpty) {
                    final newBag = BagModel(
                      id: _bags.length + 1,
                      size: sizeController.text.trim(),
                      price: double.tryParse(priceController.text.trim()) ?? 12.0,
                      description: descController.text.trim().isNotEmpty
                          ? descController.text.trim()
                          : "${sizeController.text.trim()} waste bag",
                      isActive: true,
                    );
                    setState(() {
                      _bags.add(newBag);
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Added ${newBag.size} bag successfully!"),
                        backgroundColor: SuchigoColors.collectorGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D723C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.spMin),
                  ),
                ),
                child: Text(
                  "Save Bag Specification",
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF135C30),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Manage Bags",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.spMin,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBagDialog,
        backgroundColor: const Color(0xFF1D723C),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.spMin),
        ),
        child: Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 30.spMin,
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 16.spMin),

          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.spMin),
            child: Container(
              height: 50.spMin,
              padding: EdgeInsets.symmetric(horizontal: 14.spMin),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8F1),
                borderRadius: BorderRadius.circular(18.spMin),
                border: Border.all(
                  color: const Color(0xFFC8E6C9),
                  width: 1.spMin,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: const Color(0xFF1D723C),
                    size: 22.spMin,
                  ),
                  SizedBox(width: 8.spMin),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(
                        fontSize: 14.spMin,
                        color: SuchigoColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        filled: false,
                        fillColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hintText: "Search bags by size, price, desc...",
                        hintStyle: TextStyle(
                          color: const Color(0xFF9E9E9E),
                          fontSize: 13.5.spMin,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      child: Icon(
                        Icons.close_rounded,
                        color: const Color(0xFF9E9E9E),
                        size: 18.spMin,
                      ),
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.spMin),

          // Bags List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        SuchigoColors.collectorGreen,
                      ),
                    ),
                  )
                : _filteredBags.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 48.spMin,
                              color: const Color(0xFFBDBDBD),
                            ),
                            SizedBox(height: 12.spMin),
                            Text(
                              "No bag specifications found",
                              style: TextStyle(
                                fontSize: 15.spMin,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.spMin,
                          vertical: 4.spMin,
                        ),
                        itemCount: _filteredBags.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: 12.spMin),
                        itemBuilder: (context, index) {
                          final bag = _filteredBags[index];

                          return Container(
                            padding: EdgeInsets.all(16.spMin),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.spMin),
                              border: Border.all(
                                color: const Color(0xFFC8E6C9).withValues(alpha: 0.5),
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
                            child: Row(
                              children: [
                                // Bag Icon
                                Container(
                                  width: 44.spMin,
                                  height: 44.spMin,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE8F5E9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.shopping_bag_outlined,
                                    color: const Color(0xFF1D723C),
                                    size: 22.spMin,
                                  ),
                                ),

                                SizedBox(width: 14.spMin),

                                // Bag Size & Active Badge & Description
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            bag.size,
                                            style: TextStyle(
                                              fontSize: 16.spMin,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF1A1A1A),
                                            ),
                                          ),
                                          SizedBox(width: 8.spMin),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.spMin,
                                              vertical: 2.spMin,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE8F5E9),
                                              borderRadius:
                                                  BorderRadius.circular(6.spMin),
                                            ),
                                            child: Text(
                                              "Active",
                                              style: TextStyle(
                                                fontSize: 11.spMin,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF1D723C),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.spMin),
                                      Text(
                                        bag.description?.isNotEmpty == true
                                            ? bag.description!
                                            : "${bag.size} waste bag",
                                        style: TextStyle(
                                          fontSize: 12.5.spMin,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF757575),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(width: 8.spMin),

                                // Price
                                Text(
                                  "₹${bag.price.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 16.spMin,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1D723C),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
