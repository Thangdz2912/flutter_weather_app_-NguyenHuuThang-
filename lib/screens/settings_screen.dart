import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Các biến trạng thái giả lập (Sau này bạn có thể dùng Provider để lưu lâu dài)
  bool _isCelsius = true;
  bool _is24hFormat = true;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Phần 1: Tùy chỉnh hiển thị
          _buildSectionHeader('Hiển thị'),

          SwitchListTile(
            title: const Text('Sử dụng độ Celsius (°C)'),
            subtitle: Text(_isCelsius ? 'Đang dùng độ C' : 'Đang dùng độ F'),
            secondary: const Icon(Icons.thermostat, color: Colors.orange),
            value: _isCelsius,
            onChanged: (bool value) {
              setState(() {
                _isCelsius = value;
              });
            },
          ),

          SwitchListTile(
            title: const Text('Định dạng 24 giờ'),
            subtitle: Text(_is24hFormat ? 'Định dạng 24h' : 'Định dạng 12h (AM/PM)'),
            secondary: const Icon(Icons.access_time, color: Colors.blue),
            value: _is24hFormat,
            onChanged: (bool value) {
              setState(() {
                _is24hFormat = value;
              });
            },
          ),

          const Divider(),

          // Phần 2: Thông báo & Hệ thống
          _buildSectionHeader('Hệ thống'),

          SwitchListTile(
            title: const Text('Thông báo thời tiết'),
            subtitle: const Text('Cập nhật cảnh báo hàng ngày'),
            secondary: const Icon(Icons.notifications_active, color: Colors.teal),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),

          ListTile(
            leading: const Icon(Icons.language, color: Colors.purple),
            title: const Text('Ngôn ngữ'),
            subtitle: const Text('Tiếng Việt'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Logic chọn ngôn ngữ
            },
          ),

          const Divider(),

          // Phần 3: Thông tin ứng dụng
          _buildSectionHeader('Thông tin'),

          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.grey),
            title: const Text('Phiên bản ứng dụng'),
            subtitle: const Text('1.0.0 (Build 2024)'),
          ),

          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: Colors.grey),
            title: const Text('Chính sách bảo mật'),
            onTap: () {
              // Mở trang web hoặc file PDF
            },
          ),
        ],
      ),
    );
  }

  // Widget phụ để tạo tiêu đề nhóm cài đặt
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}