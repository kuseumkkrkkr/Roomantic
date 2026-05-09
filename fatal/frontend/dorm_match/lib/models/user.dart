class User {
  final String uid;
  final String studentId;
  final String name;

  User({required this.uid, required this.studentId, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? '',
      studentId: json['student_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'student_id': studentId,
        'name': name,
      };
}
