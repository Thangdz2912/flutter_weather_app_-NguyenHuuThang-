import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key}); // Thêm const và key [cite: 5]

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  // Giải phóng bộ nhớ khi đóng màn hình
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(String cityName) {
    final name = cityName.trim();
    if (name.isNotEmpty) {
      // Gọi hàm tìm kiếm từ Provider
      context.read<WeatherProvider>().fetchWeatherByCity(name);
      // Quay lại màn hình chính
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Màu nền đồng bộ với HomeScreen
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade400, Colors.blue.shade800],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nút quay lại
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Tìm kiếm thành phố",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // Ô nhập liệu tìm kiếm
                TextField(
                  controller: _controller,
                  autofocus: true, // Tự động hiện bàn phím khi mở màn hình
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Nhập tên thành phố (Vd: Hanoi, London...)',
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white70),
                      onPressed: () => _controller.clear(),
                    ),
                  ),
                  onSubmitted: (value) => _onSearch(value),
                ),

                const SizedBox(height: 30),

                // Phần gợi ý thành phố nhanh
                const Text(
                  "Gợi ý phổ biến",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),

                const SizedBox(height: 15),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildQuickSearchChip("Hanoi"),
                    _buildQuickSearchChip("Ho Chi Minh"),
                    _buildQuickSearchChip("Da Nang"),
                    _buildQuickSearchChip("London"),
                    _buildQuickSearchChip("Tokyo"),
                    _buildQuickSearchChip("New York"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget tạo các nút bấm nhanh
  Widget _buildQuickSearchChip(String city) {
    return GestureDetector(
      onTap: () => _onSearch(city),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          city,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}