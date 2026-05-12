class User {
  String userUid;
  String loginId;
  String studentId;
  String name;
  String schoolName;
  String regionName;
  bool isEnrolled;

  User({
    required this.userUid,
    this.loginId = '',
    this.studentId = '',
    required this.name,
    this.schoolName = '',
    this.regionName = '',
    this.isEnrolled = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userUid: json['user_uid'] ?? json['uid'] ?? '',
      loginId: json['login_id'] ?? '',
      studentId: json['student_id'] ?? '',
      name: json['name'] ?? '',
      schoolName: json['school_name'] ?? '',
      regionName: json['region_name'] ?? '',
      isEnrolled: json['is_enrolled'] == 1 || json['is_enrolled'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_uid': userUid,
      'login_id': loginId,
      'student_id': studentId,
      'name': name,
      'school_name': schoolName,
      'region_name': regionName,
      'is_enrolled': isEnrolled,
    };
  }
}
