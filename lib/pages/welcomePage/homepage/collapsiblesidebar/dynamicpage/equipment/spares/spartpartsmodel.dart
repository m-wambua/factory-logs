class SparePart {
  final String name;
  final String partNumber;
  final String description;
  final int minimumStock;
  final int maximumStock;
  final String leadTime;
  final String supplierInfo;
  final String criticality;
  final String condition;
  final String warranty;
  final String usageRate;

  SparePart({
    required this.name,
    required this.partNumber,
    required this.description,
    required this.minimumStock,
    required this.maximumStock,
    required this.leadTime,
    required this.supplierInfo,
    required this.criticality,
    required this.condition,
    required this.warranty,
    required this.usageRate,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'partNumber': partNumber,
      'description': description,
      'minimumStock': minimumStock,
      'maximumStock': maximumStock,
      'leadTime': leadTime,
      'supplierInfo': supplierInfo,
      'criticality': criticality,
      'condition': condition,
      'warranty': warranty,
      'usageRate': usageRate,
    };
  }

  static SparePart fromJson(Map<String, dynamic> json) {
    return SparePart(
      name: json['name'],
      partNumber: json['partNumber'],
      description: json['description'],
      minimumStock: json['minimumStock'],
      maximumStock: json['maximumStock'],
      leadTime: json['leadTime'],
      supplierInfo: json['supplierInfo'],
      criticality: json['criticality'],
      condition: json['condition'],
      warranty: json['warranty'],
      usageRate: json['usageRate'],
    );
  }
}
