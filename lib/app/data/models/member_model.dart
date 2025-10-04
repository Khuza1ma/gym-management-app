import 'package:cloud_firestore/cloud_firestore.dart';

class Member {
  final String id;
  final String memberName;
  final String memberLastname;
  final int cardNumber;
  final String phoneNumber;
  final DateTime planStartDate;
  final DateTime planEndDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Member({
    required this.id,
    required this.memberName,
    required this.memberLastname,
    required this.cardNumber,
    required this.phoneNumber,
    required this.planStartDate,
    required this.planEndDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Member.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Member(
      id: doc.id,
      memberName: data['memberName'] ?? '',
      memberLastname: data['memberLastname'] ?? '',
      cardNumber: data['cardNumber'] ?? 0,
      phoneNumber: data['phoneNumber'] ?? '',
      planStartDate: (data['planStartDate'] as Timestamp).toDate(),
      planEndDate: (data['planEndDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'memberName': memberName,
      'memberLastname': memberLastname,
      'cardNumber': cardNumber,
      'phoneNumber': phoneNumber,
      'planStartDate': Timestamp.fromDate(planStartDate),
      'planEndDate': Timestamp.fromDate(planEndDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Member copyWith({
    String? id,
    String? memberName,
    String? memberLastname,
    int? cardNumber,
    String? phoneNumber,
    DateTime? planStartDate,
    DateTime? planEndDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Member(
      id: id ?? this.id,
      memberName: memberName ?? this.memberName,
      memberLastname: memberLastname ?? this.memberLastname,
      cardNumber: cardNumber ?? this.cardNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      planStartDate: planStartDate ?? this.planStartDate,
      planEndDate: planEndDate ?? this.planEndDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
