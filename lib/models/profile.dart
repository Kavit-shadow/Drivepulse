// lib/models/profile.dart
class Profile {
  final int? id;
  final String? custUid;
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final dynamic totalAmount; // Can be String or number from DB
  final dynamic paidAmount;
  final dynamic dueAmount;
  final String? paymentMethod;
  final String? days;
  final String? timeslot;
  final String? vehicle;
  final String? rtoWork; // Alias for newlicence
  final String? trainerName;
  final String? trainerPhone;
  final String? registrationDate;
  final String? registrationTime;
  final String? trainingStartDate;
  final String? trainingEndDate;
  final String? formFiller;
  final bool? isAppUser; // Check if password is set

  Profile({
    this.id,
    this.custUid,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.totalAmount,
    this.paidAmount,
    this.dueAmount,
    this.paymentMethod,
    this.days,
    this.timeslot,
    this.vehicle,
    this.rtoWork,
    this.trainerName,
    this.trainerPhone,
    this.registrationDate,
    this.registrationTime,
    this.trainingStartDate,
    this.trainingEndDate,
    this.formFiller,
    this.isAppUser
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      custUid: json['cust_uid'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      totalAmount: json['totalamount'],
      paidAmount: json['paidamount'],
      dueAmount: json['dueamount'],
      paymentMethod: json['payment_method'],
      days: json['days']?.toString(), // Ensure days is string
      timeslot: json['timeslot'],
      vehicle: json['vehicle'],
      rtoWork: json['rto_work'], // Use alias from API
      trainerName: json['trainername'],
      trainerPhone: json['trainerphone'],
      registrationDate: json['registration_date'],
      registrationTime: json['registration_time'],
      trainingStartDate: json['training_start_date'],
      trainingEndDate: json['training_end_date'],
      formFiller: json['formfiller'],
      isAppUser: json['is_app_user'] == 1, // Convert DB 1/0 to bool
    );
  }

  // Helper to get due amount as double
  double get dueAmountDouble => double.tryParse(dueAmount?.toString() ?? '0') ?? 0;
}