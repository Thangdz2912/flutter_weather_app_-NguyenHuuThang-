import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/current_weather_card.dart';
// import '../widgets/forecast_section.dart'; // Giả sử bạn có widget này
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Tự động lấy thời tiết khi mở app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchWeatherByLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dùng ExtendBodyBehindAppBar để ảnh nền (nếu có) chui lên trên
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () => context.read<WeatherProvider>().fetchWeatherByLocation(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade300, Colors.blue.shade900],
          ),
        ),
        child: Consumer<WeatherProvider>(
          builder: (context, provider, child) {
            // 1. Nếu đang tải và chưa có dữ liệu gì trong tay
            if (provider.state == WeatherState.loading && provider.currentWeather == null) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            // 2. Nếu lỗi và cũng không có dữ liệu cũ (cache)
            if (provider.state == WeatherState.error && provider.currentWeather == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 80, color: Colors.white70),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi: ${provider.errorMessage}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    ElevatedButton(
                      onPressed: () => provider.fetchWeatherByLocation(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            // 3. Nếu không có dữ liệu (trường hợp hiếm)
            if (provider.currentWeather == null) {
              return const Center(child: Text('Không có dữ liệu', style: TextStyle(color: Colors.white)));
            }

            // 4. Giao diện chính khi đã có dữ liệu (hoặc đang loading nhưng vẫn giữ dữ liệu cũ)
            return RefreshIndicator(
              onRefresh: () => provider.refreshWeather(),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 100), // Khoảng trống cho AppBar

                          // Hiển thị Card thời tiết hiện tại
                          CurrentWeatherCard(weather: provider.currentWeather!),

                          const SizedBox(height: 20),

                          // Hiển thị tiêu đề dự báo
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Dự báo tiếp theo",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Hiển thị danh sách dự báo (Forecast)
                          ListView.builder(
                            shrinkWrap: true, // Quan trọng: Để lồng trong SingleChildScrollView
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: provider.forecast.length,
                            itemBuilder: (context, index) {
                              final day = provider.forecast[index];
                              return Card(
                                color: Colors.white.withOpacity(0.1),
                                child: ListTile(
                                  leading: Image.network(
                                    "https://openweathermap.org/img/wn/${day.icon}@2x.png",
                                    width: 50,
                                  ),
                                  title: Text(
                                    "${day.temperature.round()}°C - ${day.description}",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    day.dateTime.toString().substring(0, 16),
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Hiển thị một thanh loading nhỏ trên cùng nếu đang refresh ngầm
                  if (provider.state == WeatherState.loading)
                    const Positioned(
                      top: 100,
                      left: 0,
                      right: 0,
                      child: Center(child: LinearProgressIndicator()),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orangeAccent,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        ),
        child: const Icon(Icons.search, color: Colors.white),
      ),
    );
  }
}