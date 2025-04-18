class User {
  int id;
  String name;
  String email;
  String phone;
  dynamic emailVerifiedAt;
  DateTime createdAt;
  DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Manejo seguro del ID
    int userId;
    try {
      if (json["id"] is String) {
        userId = int.parse(json["id"]);
      } else {
        userId = json["id"] ?? 0;
      }
    } catch (e) {
      print('Error parseando ID de usuario: $e');
      userId = 0;
    }

    // Manejo seguro del nombre
    String userName = json["name"] ?? '';

    // Manejo seguro del email
    String userEmail = json["email"] ?? '';

    // Manejo seguro del teléfono
    String userPhone = '';
    if (json["phone"] != null) {
      if (json["phone"] is int) {
        userPhone = json["phone"].toString();
      } else if (json["phone"] is String) {
        userPhone = json["phone"];
      } else {
        userPhone = json["phone"].toString();
      }
    }

    // Manejo seguro de fechas
    DateTime createdAtDate, updatedAtDate;
    try {
      createdAtDate = json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : DateTime.now();
    } catch (e) {
      print('Error parseando created_at: $e');
      createdAtDate = DateTime.now();
    }

    try {
      updatedAtDate = json["updated_at"] != null
          ? DateTime.parse(json["updated_at"])
          : DateTime.now();
    } catch (e) {
      print('Error parseando updated_at: $e');
      updatedAtDate = DateTime.now();
    }

    return User(
      id: userId,
      name: userName,
      email: userEmail,
      phone: userPhone,
      emailVerifiedAt: json["email_verified_at"],
      createdAt: createdAtDate,
      updatedAt: updatedAtDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
