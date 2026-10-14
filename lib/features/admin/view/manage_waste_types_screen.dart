import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suchigo_collector/models/collector_model.dart';
import 'package:suchigo_collector/services/api_client.dart';
import 'package:suchigo_collector/utils/suchigo_colors.dart';

class ManageWasteTypesScreen extends StatefulWidget {
  static const routeName = '/ManageWasteTypesScreen';

  const ManageWasteTypesScreen({super.key});

  @override
  State<ManageWasteTypesScreen> createState() => _ManageWasteTypesScreenState();
}

class _ManageWasteTypesScreenState extends State<ManageWasteTypesScreen> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();

  List<WasteTypeModel> _wasteTypes = [];
  bool _isLoading = true;

  final List<WasteTypeModel> _defaultWasteTypes = [
    WasteTypeModel(
      id: 1,
      name: "Adult Daiper",
      description: "Adult Daiper",
      isActive: true,
    ),
    WasteTypeModel(
      id: 2,
      name: "Compostable Materials",
      description: "Materials suitable for composting",
      isActive: true,
    ),
    WasteTypeModel(
      id: 3,
      name: "Hair",
      description: "Hair Waste",
      isActive: true,
    ),
    WasteTypeModel(
      id: 4,
      name: "Hazardous Waste",
      description: "Dangerous materials requiring special handling",
      isActive: true,
    ),
    WasteTypeModel(
      id: 5,
      name: "Kids Daiper",
      description: "Kids Daiper",
      isActive: true,
    ),
    WasteTypeModel(
      id: 6,
      name: "Medical Waste",
      description: "Medical wastes",
      isActive: true,
    ),
    WasteTypeModel(
      id: 7,
      name: "SANITARY PAD",
      description: "Sanitary pad waste",
      isActive: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchWasteTypes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchWasteTypes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final remoteTypes = await _apiClient.getWasteTypes();
      if (mounted) {
        setState(() {
          _wasteTypes =
              remoteTypes.isNotEmpty ? remoteTypes : _defaultWasteTypes;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _wasteTypes = _defaultWasteTypes;
          _isLoading = false;
        });
      }
    }
  }

  List<WasteTypeModel> get _filteredWasteTypes {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _wasteTypes;
    return _wasteTypes.where((w) {
      final name = w.name.toLowerCase();
      final desc = (w.description ?? '').toLowerCase();
      return name.contains(query) || desc.contains(query);
    }).toList();
  }

  void _showAddWasteTypeDialog() {
    final nameController = TextEditingController();
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
              "Add New Waste Type Category",
              style: TextStyle(
                fontSize: 18.spMin,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B4D3E),
              ),
            ),
            SizedBox(height: 16.spMin),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Category Name (e.g. E-Waste, Glass)",
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
                  if (nameController.text.trim().isNotEmpty) {
                    final newType = WasteTypeModel(
                      id: _wasteTypes.length + 1,
                      name: nameController.text.trim(),
                      description: descController.text.trim().isNotEmpty
                          ? descController.text.trim()
                          : nameController.text.trim(),
                      isActive: true,
                    );
                    setState(() {
                      _wasteTypes.add(newType);
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Added ${newType.name} successfully!"),
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
                  "Save Category",
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
          "Manage Waste Types",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.spMin,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddWasteTypeDialog,
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
                        hintText: "Search categories by name, desc...",
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

          // Waste Types List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        SuchigoColors.collectorGreen,
                      ),
                    ),
                  )
                : _filteredWasteTypes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.recycling_rounded,
                              size: 48.spMin,
                              color: const Color(0xFFBDBDBD),
                            ),
                            SizedBox(height: 12.spMin),
                            Text(
                              "No waste categories found",
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
                        itemCount: _filteredWasteTypes.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: 12.spMin),
                        itemBuilder: (context, index) {
                          final waste = _filteredWasteTypes[index];

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
                                // Recycling Icon
                                Container(
                                  width: 44.spMin,
                                  height: 44.spMin,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE8F5E9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.recycling_rounded,
                                    color: const Color(0xFF1D723C),
                                    size: 22.spMin,
                                  ),
                                ),

                                SizedBox(width: 14.spMin),

                                // Category Name & Active Badge & Description
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              waste.name,
                                              style: TextStyle(
                                                fontSize: 15.5.spMin,
                                                fontWeight: FontWeight.w800,
                                                color: const Color(0xFF1A1A1A),
                                              ),
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
                                        waste.description?.isNotEmpty == true
                                            ? waste.description!
                                            : waste.name,
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
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
