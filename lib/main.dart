import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import các file bạn đã tạo
import 'providers/weather_provider.dart';
import 'services/weather_service.dart';
import 'services/location_service.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';

void main() async {
  // Đảm bảo các ràng buộc của Flutter được khởi tạo trước khi nạp .env
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Tải file cấu hình môi trường (.env)
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Lỗi: Không tìm thấy file .env. Hãy tạo file .env ở thư mục gốc.");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Khởi tạo các Service độc lập
        Provider(create: (_) => LocationService()),
        Provider(create: (_) => StorageService()),

        // Khởi tạo WeatherService với API Key từ file .env
        ProxyProvider0<WeatherService>(
          update: (_, __) => WeatherService(
            apiKey: dotenv.env['OPENWEATHER_API_KEY'] ?? '',
          ),
        ),

        // Khởi tạo WeatherProvider và tiêm (inject) các Service vào
        ChangeNotifierProxyProvider3<WeatherService, LocationService, StorageService, WeatherProvider>(
          create: (context) => WeatherProvider(
            context.read<WeatherService>(),
            context.read<LocationService>(),
            context.read<StorageService>(),
          ),
          update: (context, weatherSvc, locationSvc, storageSvc, previousProvider) =>
          previousProvider ?? WeatherProvider(weatherSvc, locationSvc, storageSvc),
        ),
      ],
      child: MaterialApp(
        title: 'Weather App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'Roboto', // Nếu bạn có font tùy chỉnh
        ),
        home: HomeScreen(), // Màn hình đầu tiên khi mở app
      ),
    );
  }
}