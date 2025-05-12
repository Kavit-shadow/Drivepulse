// lib/models/user.dart
class User {
  final String custUid;
  final String name;
  // Add other fields if returned by login API and needed globally
  // final String? email;
  // final String? phone;

  User({
    required this.custUid,
    required this.name,
    // this.email,
    // this.phone,
  });

  // Factory constructor to create a User from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      custUid: json['cust_uid'] as String,
      name: json['name'] as String,
      // email: json['email'] as String?, // Uncomment if API returns these
      // phone: json['phone'] as String?,
    );
  }
}