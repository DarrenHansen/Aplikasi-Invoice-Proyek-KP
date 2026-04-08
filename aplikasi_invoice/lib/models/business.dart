class Business {
  int? id;
  String logoPath;
  String name;
  String owner;
  String address;
  String phone;
  String? website;
  List<String> paymentMethods;

  Business({
    this.id,
    required this.logoPath,
    required this.name,
    required this.owner,
    required this.address,
    required this.phone,
    this.website,
    required this.paymentMethods,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'logoPath': logoPath,
      'name': name,
      'owner': owner,
      'address': address,
      'phone': phone,
      'website': website,
      'paymentMethods': paymentMethods.join(','),
    };
  }

  factory Business.fromMap(Map<String, dynamic> map) {
    return Business(
      id: map['id'],
      logoPath: map['logoPath'] ?? '',
      name: map['name'],
      owner: map['owner'],
      address: map['address'],
      phone: map['phone'],
      website: map['website'],
      paymentMethods: map['paymentMethods']?.toString().split(',') ?? [],
    );
  }
}
