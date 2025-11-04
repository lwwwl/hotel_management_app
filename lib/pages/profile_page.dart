import 'package:flutter/material.dart';
import '../models/user_detail.dart';
import '../services/user_api_service.dart';

/// 个人资料页面
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserDetail? _userDetail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserDetail();
  }

  /// 加载用户详情
  Future<void> _loadUserDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await UserApiService.getUserDetail();
      
      if (mounted) {
        if (response.isSuccess && response.data != null) {
          setState(() {
            _userDetail = response.data;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = response.message;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '加载失败: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('个人资料'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserDetail,
            tooltip: '刷新',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildProfileContent(),
    );
  }

  /// 错误视图
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadUserDetail,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 个人资料内容
  Widget _buildProfileContent() {
    if (_userDetail == null) {
      return const Center(child: Text('暂无数据'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // 头像和基本信息
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade600,
                  Colors.blue.shade400,
                ],
              ),
            ),
            child: Column(
              children: [
                // 头像
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                // 显示名称
                Text(
                  _userDetail!.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // 用户名
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '@${_userDetail!.username}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 状态标签
                if (_userDetail!.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          '已激活',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // 详细信息卡片
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 基本信息
                _buildInfoCard(
                  title: '基本信息',
                  icon: Icons.person_outline,
                  children: [
                    if (_userDetail!.employeeNumber != null)
                      _buildInfoRow(
                        icon: Icons.badge_outlined,
                        label: '工号',
                        value: _userDetail!.employeeNumber!,
                        iconColor: Colors.orange,
                      ),
                    if (_userDetail!.phone != null)
                      _buildInfoRow(
                        icon: Icons.phone_outlined,
                        label: '手机号',
                        value: _userDetail!.phone!,
                        iconColor: Colors.green,
                      ),
                    if (_userDetail!.email != null)
                      _buildInfoRow(
                        icon: Icons.email_outlined,
                        label: '邮箱',
                        value: _userDetail!.email!,
                        iconColor: Colors.blue,
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // 组织信息
                _buildInfoCard(
                  title: '组织信息',
                  icon: Icons.business_outlined,
                  children: [
                    if (_userDetail!.department != null)
                      _buildInfoRow(
                        icon: Icons.corporate_fare,
                        label: '部门',
                        value: _userDetail!.department!.departmentName ?? '未知部门',
                        iconColor: Colors.purple,
                      ),
                    if (_userDetail!.roles != null && _userDetail!.roles!.isNotEmpty)
                      ..._userDetail!.roles!.asMap().entries.map((entry) {
                        return _buildInfoRow(
                          icon: Icons.shield_outlined,
                          label: entry.key == 0 ? '角色' : '',
                          value: entry.value.roleName ?? '未知角色',
                          iconColor: Colors.indigo,
                        );
                      }).toList(),
                  ],
                ),

                const SizedBox(height: 16),

                // 账号信息
                _buildInfoCard(
                  title: '账号信息',
                  icon: Icons.security_outlined,
                  children: [
                    _buildInfoRow(
                      icon: Icons.fingerprint,
                      label: '用户ID',
                      value: _userDetail!.userId.toString(),
                      iconColor: Colors.teal,
                    ),
                    _buildInfoRow(
                      icon: Icons.admin_panel_settings_outlined,
                      label: '管理员权限',
                      value: _userDetail!.superAdmin == true ? '是' : '否',
                      iconColor: _userDetail!.superAdmin == true 
                          ? Colors.red 
                          : Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 信息卡片
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片标题
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          // 卡片内容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  /// 信息行
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label.isNotEmpty) ...[
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

