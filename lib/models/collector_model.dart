class CollectorModel {
  final int id;
  final String username;
  final String name;
  final String email;
  final String phone;
  final String? vehicleName;
  final String? vehicleNumber;
  final int totalPickups;
  final double totalQuantity;
  final double totalRevenue;
  final double cashCollected;
  final double onlineCollected;
  final int pickups;
  final double quantity;
  final double revenue;
  final String? district;
  final int? districtId;
  final String? localBody;
  final int? localBodyId;
  final String? localBodyName;
  final String? ward;
  final bool? isActive;

  CollectorModel({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.phone,
    this.vehicleName,
    this.vehicleNumber,
    this.totalPickups = 0,
    this.totalQuantity = 0.0,
    this.totalRevenue = 0.0,
    this.cashCollected = 0.0,
    this.onlineCollected = 0.0,
    this.pickups = 0,
    this.quantity = 0.0,
    this.revenue = 0.0,
    this.district,
    this.districtId,
    this.localBody,
    this.localBodyId,
    this.localBodyName,
    this.ward,
    this.isActive,
  });

  factory CollectorModel.fromJson(Map<String, dynamic> json) {
    final int totalP = json['total_pickups'] is int
        ? json['total_pickups'] as int
        : (json['pickups'] is int
            ? json['pickups'] as int
            : int.tryParse(json['total_pickups']?.toString() ??
                    json['pickups']?.toString() ??
                    '') ??
                0);

    final double totalQ = json['total_quantity'] != null
        ? (double.tryParse(json['total_quantity'].toString()) ?? 0.0)
        : (json['total_waste'] != null
            ? (double.tryParse(json['total_waste'].toString()) ?? 0.0)
            : (json['quantity'] != null
                ? (double.tryParse(json['quantity'].toString()) ?? 0.0)
                : 0.0));

    final double totalR = json['total_revenue'] != null
        ? (double.tryParse(json['total_revenue'].toString()) ?? 0.0)
        : (json['revenue'] != null
            ? (double.tryParse(json['revenue'].toString()) ?? 0.0)
            : 0.0);

    final double cash = json['cash_collected'] != null
        ? (double.tryParse(json['cash_collected'].toString()) ?? 0.0)
        : 0.0;

    final double online = json['online_collected'] != null
        ? (double.tryParse(json['online_collected'].toString()) ?? 0.0)
        : 0.0;

    final String? dist = json['district']?.toString();
    final int? distId = json['district_id'] is int
        ? json['district_id'] as int
        : int.tryParse(json['district_id']?.toString() ?? '');

    final String? lb = json['local_body']?.toString() ??
        json['localbody']?.toString();
    final int? lbId = json['local_body_id'] is int
        ? json['local_body_id'] as int
        : int.tryParse(json['local_body_id']?.toString() ?? '');
    final String? lbName = json['local_body_name']?.toString() ??
        json['local_body']?.toString() ??
        json['localbody']?.toString();

    final String? w = json['ward']?.toString();

    final bool? act = json['is_active'] is bool
        ? json['is_active'] as bool
        : (json['is_active'] != null
            ? (json['is_active'].toString().toLowerCase() == 'true')
            : null);

    return CollectorModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      vehicleName: json['vehicle_name']?.toString(),
      vehicleNumber: json['vehicle_number']?.toString(),
      totalPickups: totalP,
      totalQuantity: totalQ,
      totalRevenue: totalR,
      cashCollected: cash,
      onlineCollected: online,
      pickups: json['pickups'] is int
          ? json['pickups'] as int
          : int.tryParse(json['pickups']?.toString() ?? '') ?? totalP,
      quantity: json['quantity'] != null
          ? (double.tryParse(json['quantity'].toString()) ?? totalQ)
          : totalQ,
      revenue: json['revenue'] != null
          ? (double.tryParse(json['revenue'].toString()) ?? totalR)
          : totalR,
      district: dist,
      districtId: distId,
      localBody: lb,
      localBodyId: lbId,
      localBodyName: lbName,
      ward: w,
      isActive: act,
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
      'total_pickups': totalPickups,
      'total_quantity': totalQuantity,
      'total_revenue': totalRevenue,
      'cash_collected': cashCollected,
      'online_collected': onlineCollected,
      'pickups': pickups,
      'quantity': quantity,
      'revenue': revenue,
      'district': district,
      'district_id': districtId,
      'local_body': localBody,
      'local_body_id': localBodyId,
      'local_body_name': localBodyName,
      'ward': ward,
      'is_active': isActive,
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
    int? totalPickups,
    double? totalQuantity,
    double? totalRevenue,
    double? cashCollected,
    double? onlineCollected,
    int? pickups,
    double? quantity,
    double? revenue,
    String? district,
    int? districtId,
    String? localBody,
    int? localBodyId,
    String? localBodyName,
    String? ward,
    bool? isActive,
  }) {
    return CollectorModel(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      totalPickups: totalPickups ?? this.totalPickups,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      cashCollected: cashCollected ?? this.cashCollected,
      onlineCollected: onlineCollected ?? this.onlineCollected,
      pickups: pickups ?? this.pickups,
      quantity: quantity ?? this.quantity,
      revenue: revenue ?? this.revenue,
      district: district ?? this.district,
      districtId: districtId ?? this.districtId,
      localBody: localBody ?? this.localBody,
      localBodyId: localBodyId ?? this.localBodyId,
      localBodyName: localBodyName ?? this.localBodyName,
      ward: ward ?? this.ward,
      isActive: isActive ?? this.isActive,
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
      collector: json['collector'] != null &&
              json['collector'] is Map<String, dynamic>
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
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DistrictModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, name);
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalBodyModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, name);
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
  final double amount;
  final double quantityKg;
  final String? paymentMethod;
  final String? scheduleCode;
  final double? bagRate;
  final String? dayOfWeek;
  final String? pickupDateDisplay;
  final String? pickupDay;
  final int? calendarDate;
  final double? walletBalance;
  final double? latitude;
  final double? longitude;

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
    this.amount = 0.0,
    this.quantityKg = 0.0,
    this.paymentMethod,
    this.scheduleCode,
    this.bagRate,
    this.dayOfWeek,
    this.pickupDateDisplay,
    this.pickupDay,
    this.calendarDate,
    this.walletBalance,
    this.latitude,
    this.longitude,
  });

  factory LocationPickupModel.fromJson(Map<String, dynamic> json) {
    double? parsedLat;
    if (json['latitude'] != null) {
      parsedLat = double.tryParse(json['latitude'].toString());
    } else if (json['lat'] != null) {
      parsedLat = double.tryParse(json['lat'].toString());
    } else if (json['customer_lat'] != null) {
      parsedLat = double.tryParse(json['customer_lat'].toString());
    } else if (json['location_lat'] != null) {
      parsedLat = double.tryParse(json['location_lat'].toString());
    } else if (json['pickup_lat'] != null) {
      parsedLat = double.tryParse(json['pickup_lat'].toString());
    } else if (json['coordinates'] is Map &&
        (json['coordinates'] as Map)['latitude'] != null) {
      parsedLat = double.tryParse(
          (json['coordinates'] as Map)['latitude'].toString());
    } else if (json['coordinates'] is Map &&
        (json['coordinates'] as Map)['lat'] != null) {
      parsedLat =
          double.tryParse((json['coordinates'] as Map)['lat'].toString());
    }

    double? parsedLng;
    if (json['longitude'] != null) {
      parsedLng = double.tryParse(json['longitude'].toString());
    } else if (json['lng'] != null) {
      parsedLng = double.tryParse(json['lng'].toString());
    } else if (json['long'] != null) {
      parsedLng = double.tryParse(json['long'].toString());
    } else if (json['lon'] != null) {
      parsedLng = double.tryParse(json['lon'].toString());
    } else if (json['customer_lng'] != null) {
      parsedLng = double.tryParse(json['customer_lng'].toString());
    } else if (json['customer_long'] != null) {
      parsedLng = double.tryParse(json['customer_long'].toString());
    } else if (json['location_lng'] != null) {
      parsedLng = double.tryParse(json['location_lng'].toString());
    } else if (json['pickup_lng'] != null) {
      parsedLng = double.tryParse(json['pickup_lng'].toString());
    } else if (json['coordinates'] is Map &&
        (json['coordinates'] as Map)['longitude'] != null) {
      parsedLng = double.tryParse(
          (json['coordinates'] as Map)['longitude'].toString());
    } else if (json['coordinates'] is Map &&
        (json['coordinates'] as Map)['lng'] != null) {
      parsedLng =
          double.tryParse((json['coordinates'] as Map)['lng'].toString());
    }

    return LocationPickupModel(
      id: json['id'] is int
          ? json['id']
          : (int.tryParse(json['id']?.toString() ?? '') ??
              (json['location_id'] is int
                  ? json['location_id']
                  : int.tryParse(json['location_id']?.toString() ?? '') ?? 0)),
      pickupId: json['pickup_id'] is int
          ? json['pickup_id']
          : int.tryParse(json['pickup_id']?.toString() ?? ''),
      name: json['name']?.toString() ??
          json['user_name']?.toString() ??
          json['customer_name']?.toString() ??
          '',
      email: json['email']?.toString(),
      contactNumber: json['contact_number']?.toString() ??
          json['customer_number']?.toString() ??
          json['customer_phone']?.toString() ??
          json['phone']?.toString() ??
          json['mobile']?.toString() ??
          json['phone_number']?.toString() ??
          json['user_phone']?.toString() ??
          json['contact']?.toString(),
      street: json['street']?.toString() ??
          json['address']?.toString() ??
          json['delivery_address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      district: json['district']?.toString(),
      zipCode: json['zip_code']?.toString(),
      ward: json['ward']?.toString(),
      localBody: json['local_body']?.toString() ??
          json['dh_localbody']?.toString() ??
          json['localbody']?.toString() ??
          json['local_body_name']?.toString(),
      landmark: json['landmark']?.toString(),
      pickupDate: json['pickup_date']?.toString() ??
          json['date']?.toString() ??
          json['collection_date']?.toString() ??
          json['scheduled_date']?.toString(),
      pickupTimeSlot: json['pickup_time_slot']?.toString(),
      wasteType: json['waste_type']?.toString() ??
          json['waste_category']?.toString(),
      itemsDescription: json['items_description']?.toString(),
      status: json['status']?.toString(),
      vehicleName: json['vehicle_name']?.toString(),
      vehicleNumber: json['vehicle_number']?.toString(),
      amount: json['amount'] != null
          ? (double.tryParse(json['amount'].toString()) ?? 0.0)
          : (json['amount_collected'] != null
              ? (double.tryParse(json['amount_collected'].toString()) ?? 0.0)
              : (json['total_amount'] != null
                  ? (double.tryParse(json['total_amount'].toString()) ?? 0.0)
                  : (json['rate'] != null
                      ? (double.tryParse(json['rate'].toString()) ?? 0.0)
                      : 0.0))),
      quantityKg: json['quantity_kg'] != null
          ? (double.tryParse(json['quantity_kg'].toString()) ?? 0.0)
          : (json['weight_kg'] != null
              ? (double.tryParse(json['weight_kg'].toString()) ?? 0.0)
              : (json['quantity'] != null
                  ? (double.tryParse(json['quantity'].toString()) ?? 0.0)
                  : (json['weight'] != null
                      ? (double.tryParse(json['weight'].toString()) ?? 0.0)
                      : 0.0))),
      paymentMethod: json['payment_method']?.toString() ??
          json['payment_mode']?.toString() ??
          json['payment_type']?.toString(),
      scheduleCode: json['schedule_code']?.toString() ??
          json['order_id']?.toString() ??
          json['bill_no']?.toString() ??
          json['bill_id']?.toString() ??
          (json['pickup_id'] != null
              ? 'BILL-${json['pickup_id']}'
              : (json['id'] != null
                  ? 'BILL-${json['id']}'
                  : (json['location_id'] != null
                      ? 'BILL-${json['location_id']}'
                      : null))),
      bagRate: json['bag_rate'] != null
          ? (double.tryParse(json['bag_rate'].toString()) ?? 0.0)
          : (json['bag_price'] != null
              ? (double.tryParse(json['bag_price'].toString()) ?? 0.0)
              : (json['bag_amount'] != null
                  ? (double.tryParse(json['bag_amount'].toString()) ?? 0.0)
                  : (json['rate'] != null
                      ? (double.tryParse(json['rate'].toString()) ?? 0.0)
                      : null))),
      dayOfWeek: json['day_of_week']?.toString() ??
          json['pickup_day']?.toString() ??
          json['day']?.toString(),
      pickupDateDisplay: json['pickup_date_display']?.toString(),
      pickupDay: json['pickup_day']?.toString() ?? json['day']?.toString(),
      calendarDate: json['calendar_date'] is int
          ? json['calendar_date']
          : int.tryParse(json['calendar_date']?.toString() ?? ''),
      walletBalance: json['wallet_balance'] != null
          ? (double.tryParse(json['wallet_balance'].toString()) ?? 0.0)
          : (json['wallet'] != null
              ? (double.tryParse(json['wallet'].toString()) ?? 0.0)
              : null),
      latitude: parsedLat,
      longitude: parsedLng,
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
        'day_of_week': dayOfWeek,
        'pickup_date_display': pickupDateDisplay,
        'pickup_day': pickupDay,
        'calendar_date': calendarDate,
        'wallet_balance': walletBalance,
        'latitude': latitude,
        'longitude': longitude,
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
    double? amount,
    double? quantityKg,
    String? paymentMethod,
    String? scheduleCode,
    double? bagRate,
    String? dayOfWeek,
    String? pickupDateDisplay,
    String? pickupDay,
    int? calendarDate,
    double? walletBalance,
    double? latitude,
    double? longitude,
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
      amount: amount ?? this.amount,
      quantityKg: quantityKg ?? this.quantityKg,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      scheduleCode: scheduleCode ?? this.scheduleCode,
      bagRate: bagRate ?? this.bagRate,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      pickupDateDisplay: pickupDateDisplay ?? this.pickupDateDisplay,
      pickupDay: pickupDay ?? this.pickupDay,
      calendarDate: calendarDate ?? this.calendarDate,
      walletBalance: walletBalance ?? this.walletBalance,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class WardModel {
  final int id;
  final String name;
  final String? wardNumber;
  final int? localbody;
  final String? localBodyName;
  final int? pendingCount;
  final int? count;

  WardModel({
    required this.id,
    required this.name,
    this.wardNumber,
    this.localbody,
    this.localBodyName,
    this.pendingCount,
    this.count,
  });

  String get displayName => formatWardName(name, wardNumber, id);

  static String formatWardName(String rawName,
      [String? rawWardNumber, int? id]) {
    String name = rawName.trim();
    String? numStr = (rawWardNumber != null && rawWardNumber.trim().isNotEmpty)
        ? rawWardNumber.trim()
        : null;

    // Check if name has pattern like "Ward 1 - Ward Name" or "Ward 1: Ward Name"
    final wardPrefixMatch =
        RegExp(r'^Ward\s*(\d+)\s*[-:]*\s*(.*)$', caseSensitive: false)
            .firstMatch(name);
    if (wardPrefixMatch != null) {
      numStr ??= wardPrefixMatch.group(1);
      final rest = wardPrefixMatch.group(2)!.trim();
      if (rest.isNotEmpty) {
        name = rest;
      }
    }

    // Check if name has pattern like "1 - Ward Name" or "1-Ward Name"
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
    final rawPending = json['pending_count'] ?? json['count'];
    final pendingVal = rawPending is int
        ? rawPending
        : int.tryParse(rawPending?.toString() ?? '');

    final rawLocalBodyId =
        json['local_body_id'] ?? json['localbody'] ?? json['local_body'];
    final localBodyIdVal = rawLocalBodyId is int
        ? rawLocalBodyId
        : int.tryParse(rawLocalBodyId?.toString() ?? '');

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
      localbody: localBodyIdVal,
      localBodyName: json['local_body_name']?.toString() ??
          (json['local_body'] is String
              ? json['local_body']?.toString()
              : null),
      pendingCount: pendingVal,
      count: json['count'] is int
          ? json['count']
          : int.tryParse(json['count']?.toString() ?? '') ?? pendingVal,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (wardNumber != null) 'ward_number': wardNumber,
        if (localbody != null) 'localbody': localbody,
        if (localBodyName != null) 'local_body_name': localBodyName,
        if (pendingCount != null) 'pending_count': pendingCount,
        if (count != null) 'count': count,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WardModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          wardNumber == other.wardNumber;

  @override
  int get hashCode => Object.hash(id, name, wardNumber);
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
  final int? localBodyId;
  final String? localBodyName;
  final double ratePerKg;

  DisposalRateModel({
    required this.id,
    this.localBody,
    this.localBodyId,
    this.localBodyName,
    required this.ratePerKg,
  });

  factory DisposalRateModel.fromJson(Map<String, dynamic> json) {
    final parsedId = json['local_body_id'] is int
        ? json['local_body_id'] as int
        : (int.tryParse(json['local_body_id']?.toString() ?? '') ??
            (json['local_body'] is int
                ? json['local_body'] as int
                : int.tryParse(json['local_body']?.toString() ?? '')));
    final parsedName = json['local_body_name']?.toString() ??
        (json['local_body'] is String ? json['local_body'] as String : null);

    return DisposalRateModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      localBody: parsedId,
      localBodyId: parsedId,
      localBodyName: parsedName,
      ratePerKg:
          double.tryParse(json['rate_per_kg']?.toString() ?? '42') ?? 42.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'local_body': localBodyName ?? localBody,
        'local_body_id': localBodyId,
        'local_body_name': localBodyName,
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
  final double totalCash;
  final double totalOnline;
  final double totalRevenue;

  AdminDashboardStatisticsModel({
    required this.totalCollectors,
    required this.totalLocations,
    required this.pendingPickups,
    required this.assignedPickups,
    required this.completedPickups,
    required this.totalBills,
    required this.pendingCash,
    this.totalCash = 0.0,
    this.totalOnline = 0.0,
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
      pendingCash:
          double.tryParse(json['pending_cash']?.toString() ?? '') ?? 0.0,
      totalCash: json['total_cash'] != null
          ? (double.tryParse(json['total_cash'].toString()) ?? 0.0)
          : (json['cash'] != null
              ? (double.tryParse(json['cash'].toString()) ?? 0.0)
              : 0.0),
      totalOnline: json['total_online'] != null
          ? (double.tryParse(json['total_online'].toString()) ?? 0.0)
          : (json['online'] != null
              ? (double.tryParse(json['online'].toString()) ?? 0.0)
              : 0.0),
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
        'total_cash': totalCash,
        'total_online': totalOnline,
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
              totalCash: 0,
              totalOnline: 0,
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
  final int assignedBagCount;
  final List<LocationPickupModel> locations;
  final String district;
  final String localBody;
  final String ward;

  AdminCollectorHistoryModel({
    required this.collector,
    required this.bagAssignments,
    required this.totalBagAssignments,
    this.assignedBagCount = 0,
    required this.locations,
    this.district = '',
    this.localBody = '',
    this.ward = '',
  });

  factory AdminCollectorHistoryModel.fromJson(Map<String, dynamic> json) {
    CollectorModel col;
    if (json.containsKey('collector') && json['collector'] is Map) {
      col = CollectorModel.fromJson(
          Map<String, dynamic>.from(json['collector'] as Map));
    } else {
      col = CollectorModel.fromJson(json);
    }

    final rawLocations = json['locations'] ??
        json['history'] ??
        json['pickups'] ??
        json['orders'] ??
        json['records'];

    final locationsList = rawLocations is List
        ? rawLocations
            .map((item) {
              if (item is Map) {
                return LocationPickupModel.fromJson(
                    Map<String, dynamic>.from(item));
              }
              return null;
            })
            .whereType<LocationPickupModel>()
            .toList()
        : <LocationPickupModel>[];

    final bags = json['bag_assignments'] is List
        ? (json['bag_assignments'] as List)
        : <dynamic>[];

    int sumBagCounts = 0;
    for (final item in bags) {
      if (item is Map) {
        final count = item['bag_count'] ?? item['count'] ?? item['bags'];
        if (count != null) {
          sumBagCounts +=
              (count is int ? count : int.tryParse(count.toString()) ?? 0);
        }
      }
    }

    final int assignedBagCount = sumBagCounts;
    final int totalBags = sumBagCounts > 0
        ? sumBagCounts
        : (json['total_bag_assignments'] is int
            ? json['total_bag_assignments'] as int
            : (int.tryParse(json['total_bag_assignments']?.toString() ?? '') ??
                0));

    // Resolve District, Local Body, and Ward directly from collector object
    final collectorMap =
        json['collector'] is Map ? (json['collector'] as Map) : null;
    final String resolvedDistrict = (collectorMap?['district'] != null &&
            collectorMap!['district'].toString().trim().isNotEmpty)
        ? collectorMap['district'].toString().trim()
        : ((col.district != null && col.district!.trim().isNotEmpty)
            ? col.district!.trim()
            : (json['district']?.toString().trim() ?? ''));

    final String resolvedLocalBody = (collectorMap?['local_body_name'] != null &&
            collectorMap!['local_body_name'].toString().trim().isNotEmpty)
        ? collectorMap['local_body_name'].toString().trim()
        : ((collectorMap?['local_body'] != null &&
                collectorMap!['local_body'].toString().trim().isNotEmpty)
            ? collectorMap['local_body'].toString().trim()
            : ((col.localBodyName != null && col.localBodyName!.trim().isNotEmpty)
                ? col.localBodyName!.trim()
                : ((col.localBody != null && col.localBody!.trim().isNotEmpty)
                    ? col.localBody!.trim()
                    : (json['local_body_name']?.toString().trim() ??
                        json['local_body']?.toString().trim() ??
                        ''))));

    final String resolvedWard = (collectorMap?['ward'] != null &&
            collectorMap!['ward'].toString().trim().isNotEmpty)
        ? collectorMap['ward'].toString().trim()
        : ((col.ward != null && col.ward!.trim().isNotEmpty)
            ? col.ward!.trim()
            : (json['ward']?.toString().trim() ?? ''));

    return AdminCollectorHistoryModel(
      collector: col,
      bagAssignments: bags,
      totalBagAssignments: totalBags,
      assignedBagCount: assignedBagCount,
      locations: locationsList,
      district: resolvedDistrict,
      localBody: resolvedLocalBody,
      ward: resolvedWard,
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleModelItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, name);
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleNumberItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          number == other.number;

  @override
  int get hashCode => Object.hash(id, number);
}

class CollectorOverviewModel {
  final CollectorModel? collector;
  final OverviewSummaryModel overview;
  final List<DailySummaryItemModel> dailySummary;
  final List<LocationPickupModel> completedRecords;

  CollectorOverviewModel({
    this.collector,
    required this.overview,
    required this.dailySummary,
    required this.completedRecords,
  });

  factory CollectorOverviewModel.fromJson(Map<String, dynamic> json) {
    return CollectorOverviewModel(
      collector: json['collector'] is Map<String, dynamic>
          ? CollectorModel.fromJson(json['collector'] as Map<String, dynamic>)
          : null,
      overview: json['overview'] is Map<String, dynamic>
          ? OverviewSummaryModel.fromJson(
              json['overview'] as Map<String, dynamic>)
          : OverviewSummaryModel.empty(),
      dailySummary: (json['daily_summary'] is List)
          ? (json['daily_summary'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => DailySummaryItemModel.fromJson(e))
              .toList()
          : [],
      completedRecords: (json['completed_records'] is List)
          ? (json['completed_records'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => LocationPickupModel.fromJson(e))
              .toList()
          : [],
    );
  }

  factory CollectorOverviewModel.empty() {
    return CollectorOverviewModel(
      collector: null,
      overview: OverviewSummaryModel.empty(),
      dailySummary: [],
      completedRecords: [],
    );
  }
}

class OverviewSummaryModel {
  final int totalOrders;
  final double totalQuantityKg;
  final double totalAmountCollected;
  final double vehicleCapacityKg;
  final double vehicleCapacityUsedKg;
  final Map<String, double> categoryQuantities;

  OverviewSummaryModel({
    required this.totalOrders,
    required this.totalQuantityKg,
    required this.totalAmountCollected,
    this.vehicleCapacityKg = 500.0,
    this.vehicleCapacityUsedKg = 0.0,
    this.categoryQuantities = const {},
  });

  factory OverviewSummaryModel.fromJson(Map<String, dynamic> json) {
    final orders = json['total_orders'] is int
        ? json['total_orders'] as int
        : int.tryParse(json['total_orders']?.toString() ?? '') ?? 0;

    final qty = json['total_quantity_kg'] != null
        ? (double.tryParse(json['total_quantity_kg'].toString()) ?? 0.0)
        : (json['quantity_kg'] != null
            ? (double.tryParse(json['quantity_kg'].toString()) ?? 0.0)
            : (json['quantity'] != null
                ? (double.tryParse(json['quantity'].toString()) ?? 0.0)
                : 0.0));

    final amount = json['total_amount_collected'] != null
        ? (double.tryParse(json['total_amount_collected'].toString()) ?? 0.0)
        : (json['total_amount'] != null
            ? (double.tryParse(json['total_amount'].toString()) ?? 0.0)
            : (json['amount'] != null
                ? (double.tryParse(json['amount'].toString()) ?? 0.0)
                : 0.0));

    final capacity = json['vehicle_capacity_kg'] != null
        ? (double.tryParse(json['vehicle_capacity_kg'].toString()) ?? 500.0)
        : 500.0;

    final used = json['vehicle_capacity_used_kg'] != null
        ? (double.tryParse(json['vehicle_capacity_used_kg'].toString()) ?? qty)
        : qty;

    final Map<String, double> categories = {};
    if (json['category_quantities'] is Map) {
      (json['category_quantities'] as Map).forEach((k, v) {
        categories[k.toString()] = double.tryParse(v.toString()) ?? 0.0;
      });
    }

    return OverviewSummaryModel(
      totalOrders: orders,
      totalQuantityKg: qty,
      totalAmountCollected: amount,
      vehicleCapacityKg: capacity,
      vehicleCapacityUsedKg: used,
      categoryQuantities: categories,
    );
  }

  factory OverviewSummaryModel.empty() {
    return OverviewSummaryModel(
      totalOrders: 0,
      totalQuantityKg: 0.0,
      totalAmountCollected: 0.0,
    );
  }
}

class DailySummaryItemModel {
  final String date;
  final int totalOrders;
  final double totalQuantityKg;
  final double totalAmount;
  final String? wasteType;

  DailySummaryItemModel({
    required this.date,
    required this.totalOrders,
    required this.totalQuantityKg,
    required this.totalAmount,
    this.wasteType,
  });

  factory DailySummaryItemModel.fromJson(Map<String, dynamic> json) {
    return DailySummaryItemModel(
      date: json['date']?.toString() ??
          json['day']?.toString() ??
          json['pickup_date']?.toString() ??
          '',
      totalOrders: json['total_orders'] is int
          ? json['total_orders'] as int
          : (json['orders'] is int
              ? json['orders'] as int
              : int.tryParse(json['total_orders']?.toString() ??
                      json['orders']?.toString() ??
                      json['count']?.toString() ??
                      '') ??
                  0),
      totalQuantityKg: json['total_quantity_kg'] != null
          ? (double.tryParse(json['total_quantity_kg'].toString()) ?? 0.0)
          : (json['quantity_kg'] != null
              ? (double.tryParse(json['quantity_kg'].toString()) ?? 0.0)
              : (json['quantity'] != null
                  ? (double.tryParse(json['quantity'].toString()) ?? 0.0)
                  : 0.0)),
      totalAmount: json['total_amount_collected'] != null
          ? (double.tryParse(json['total_amount_collected'].toString()) ?? 0.0)
          : (json['total_amount'] != null
              ? (double.tryParse(json['total_amount'].toString()) ?? 0.0)
              : (json['amount'] != null
                  ? (double.tryParse(json['amount'].toString()) ?? 0.0)
                  : 0.0)),
      wasteType: json['waste_type']?.toString() ??
          json['category']?.toString() ??
          json['items_description']?.toString(),
    );
  }
}
