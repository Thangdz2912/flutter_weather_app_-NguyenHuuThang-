import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/forecast_model.dart';

class HourlyForecastList extends StatelessWidget {
  final List<ForecastModel> forecasts;

  const HourlyForecastList({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    // Kiểm tra nếu danh sách rỗng để tránh lỗi
    if (forecasts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            "Dự báo 24 giờ tới",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Chỉnh sang màu trắng cho đồng bộ nền xanh
            ),
          ),
        ),
        SizedBox(
          height: 130, // Tăng nhẹ chiều cao để thoải mái hơn
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            // SỬA LỖI: Lấy tối đa 8 mục, hoặc ít hơn nếu danh sách không đủ 8
            itemCount: forecasts.length > 8 ? 8 : forecasts.length,
            itemBuilder: (context, index) {
              final forecast = forecasts[index];
              return Container(
                width: 85,
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                decoration: BoxDecoration(
                  // Dùng màu trắng mờ để nổi bật trên nền Gradient xanh
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Giờ
                    Text(
                      DateFormat('HH:mm').format(forecast.dateTime),
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),

                    // Icon thời tiết (Dùng @2x để ảnh nét hơn)
                    Image.network(
                      'https://openweathermap.org/img/wn/${forecast.icon}@2x.png',
                      height: 50,
                      width: 50,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.wb_cloudy, color: Colors.white),
                    ),

                    // Nhiệt độ
                    Text(
                      '${forecast.temperature.round()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
