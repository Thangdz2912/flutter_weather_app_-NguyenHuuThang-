import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/weather_model.dart';

class CurrentWeatherCard extends StatelessWidget {
  final WeatherModel weather;

  const CurrentWeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        // Thay đổi Gradient dựa trên điều kiện thời tiết
        gradient: _getWeatherGradient(weather.mainCondition),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tên thành phố
          Text(
            weather.cityName,
            style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
          ),

          // LỖI ĐÃ SỬA: Đưa style vào đúng trong hàm Text
          Text(
            DateFormat('EEEE, MMM d').format(weather.dateTime),
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),

          const SizedBox(height: 20),

          // Icon thời tiết từ OpenWeatherMap
          CachedNetworkImage(
            imageUrl: 'https://openweathermap.org/img/wn/${weather.icon}@4x.png',
            height: 120,
            // Hiệu ứng loading khi chờ ảnh
            placeholder: (context, url) => const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
            // Ảnh lỗi nếu không tải được icon
            errorWidget: (context, url, error) => const Icon(Icons.wb_cloudy, size: 80, color: Colors.white),
          ),

          // Nhiệt độ chính
          Text(
            '${weather.temperature.round()}°',
            style: const TextStyle(fontSize: 80, color: Colors.white, fontWeight: FontWeight.w300),
          ),

          // Mô tả (VD: Mây rải rác)
          Text(
            weather.description.toUpperCase(),
            style: const TextStyle(fontSize: 20, color: Colors.white, letterSpacing: 1.2),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          // Cảm giác như...
          Text(
            'Cảm giác như ${weather.feelsLike.round()}°',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // Hàm chọn màu sắc Gradient chuyên nghiệp hơn
  LinearGradient _getWeatherGradient(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF87CEEB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        return const LinearGradient(
          colors: [Color(0xFF4A5568), Color(0xFF2D3748)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'clouds':
        return const LinearGradient(
          colors: [Color(0xFF718096), Color(0xFF4A5568)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
    }
  }
}