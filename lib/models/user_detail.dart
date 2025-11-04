/// 用户详情模型（匹配后端 UserDetailResponse）
class UserDetail {
  final int userId;
  final String username;
  final String? displayName;
  final String? employeeNumber;
  final String? email;
  final String? phone;
  final bool? superAdmin;
  final int? active;
  final UserDepartmentInfo? department;
  final List<UserRoleInfo>? roles;

  UserDetail({
    required this.userId,
    required this.username,
    this.displayName,
    this.employeeNumber,
    this.email,
    this.phone,
    this.superAdmin,
    this.active,
    this.department,
    this.roles,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      userId: json['userId'] ?? 0,
      username: json['username'] ?? '',
      displayName: json['displayName'],
      employeeNumber: json['employeeNumber'],
      email: json['email'],
      phone: json['phone'],
      superAdmin: json['superAdmin'],
      active: json['active'],
      department: json['department'] != null 
          ? UserDepartmentInfo.fromJson(json['department']) 
          : null,
      roles: json['roles'] != null
          ? (json['roles'] as List).map((r) => UserRoleInfo.fromJson(r)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'displayName': displayName,
      'employeeNumber': employeeNumber,
      'email': email,
      'phone': phone,
      'superAdmin': superAdmin,
      'active': active,
      'department': department?.toJson(),
      'roles': roles?.map((r) => r.toJson()).toList(),
    };
  }

  /// 获取显示名称（优先使用 displayName，否则使用 username）
  String get name => displayName ?? username;

  /// 获取角色描述
  String get roleDescription {
    if (roles == null || roles!.isEmpty) {
      return '无角色';
    }
    return roles!.map((r) => r.roleName).join(', ');
  }

  /// 是否激活
  bool get isActive => active == 1;
}

/// 用户部门信息
class UserDepartmentInfo {
  final int? departmentId;
  final String? departmentName;

  UserDepartmentInfo({
    this.departmentId,
    this.departmentName,
  });

  factory UserDepartmentInfo.fromJson(Map<String, dynamic> json) {
    return UserDepartmentInfo(
      departmentId: json['departmentId'],
      departmentName: json['departmentName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'departmentId': departmentId,
      'departmentName': departmentName,
    };
  }
}

/// 用户角色信息
class UserRoleInfo {
  final int? roleId;
  final String? roleName;

  UserRoleInfo({
    this.roleId,
    this.roleName,
  });

  factory UserRoleInfo.fromJson(Map<String, dynamic> json) {
    return UserRoleInfo(
      roleId: json['roleId'],
      roleName: json['roleName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roleId': roleId,
      'roleName': roleName,
    };
  }
}

