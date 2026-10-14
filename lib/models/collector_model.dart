class CollectorModel {
  final int id;
  final String username;
  final String name;
  final String email;
  final String phone;
  final String? vehicleName;
  final String? vehicleNumber;

  CollectorModel({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.phone,
    this.vehicleName,
    this.vehicleNumber,
  });

  factory CollectorModel.fromJson(Map<String, dynamic> json) {
    return CollectorModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      vehicleName: json['vehicle_name']?.toString(),
      vehicleNumber: json['vehicle_number']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'phone': phone,
      'vehicle_name': vehicleName,
      'vehicle_number': vehicleNumber,
    };
  }

  CollectorModel copyWith({
    int? id,
    String? username,
    String? name,
    String? email,
    String? phone,
    String? vehicleName,
    String? vehicleNumber,
  }) {
    return CollectorModel(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
    );
  }
}

class AuthResponseModel {
  final String message;
  final String token;
  final CollectorModel? collector;

  AuthResponseModel({
    required this.message,
    required this.token,
    this.collector,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      message: json['message']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      collector: json['collector'] != null && json['collector'] is Map<String, dynamic>
          ? CollectorModel.fromJson(json['collector'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'token': token,
      'collector': collector?.toJson(),
    };
  }
}

class DistrictModel {
  final int id;
  final String name;

  DistrictModel({required this.id, required this.name});

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class LocalBodyModel {
  final int id;
  final String name;
  final String localbodyType;
  final int district;

  LocalBodyModel({
    required this.id,
    required this.name,
    required this.localbodyType,
    required this.district,
  });

  factory LocalBodyModel.fromJson(Map<String, dynamic> json) {
    return LocalBodyModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      localbodyType: json['localbody_type']?.toString() ?? '',
      district: json['district'] is int
          ? json['district']
          : int.tryParse(json['district'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'localbody_type': localbodyType,
        'district': district,
      };
}

class LocationPickupModel {
  final int id;
  final int? pickupId;
  final String name;
  final String? email;
  final String? contactNumber;
  final String? street;
  final String? city;
  final String? state;
  final String? district;
  final String? zipCode;
  final String? ward;
  final String? localBody;
  final String? landmark;
  final String? pickupDate;
  final String? pickupTimeSlot;
  final String? wasteType;
  final String? itemsDescription;
  final String? status;
  final String? vehicleName;
  final String? vehicleNumber;

  LocationPickupModel({
    required this.id,
    this.pickupId,
    required this.name,
    this.email,
    this.contactNumber,
    this.street,
    this.city,
    this.state,
    this.district,
    this.zipCode,
    this.ward,
    this.localBody,
    this.landmark,
    this.pickupDate,
    this.pickupTimeSlot,
    this.wasteType,
    this.itemsDescription,
    this.status,
    this.vehicleName,
    this.vehicleNumber,
  });

  factory LocationPickupModel.fromJson(Map<String, dynamic> json) {
    return LocationPickupModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      pickupId: json['pickup_id'] is int
          ? json['pickup_id']
          : int.tryParse(json['pickup_id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      contactNumber: json['contact_number']?.toString(),
      street: json['street']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      district: json['district']?.toString(),
      zipCode: json['zip_code']?.toString(),
      ward: json['ward']?.toString(),
      localBody: json['local_body']?.toString(),
      landmark: json['landmark']?.toString(),
      pickupDate: json['pickup_date']?.toString(),
      pickupTimeSlot: json['pickup_time_slot']?.toString(),
      wasteType: json['waste_type']?.toString(),
      itemsDescription: json['items_description']?.toString(),
      status: json['status']?.toString(),
      vehicleName: json['vehicle_name']?.toString(),
      vehicleNumber: json['vehicle_number']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pickup_id': pickupId,
        'name': name,
        'email': email,
        'contact_number': contactNumber,
        'street': street,
        'city': city,
        'state': state,
        'district': district,
        'zip_code': zipCode,
        'ward': ward,
        'local_body': localBody,
        'landmark': landmark,
        'pickup_date': pickupDate,
        'pickup_time_slot': pickupTimeSlot,
        'waste_type': wasteType,
        'items_description': itemsDescription,
        'status': status,
        'vehicle_name': vehicleName,
        'vehicle_number': vehicleNumber,
      };

  LocationPickupModel copyWith({
    int? id,
    int? pickupId,
    String? name,
    String? email,
    String? contactNumber,
    String? street,
    String? city,
    String? state,
    String? district,
    String? zipCode,
    String? ward,
    String? localBody,
    String? landmark,
    String? pickupDate,
    String? pickupTimeSlot,
    String? wasteType,
    String? itemsDescription,
    String? status,
    String? vehicleName,
    String? vehicleNumber,
  }) {
    return LocationPickupModel(
      id: id ?? this.id,
      pickupId: pickupId ?? this.pickupId,
      name: name ?? this.name,
      email: email ?? this.email,
      contactNumber: contactNumber ?? this.contactNumber,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      district: district ?? this.district,
      zipCode: zipCode ?? this.zipCode,
      ward: ward ?? this.ward,
      localBody: localBody ?? this.localBody,
      landmark: landmark ?? this.landmark,
      pickupDate: pickupDate ?? this.pickupDate,
      pickupTimeSlot: pickupTimeSlot ?? this.pickupTimeSlot,
      wasteType: wasteType ?? this.wasteType,
      itemsDescription: itemsDescription ?? this.itemsDescription,
      status: status ?? this.status,
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
    );
  }
}

class WardModel {
  final int id;
  final String name;
  final String? wardNumber;
  final int? localbody;

  WardModel({
    required this.id,
    required this.name,
    this.wardNumber,
    this.localbody,
  });

  String get displayName => formatWardName(name, wardNumber, id);

  static String formatWardName(String rawName, [String? rawWardNumber, int? id]) {
    String name = rawName.trim();
    String? numStr = (rawWardNumber != null && rawWardNumber.trim().isNotEmpty)
        ? rawWardNumber.trim()
        : null;

    // Check if name has pattern like "Ward 1 - Neericode West" or "Ward 1: Neericode West"
    final wardPrefixMatch = RegExp(r'^Ward\s*(\d+)\s*[-:]*\s*(.*)$', caseSensitive: false).firstMatch(name);
    if (wardPrefixMatch != null) {
      numStr ??= wardPrefixMatch.group(1);
      final rest = wardPrefixMatch.group(2)!.trim();
      if (rest.isNotEmpty) {
        name = rest;
      }
    }

    // Check if name has pattern like "1 - Neericode West" or "1-Neericode West"
    final dashPrefixMatch = RegExp(r'^(\d+)\s*[-:]\s*(.+)$').firstMatch(name);
    if (dashPrefixMatch != null) {
      numStr ??= dashPrefixMatch.group(1);
      name = dashPrefixMatch.group(2)!.trim();
    }

    // Fallback number if still null/empty
    if ((numStr == null || numStr.isEmpty) && id != null && id > 0) {
      numStr = id.toString();
    }

    if (numStr != null && numStr.isNotEmpty) {
      if (name.isNotEmpty) {
        return '$numStr - ${name.toUpperCase()}';
      } else {
        return '$numStr - WARD $numStr';
      }
    }

    return name.toUpperCase();
  }

  factory WardModel.fromJson(Map<String, dynamic> json) {
    return WardModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ??
          (json['ward_name']?.toString() ??
              (json['ward_number'] != null
                  ? 'Ward ${json['ward_number']}'
                  : 'Ward')),
      wardNumber: json['ward_number']?.toString() ??
          json['number']?.toString() ??
          json['ward_no']?.toString() ??
          json['wardNo']?.toString(),
      localbody: json['localbody'] is int
          ? json['localbody']
          : (json['local_body'] is int
              ? json['local_body']
              : int.tryParse(json['localbody']?.toString() ??
                  json['local_body']?.toString() ??
                  '')),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (wardNumber != null) 'ward_number': wardNumber,
        if (localbody != null) 'localbody': localbody,
      };
}

class CollectorVehicleModel {
  final String vehicleName;
  final String vehicleNumber;
  final String collectorName;
  final String collectorUsername;

  CollectorVehicleModel({
    required this.vehicleName,
    required this.vehicleNumber,
    required this.collectorName,
    required this.collectorUsername,
  });

  factory CollectorVehicleModel.fromJson(Map<String, dynamic> json) {
    return CollectorVehicleModel(
      vehicleName: json['vehicle_name']?.toString() ?? '',
      vehicleNumber: json['vehicle_number']?.toString() ?? '',
      collectorName: json['collector_name']?.toString() ?? '',
      collectorUsername: json['collector_username']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'vehicle_name': vehicleName,
        'vehicle_number': vehicleNumber,
        'collector_name': collectorName,
        'collector_username': collectorUsername,
      };
}

class CollectorBagStatusModel {
  final int collectorId;
  final String collectorName;
  final int bagCount;
  final String? assignedDate;
  final String? updatedDate;

  CollectorBagStatusModel({
    required this.collectorId,
    required this.collectorName,
    required this.bagCount,
    this.assignedDate,
    this.updatedDate,
  });

  factory CollectorBagStatusModel.fromJson(Map<String, dynamic> json) {
    return CollectorBagStatusModel(
      collectorId: json['collector_id'] is int
          ? json['collector_id']
          : int.tryParse(json['collector_id'].toString()) ?? 0,
      collectorName: json['collector_name']?.toString() ?? '',
      bagCount: json['bag_count'] is int
          ? json['bag_count']
          : int.tryParse(json['bag_count'].toString()) ?? 0,
      assignedDate: json['assigned_date']?.toString(),
      updatedDate: json['updated_date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'collector_id': collectorId,
        'collector_name': collectorName,
        'bag_count': bagCount,
        'assigned_date': assignedDate,
        'updated_date': updatedDate,
      };
}

class BagModel {
  final int id;
  final String size;
  final double price;
  final String? description;
  final bool isActive;

  BagModel({
    required this.id,
    required this.size,
    required this.price,
    this.description,
    this.isActive = true,
  });

  factory BagModel.fromJson(Map<String, dynamic> json) {
    return BagModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      size: json['size']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      description: json['description']?.toString(),
      isActive: json['is_active'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'size': size,
        'price': price,
        'description': description,
        'is_active': isActive,
      };
}

class WasteTypeModel {
  final int id;
  final String name;
  final String? description;
  final bool isActive;

  WasteTypeModel({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
  });

  factory WasteTypeModel.fromJson(Map<String, dynamic> json) {
    return WasteTypeModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      isActive: json['is_active'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'is_active': isActive,
      };
}

class DisposalRateModel {
  final int id;
  final int? localBody;
  final double ratePerKg;

  DisposalRateModel({
    required this.id,
    this.localBody,
    required this.ratePerKg,
  });

  factory DisposalRateModel.fromJson(Map<String, dynamic> json) {
    return DisposalRateModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      localBody: json['local_body'] is int
          ? json['local_body']
          : int.tryParse(json['local_body']?.toString() ?? ''),
      ratePerKg:
          double.tryParse(json['rate_per_kg']?.toString() ?? '42') ?? 42.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'local_body': localBody,
        'rate_per_kg': ratePerKg,
      };
}

class AdminDashboardStatisticsModel {
  final int totalCollectors;
  final int totalLocations;
  final int pendingPickups;
  final int assignedPickups;
  final int completedPickups;
  final int totalBills;
  final double pendingCash;
  final double totalRevenue;

  AdminDashboardStatisticsModel({
    required this.totalCollectors,
    required this.totalLocations,
    required this.pendingPickups,
    required this.assignedPickups,
    required this.completedPickups,
    required this.totalBills,
    required this.pendingCash,
    required this.totalRevenue,
  });

  factory AdminDashboardStatisticsModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStatisticsModel(
      totalCollectors: json['total_collectors'] is int
          ? json['total_collectors']
          : int.tryParse(json['total_collectors']?.toString() ?? '') ?? 0,
      totalLocations: json['total_locations'] is int
          ? json['total_locations']
          : int.tryParse(json['total_locations']?.toString() ?? '') ?? 0,
      pendingPickups: json['pending_pickups'] is int
          ? json['pending_pickups']
          : int.tryParse(json['pending_pickups']?.toString() ?? '') ?? 0,
      assignedPickups: json['assigned_pickups'] is int
          ? json['assigned_pickups']
          : int.tryParse(json['assigned_pickups']?.toString() ?? '') ?? 0,
      completedPickups: json['completed_pickups'] is int
          ? json['completed_pickups']
          : int.tryParse(json['completed_pickups']?.toString() ?? '') ?? 0,
      totalBills: json['total_bills'] is int
          ? json['total_bills']
          : int.tryParse(json['total_bills']?.toString() ?? '') ?? 0,
      pendingCash: double.tryParse(json['pending_cash']?.toString() ?? '') ?? 0.0,
      totalRevenue:
          double.tryParse(json['total_revenue']?.toString() ?? '') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_collectors': totalCollectors,
        'total_locations': totalLocations,
        'pending_pickups': pendingPickups,
        'assigned_pickups': assignedPickups,
        'completed_pickups': completedPickups,
        'total_bills': totalBills,
        'pending_cash': pendingCash,
        'total_revenue': totalRevenue,
      };
}

class AdminDashboardModel {
  final AdminDashboardStatisticsModel statistics;
  final List<LocationPickupModel> recentLocations;

  AdminDashboardModel({
    required this.statistics,
    required this.recentLocations,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardModel(
      statistics: json['statistics'] is Map<String, dynamic>
          ? AdminDashboardStatisticsModel.fromJson(
              json['statistics'] as Map<String, dynamic>)
          : AdminDashboardStatisticsModel(
              totalCollectors: 0,
              totalLocations: 0,
              pendingPickups: 0,
              assignedPickups: 0,
              completedPickups: 0,
              totalBills: 0,
              pendingCash: 0,
              totalRevenue: 0,
            ),
      recentLocations: json['recent_locations'] is List
          ? (json['recent_locations'] as List)
              .map((item) =>
                  LocationPickupModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'statistics': statistics.toJson(),
        'recent_locations': recentLocations.map((l) => l.toJson()).toList(),
      };
}

class AdminCollectorHistoryModel {
  final CollectorModel collector;
  final List<dynamic> bagAssignments;
  final int totalBagAssignments;
  final List<LocationPickupModel> locations;

  AdminCollectorHistoryModel({
    required this.collector,
    required this.bagAssignments,
    required this.totalBagAssignments,
    required this.locations,
  });

  factory AdminCollectorHistoryModel.fromJson(Map<String, dynamic> json) {
    CollectorModel col;
    if (json.containsKey('collector') &&
        json['collector'] is Map<String, dynamic>) {
      col = CollectorModel.fromJson(json['collector'] as Map<String, dynamic>);
    } else {
      col = CollectorModel.fromJson(json);
    }

    final locationsList = json['locations'] is List
        ? (json['locations'] as List)
            .map((item) =>
                LocationPickupModel.fromJson(item as Map<String, dynamic>))
            .toList()
        : <LocationPickupModel>[];

    final bags = json['bag_assignments'] is List
        ? (json['bag_assignments'] as List)
        : <dynamic>[];

    final totalBags = json['total_bag_assignments'] is int
        ? json['total_bag_assignments'] as int
        : int.tryParse(json['total_bag_assignments']?.toString() ?? '') ??
            bags.length;

    return AdminCollectorHistoryModel(
      collector: col,
      bagAssignments: bags,
      totalBagAssignments: totalBags,
      locations: locationsList,
    );
  }
}

class VehicleModelItem {
  final int id;
  final String name;

  VehicleModelItem({required this.id, required this.name});

  factory VehicleModelItem.fromJson(Map<String, dynamic> json) {
    return VehicleModelItem(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class VehicleNumberItem {
  final int id;
  final String number;
  final int? vehicleModelId;

  VehicleNumberItem({
    required this.id,
    required this.number,
    this.vehicleModelId,
  });

  factory VehicleNumberItem.fromJson(Map<String, dynamic> json) {
    return VehicleNumberItem(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      number: json['number']?.toString() ?? '',
      vehicleModelId:
          json['vehicle_model'] is int ? json['vehicle_model'] as int : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        if (vehicleModelId != null) 'vehicle_model': vehicleModelId,
      };
}


