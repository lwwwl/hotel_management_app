class User {
  final String id;
  final String username;
  final String password;
  final String name;
  final String role;
  final String? email;
  final String? phone;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.role,
    this.email,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      name: json['name'],
      role: json['role'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'name': name,
      'role': role,
      'email': email,
      'phone': phone,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? password,
    String? name,
    String? role,
    String? email,
    String? phone,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}

class UserSettings {
  final String language;
  final bool notificationsEnabled;
  final String cacheSize;

  UserSettings({
    required this.language,
    required this.notificationsEnabled,
    required this.cacheSize,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      language: json['language'] ?? 'zh-CN',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      cacheSize: json['cacheSize'] ?? '0 MB',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'cacheSize': cacheSize,
    };
  }

  UserSettings copyWith({
    String? language,
    bool? notificationsEnabled,
    String? cacheSize,
  }) {
    return UserSettings(
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      cacheSize: cacheSize ?? this.cacheSize,
    );
  }
}
