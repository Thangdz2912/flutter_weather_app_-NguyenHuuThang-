# 🌤️ Flutter Weather Application (Ứng Dụng Thời Tiết)

## 📋 Tổng Quan Dự Án

Đây là một ứng dụng thời tiết hiện đại được xây dựng bằng **Flutter**, cung cấp các thông tin chi tiết về thời tiết hiện tại và dự báo 5 ngày tới. Ứng dụng tích hợp **OpenWeatherMap API** để lấy dữ liệu thời tiết và sử dụng **GPS** để xác định vị trí người dùng.

### ✨ Đặc Điểm Chính:
- 📍 Lấy vị trí tự động bằng GPS
- 🔍 Tìm kiếm thời tiết theo tên thành phố
- 📊 Dự báo thời tiết 5 ngày
- 💾 Lưu cache dữ liệu (Chế độ Offline)
- 🎨 Giao diện đẹp mắt với Gradient động
- ⚙️ Cài đặt ứng dụng (Ngôn ngữ, Định dạng nhiệt độ...)

---

## 📁 Cấu Trúc Thư Mục Chi Tiết

```
lib/
├── main.dart                          # 🚀 Điểm khởi động ứng dụng
├── config/
│   └── api_config.dart               # ⚙️ Cấu hình API (URL, Endpoints)
├── models/                           # 📦 Các mô hình dữ liệu
│   ├── weather_model.dart            # 🌡️ Mô hình thời tiết hiện tại
│   ├── forecast_model.dart           # 📅 Mô hình dự báo thời tiết
│   └── location_model.dart           # 📍 Mô hình vị trí địa lý
├── services/                         # 🔧 Các dịch vụ xử lý business logic
│   ├── weather_service.dart          # 🌐 Gọi API thời tiết
│   ├── location_service.dart         # 📡 Xin quyền và lấy vị trí GPS
│   └── storage_service.dart          # 💾 Quản lý cache dữ liệu
├── providers/                        # 🎯 State management (Provider pattern)
│   └── weather_provider.dart         # 📊 Quản lý trạng thái thời tiết
├── screens/                          # 📱 Các màn hình của ứng dụng
│   ├── home_screen.dart              # 🏠 Màn hình chính
│   ├── search_screen.dart            # 🔍 Màn hình tìm kiếm
│   └── settings_screen.dart          # ⚙️ Màn hình cài đặt
└── widgets/                          # 🎨 Các thành phần giao diện
    ├── current_weather_card.dart     # 🃏 Card hiển thị thời tiết hiện tại
    ├── hourly_forecast_list.dart     # 📊 Danh sách dự báo giờ
    └── loading_shimmer.dart          # ⏳ Widget hiển thị trạng thái loading
```

---

## 🏗️ Kiến Trúc Ứng Dụng

### Kiến Trúc Tổng Quan:

```
┌─────────────────────────────────────────────────┐
│               UI LAYER (Screens & Widgets)      │
│  - HomeScreen / SearchScreen / SettingsScreen   │
│  - CurrentWeatherCard / ForecastList / Loading  │
└────────────────────┬────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │   STATE MANAGEMENT      │
        │  (WeatherProvider)      │
        │  - Manages Weather Data │
        │  - Manages App State    │
        └────────────┬────────────┘
                     │
    ┌────────────────┼────────────────┐
    │                │                │
┌───┴───────┐  ┌────┴────────┐  ┌───┴────────┐
│ Weather   │  │ Location    │  │ Storage    │
│ Service   │  │ Service     │  │ Service    │
└───┬───────┘  └────┬────────┘  └───┬────────┘
    │               │               │
    │  ┌────────────┴───────────┐   │
    │  │   API Layer / Device   │   │
    │  │                        │   │
    ├─→│ OpenWeatherMap API     │   │
    ├─→│ Geolocator (GPS)       │   │
    │  │ Geocoding (Địa danh)   │   │
    └─→│ SharedPreferences      │   │
       │ (Cache)                │   │
       └────────────────────────┘   │
```

**Nguyên Tắc:**
- **Separation of Concerns**: Mỗi tầng có trách nhiệm riêng
- **Provider Pattern**: Quản lý state toàn cầu
- **Service Layer**: Tách biệt logic xử lý từ UI

---

## 📄 Mô Tả Chi Tiết Các File

### 1️⃣ **main.dart** - Điểm Khởi Động
```dart
Vai trò:
  ✓ Khởi tạo ứng dụng Flutter
  ✓ Tải file .env (API Key)
  ✓ Thiết lập MultiProvider (Dependency Injection)
  ✓ Định nghĩa theme, navigation

Quản lý Dependencies:
  → LocationService: Xin quyền GPS
  → StorageService: Quản lý cache
  → WeatherService: Gọi API (Nhận API Key từ .env)
  → WeatherProvider: State management
```

**Điểm Quan Trọng:**
- `WidgetsFlutterBinding.ensureInitialized()`: Đảm bảo Flutter sẵn sàng trước khi tải .env
- `MultiProvider`: Tạo các service trước, rồi inject vào Provider
- Sử dụng `ProxyProvider0` và `ChangeNotifierProxyProvider3` để dependency injection

---

### 2️⃣ **config/api_config.dart** - Cấu Hình API
```dart
Vai trò:
  ✓ Định nghĩa Base URL: https://api.openweathermap.org/data/2.5
  ✓ Định nghĩa Endpoints:
    - /weather        : Thời tiết hiện tại
    - /forecast       : Dự báo 5 ngày
  ✓ Xây dựng URL hoàn chỉnh từ endpoint + parameters

Hàm buildUrl():
  Input: endpoint ("/weather"), params ({"q": "Hanoi", "appid": "xxx"...})
  Output: "https://api.openweathermap.org/data/2.5/weather?q=Hanoi&appid=xxx..."
```

---

### 3️⃣ **models/weather_model.dart** - Mô Hình Thời Tiết Hiện Tại
```dart
Thuộc tính:
  • cityName      : Tên thành phố (String)
  • country       : Quốc gia (String)
  • temperature   : Nhiệt độ hiện tại (°C) (double)
  • feelsLike     : Cảm giác như (double)
  • humidity      : Độ ẩm (%) (int)
  • windSpeed     : Tốc độ gió (m/s) (double)
  • pressure      : Áp suất (hPa) (int)
  • description   : Mô tả thời tiết (VD: "Mây rải rác") (String)
  • icon          : Mã icon từ OpenWeatherMap (String)
  • mainCondition : Điều kiện chính (Clear, Rain, Clouds...) (String)
  • dateTime      : Thời gian (DateTime)
  • tempMin       : Nhiệt độ thấp nhất (nullable double)
  • tempMax       : Nhiệt độ cao nhất (nullable double)
  • visibility    : Tầm nhìn (mét) (nullable int)
  • cloudiness    : Độ mây (%)(nullable int)

Phương Thức:
  ✓ fromJson(): Chuyển JSON từ API → WeatherModel
    - Xử lý lỗi: Ép kiểu an toàn (num).toDouble()
    - Xử lý giá trị null
  ✓ toJson(): Chuyển WeatherModel → JSON để lưu cache
```

---

### 4️⃣ **models/forecast_model.dart** - Mô Hình Dự Báo
```dart
Thuộc tính:
  • dateTime    : Thời gian dự báo (DateTime)
  • temperature : Nhiệt độ (°C) (double)
  • description : Mô tả (String)
  • icon        : Mã icon (String)
  • tempMin     : Nhiệt độ thấp nhất (double)
  • tempMax     : Nhiệt độ cao nhất (double)
  • humidity    : Độ ẩm (%) (int)
  • windSpeed   : Tốc độ gió (m/s) (double)

Cách Sử Dụng:
  API trả về mảng List<ForecastModel> (nhiều bản ghi, mỗi 3 giờ)
  Ví dụ: Cứ 3 giờ có 1 bản ghi dự báo trong 5 ngày
```

---

### 5️⃣ **models/location_model.dart** - Mô Hình Vị Trí
```dart
Thuộc tính:
  • latitude  : Vĩ độ (double)
  • longitude : Kinh độ (double)

Cách Sử Dụng:
  Lưu vào cache hoặc truyền cho WeatherService
  để lấy thời tiết dựa trên GPS
```

---

### 6️⃣ **services/weather_service.dart** - Dịch Vụ Thời Tiết
```dart
Vai Trò:
  ✓ Gọi OpenWeatherMap API
  ✓ Xử lý phản hồi HTTP
  ✓ Parse JSON và chuyển đổi sang Model

Các Phương Thức Chính:

1. _buildParams(extraParams)
   → Thêm API Key, units, language vào parameters
   Ví dụ: {"q": "Hanoi", "appid": "xxx", "units": "metric", "lang": "vi"}

2. _handleResponse(response)
   → Kiểm tra status code (200, 401, 404...)
   → Decode UTF-8 (hỗ trợ tiếng Việt)
   → Ném exception nếu có lỗi

3. getCurrentWeatherByCity(cityName)
   → Lấy thời tiết theo tên thành phố
   → URL Encoding để xử lý khoảng trắng/ký tự đặc biệt
   → Return: WeatherModel

4. getCurrentWeatherByCoordinates(lat, lon)
   → Lấy thời tiết theo GPS tọa độ
   → Return: WeatherModel

5. getForecast(cityName)
   → Lấy dự báo 5 ngày theo tên thành phố
   → Return: List<ForecastModel>

6. getForecastByCoordinates(lat, lon)
   → Lấy dự báo 5 ngày theo GPS
   → Return: List<ForecastModel>

Error Handling:
  ✓ SocketException: Không có Internet
  ✓ FormatException: JSON bị hỏng
  ✓ API Errors: 401 (Key sai), 404 (Thành phố không tồn tại)
```

---

### 7️⃣ **services/location_service.dart** - Dịch Vụ Vị Trí
```dart
Vai Trò:
  ✓ Xin quyền truy cập GPS từ người dùng
  ✓ Lấy tọa độ hiện tại
  ✓ Chuyển tọa độ thành tên thành phố (Reverse Geocoding)

Các Phương Thức:

1. checkPermission()
   → Kiểm tra xem dịch vụ GPS có bật không
   → Xin quyền từ người dùng (nếu chưa cấp)
   → Xử lý các trạng thái: denied, deniedForever
   → Return: bool (true = có quyền, false = không)

2. getCurrentLocation()
   → Lấy vị trí hiện tại với độ chính xác cao
   → Timeout 10 giây để tránh treo app
   → Fallback: Nếu chậm, lấy vị trí cuối cùng hoặc độ chính xác thấp
   → Return: Position (lat, lon)

3. getCityName(lat, lon)
   → Reverse Geocoding: Tọa độ → Tên thành phố
   → Ưu tiên: Locality > SubAdmin > Admin
   → Return: String (tên thành phố hoặc "Vị trí chưa xác định")

Quyền Cần Thiết:
  Android: location permission
  iOS: NSLocationWhenInUseUsageDescription
```

---

### 8️⃣ **services/storage_service.dart** - Dịch Vụ Lưu Trữ
```dart
Vai Trò:
  ✓ Lưu dữ liệu thời tiết vào SharedPreferences (local storage)
  ✓ Tải dữ liệu cũ (Cache)
  ✓ Kiểm tra tính hợp lệ của cache (TTL - Time To Live: 30 phút)

Các Phương Thức:

1. saveWeatherData(weather)
   → Chuyển WeatherModel thành JSON string
   → Lưu vào SharedPreferences với key "_cached_weather"
   → Cũng lưu thời gian cập nhật (_lastUpdateKey)

2. getCachedWeather()
   → Lấy JSON string từ SharedPreferences
   → Chuyển sang WeatherModel
   → Xử lý lỗi: Nếu JSON hỏng, xóa cache cũ
   → Return: WeatherModel? (null nếu không có cache)

3. isCacheValid()
   → Kiểm tra xem cache có còn hợp lệ không
   → TTL = 30 phút
   → Return: bool (true = còn hợp lệ, false = hết hạn)

4. clearCache()
   → Xóa tất cả cache (dùng khi Logout hoặc Clear Data)

Ưu Điểm:
  ✓ Offline Mode: Vẫn xem được dữ liệu cũ khi không có Internet
  ✓ Tệp nhẹ: Dữ liệu lưu trong bộ nhớ trong của điện thoại
```

---

### 9️⃣ **providers/weather_provider.dart** - Quản Lý Trạng Thái
```dart
Vai Trò:
  ✓ Quản lý trạng thái toàn cục của ứng dụng
  ✓ Coordinate giữa các Service
  ✓ Thông báo cho UI khi dữ liệu thay đổi

Enum WeatherState:
  • initial    : Lần đầu khởi động app
  • loading    : Đang tải dữ liệu từ API
  • loaded     : Đã tải thành công
  • error      : Có lỗi xảy ra

Thuộc Tính:
  • _currentWeather : WeatherModel? (thời tiết hiện tại)
  • _forecast       : List<ForecastModel> (dự báo)
  • _state          : WeatherState (trạng thái)
  • _errorMessage   : String (thông báo lỗi)

Các Phương Thức:

1. fetchWeatherByCity(cityName)
   Quy trình:
   a) Đặt _state = loading
   b) Gọi WeatherService.getCurrentWeatherByCity(cityName)
   c) Gọi WeatherService.getForecast(cityName)
   d) Lưu cache via StorageService
   e) Đặt _state = loaded
   f) notifyListeners() → Cập nhật UI

2. fetchWeatherByLocation()
   Quy trình:
   a) Đặt _state = loading
   b) Gọi LocationService.getCurrentLocation() (lấy GPS)
   c) Gọi WeatherService.getCurrentWeatherByCoordinates()
   d) Gọi WeatherService.getForecastByCoordinates()
   e) Lưu cache
   f) Đặt _state = loaded
   g) Nếu lỗi: loadCachedWeather() (Fallback to cache)

3. loadCachedWeather()
   → Tải dữ liệu từ cache (Offline Mode)
   → Dùng khi app khởi động hoặc mạng bị lỗi

4. refreshWeather()
   → Làm mới dữ liệu
   → Ưu tiên sử dụng thành phố hiện tại (nếu có)
   → Hoặc sử dụng GPS

Khi nào notifyListeners()?
  → Sau khi dữ liệu thay đổi
  → UI sẽ rebuild với dữ liệu mới
```

---

### 🔟 **screens/home_screen.dart** - Màn Hình Chính
```dart
Vai Trò:
  ✓ Hiển thị thế tiết hiện tại + dự báo
  ✓ Tự động lấy GPS khi mở app
  ✓ Hỗ trợ Pull-to-Refresh
  ✓ Xử lý trạng thái Loading/Error

Cấu Trúc UI:
  ├── AppBar (trong suốt)
  │   └── IconButton (My Location - Lấy GPS)
  ├── Background Gradient (Xanh dương)
  ├── Consumer<WeatherProvider>
  │   ├── State: Loading (chưa có dữ liệu)
  │   │   └── CircularProgressIndicator
  │   ├── State: Error (không có cache)
  │   │   └── Error Message + Retry Button
  │   └── State: Loaded (có dữ liệu)
  │       ├── RefreshIndicator (Pull to Refresh)
  │       ├── CurrentWeatherCard (Card thời tiết chính)
  │       ├── Text: "Dự báo tiếp theo"
  │       ├── ListView (Danh sách dự báo - forecast)
  │       │   └── ListTile (mỗi item dự báo)
  │       └── Loading Indicator (nếu đang refresh)

Tính Năng:
  ✓ Pull-to-Refresh: Kéo xuống để cập nhật
  ✓ Location Button: Nhấn để lấy GPS
  ✓ Error Handling: Hiển thị lỗi + nút Thử lại
  ✓ Offline Mode: Nếu lỗi, vẫn hiển thị cache cũ
```

---

### 1️⃣1️⃣ **screens/search_screen.dart** - Màn Hình Tìm Kiếm
```dart
Vai Trò:
  ✓ Cho phép người dùng tìm kiếm thành phố
  ✓ Gợi ý danh sách thành phố phổ biến
  ✓ Gọi API khi người dùng gửi tìm kiếm

Cấu Trúc UI:
  ├── AppBar (Back button)
  ├── Gradient Background
  ├── Title: "Tìm kiếm thành phố"
  ├── TextField (Nhập tên thành phố)
  │   ├── Placeholder: "Nhập tên thành phố (Vd: Hanoi, London...)"
  │   ├── Icon tìm kiếm trước
  │   └── Icon clear (xóa input)
  └── Section: "Gợi ý phổ biến"
      └── Grid/Row (Danh sách thành phố nhanh: Hanoi, HCMC...)

Quy Trình Tìm Kiếm:
  1. Người dùng gõ tên thành phố
  2. Nhấn Enter hoặc Search Button
  3. Gọi: context.read<WeatherProvider>().fetchWeatherByCity(cityName)
  4. Quay về HomeScreen (Navigator.pop)
  5. HomeScreen hiển thị dữ liệu mới
```

---

### 1️⃣2️⃣ **screens/settings_screen.dart** - Màn Hình Cài Đặt
```dart
Vai Trò:
  ✓ Cho phép người dùng cấu hình ứng dụng
  ✓ Quản lý cài đặt: Nhiệt độ, Giờ, Thông báo

Cấu Trúc UI:
  
Phần 1: HIỂN THỊ
├── SwitchListTile: "Sử dụng độ Celsius (°C)"
└── SwitchListTile: "Định dạng 24 giờ"

Phần 2: HỆ THỐNG
├── SwitchListTile: "Thông báo thời tiết"
├── ListTile: "Ngôn ngữ" → "Tiếng Việt"
└── (Có thể mở rộng)

Phần 3: THÔNG TIN
├── ListTile: "Phiên bản ứng dụng" → "1.0.0 (Build 2024)"
└── ListTile: "Chính sách bảo mật"

Lưu Ý:
  • Hiện tại chỉ là UI (State local)
  • Để lưu cài đặt vĩnh viễn, nên dùng Provider hoặc SharedPreferences
```

---

### 1️⃣3️⃣ **widgets/current_weather_card.dart** - Card Thời Tiết
```dart
Vai Trò:
  ✓ Hiển thị thời tiết hiện tại dưới dạng Card đẹp
  ✓ Gradient động dựa trên điều kiện thời tiết

Cấu Trúc:
  ├── Container (Card)
  │   ├── Gradient Background (Tuỳ điều kiện)
  │   └── Border Radius: 20
  │
  ├── Column (Nội dung)
  │   ├── Text: Tên thành phố (32px, Bold, Trắng)
  │   ├── Text: Ngày tháng (16px, Trắng70)
  │   ├── CachedNetworkImage: Icon thời tiết (120x120)
  │   │   ├── Loading: CircularProgressIndicator
  │   │   └── Error: Cloud icon
  │   ├── Text: Nhiệt độ (80px, Bold)
  │   ├── Text: Mô tả (20px, In hoa)
  │   └── Text: Cảm giác như (16px, Trắng70)

Gradient Animations:
  • Clear        → Blue gradient (☀️)
  • Rain/Drizzle → Dark gray (🌧️)
  • Clouds       → Cloudy blue (☁️)
  • Snow         → Light blue (❄️)

Công Nghệ:
  • CachedNetworkImage: Cache ảnh icon locally
  • Placeholder: Hiển thị loading trong khi tải ảnh
  • ErrorWidget: Hiển thị icon fallback nếu lỗi
```

---

### 1️⃣4️⃣ **widgets/hourly_forecast_list.dart** - Danh Sách Dự Báo
```dart
Vai Trò:
  ✓ Hiển thị dự báo thời tiết trong 24 giờ tới (horizontal scroll)
  ✓ Mỗi item hiển thị: Giờ, Icon, Nhiệt độ

Cấu Trúc:
  Column
  ├── Title: "Dự báo 24 giờ tới"
  └── ListView (Horizontal Scroll)
      └── Mỗi item (width: 85px):
          ├── Text: Giờ (HH:mm)
          ├── Image: Icon thời tiết
          └── Text: Nhiệt độ (°C)

Đặc Điểm:
  • Chiều cao: 130px
  • Cuộn ngang (Axis.horizontal)
  • Tối đa 8 items
  • Background: Trắng mờ (opacity: 0.15)
  • Border: Trắng10

Xử Lý Lỗi:
  ✓ Check danh sách rỗng
  ✓ Fallback icon nếu ảnh lỗi
```

---

### 1️⃣5️⃣ **widgets/loading_shimmer.dart** - Widget Loading
```dart
Vai Trò:
  ✓ Hiển thị trạng thái đang tải dữ liệu

Cấu Trúc:
  Column (Center)
  ├── CircularProgressIndicator (Trắng, 3px stroke)
  └── Text: "Đang cập nhật thời tiết..."

Sử Dụng:
  • Có thể dùng khi WeatherProvider đang loading
  • Hoặc khi lấy dữ liệu ban đầu
```

---

## 🔄 Luồng Dữ Liệu (Data Flow)

### Kịch Bản 1: Khởi Động App (Cold Start)
```
1. main.dart khởi tạo
   ↓
2. Tải file .env (API Key)
   ↓
3. MultiProvider khởi tạo các Service
   ↓
4. WeatherProvider.loadCachedWeather() (nếu có cache)
   ↓
5. HomeScreen mở
   ↓
6. initState() gọi fetchWeatherByLocation()
   ↓
7. LocationService.getCurrentLocation() (xin GPS)
   ↓
8. WeatherService.getCurrentWeatherByCoordinates()
   ↓
9. OpenWeatherMap API trả về JSON
   ↓
10. WeatherModel.fromJson() parse JSON
    ↓
11. StorageService.saveWeatherData() lưu cache
    ↓
12. WeatherProvider.notifyListeners()
    ↓
13. UI rebuild → Hiển thị thời tiết
```

### Kịch Bản 2: Người Dùng Tìm Kiếm Thành Phố
```
1. HomeScreen → SearchScreen
   ↓
2. Người dùng gõ tên thành phố + Enter
   ↓
3. fetchWeatherByCity(cityName)
   ↓
4. WeatherService.getCurrentWeatherByCity(cityName)
   ↓
5. OpenWeatherMap API (với param: q=cityName)
   ↓
6. Parse JSON → WeatherModel
   ↓
7. Save Cache
   ↓
8. notifyListeners()
   ↓
9. SearchScreen pop → Back to HomeScreen
   ↓
10. HomeScreen update UI
```

### Kịch Bản 3: Người Dùng Pull-to-Refresh
```
1. User kéo xuống
   ↓
2. RefreshIndicator.onRefresh()
   ↓
3. Provider.refreshWeather()
   ↓
4. Nếu có cityName → fetchWeatherByCity()
   Nếu không → fetchWeatherByLocation()
   ↓
5. Tải dữ liệu mới từ API
   ↓
6. Update cache
   ↓
7. UI update → Dữ liệu mới
```

### Kịch Bản 4: Mạng Bị Lỗi (Offline)
```
1. fetchWeatherByLocation()
   ↓
2. SocketException: "Không có kết nối Internet"
   ↓
3. Catch lỗi → _state = error
   ↓
4. loadCachedWeather() (Fallback)
   ↓
5. Nếu có cache → hiển thị dữ liệu cũ
   ↓
6. Nếu không → Hiển thị Error Message
```

---

## 🛠️ Công Nghệ & Dependencies

### Core Framework:
- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language

### State Management:
- **Provider**: Quản lý trạng thái ứng dụng

### API & Networking:
- **http**: HTTP client để gọi API
- **flutter_dotenv**: Tải biến môi trường từ .env

### Location & Maps:
- **geolocator**: Lấy vị trí GPS
- **geocoding**: Reverse geocoding (tọa độ → địa danh)

### Local Storage:
- **shared_preferences**: Lưu dữ liệu cơ bản (cache)

### UI & UX:
- **intl**: Format ngày tháng (DateFormat)
- **cached_network_image**: Cache ảnh từ mạng

### API sử dụng:
- **OpenWeatherMap API**: https://openweathermap.org
  - Free tier: 1000 calls/day
  - Hỗ trợ: Current weather, Forecast 5 days

---

## 📦 Cài Đặt & Chạy

### 1. Cài Đặt Flutter
```bash
# Tải Flutter SDK từ https://flutter.dev
# Thêm flutter vào PATH

flutter doctor  # Kiểm tra cài đặt
```

### 2. Clone/Setup Dự Án
```bash
# Clone repo (nếu có)
# Hoặc tạo project mới
flutter create weather_app
cd weather_app
```

### 3. Cài Đặt Dependencies
```bash
flutter pub get
```

### 4. Tạo File .env
```bash
# Tạo file .env ở thư mục gốc
echo OPENWEATHER_API_KEY=your_api_key_here > .env

# Hoặc chỉnh sửa file .env
OPENWEATHER_API_KEY=abc123xyz789...
```

**Lấy API Key:**
1. Vào https://openweathermap.org/api
2. Đăng ký tài khoản miễn phí
3. Tạo API Key
4. Copy vào file .env

### 5. Chạy Ứng Dụng
```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web (nếu có thiết lập)
flutter run -d chrome
```

---

## ⚙️ Cấu Hình Android/iOS

### Android (android/app/build.gradle):
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21  // Geolocator yêu cầu
        targetSdkVersion 34
    }
}
```

### Android (AndroidManifest.xml):
```xml
<!-- Permissions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS (ios/Runner/Info.plist):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Ứng dụng cần truy cập vị trí để hiển thị thời tiết</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Ứng dụng cần truy cập vị trí</string>
```

---

## 🐛 Xử Lý Lỗi Thường Gặp

### 1. "Lỗi: Không tìm thấy file .env"
**Nguyên Nhân:** Chưa tạo file .env  
**Giải Pháp:**
```bash
# Tạo file .env ở thư mục gốc
echo OPENWEATHER_API_KEY=your_key > .env
```

### 2. "API Key không hợp lệ (401)"
**Nguyên Nhân:** API Key sai hoặc hết hạn  
**Giải Pháp:**
- Kiểm tra lại API Key
- Regenerate key trên OpenWeatherMap
- Chắc chắn .env được tải đúng

### 3. "Không có kết nối Internet"
**Nguyên Nhân:** Điện thoại không có Internet  
**Giải Pháp:**
- Bật WiFi/4G
- App có chế độ Offline: Xem cache cũ (nếu có)

### 4. "Quyền GPS bị từ chối"
**Nguyên Nhân:** Người dùng từ chối quyền  
**Giải Pháp:**
- Mở Settings → App → Permissions → Location → Cho phép
- Hoặc dùng SearchScreen để tìm thành phố

### 5. "Không tìm thấy thông tin thời tiết"
**Nguyên Nhân:** Tên thành phố không đúng hoặc không tồn tại  
**Giải Pháp:**
- Kiểm tra lại tên thành phố (tiếng Anh)
- Thử "Hanoi" thay vì "Hà Nội"

---

## 📊 Model API Response

### Response: Current Weather
```json
{
  "name": "Hanoi",
  "sys": {
    "country": "VN"
  },
  "main": {
    "temp": 28.5,
    "feels_like": 30.2,
    "humidity": 75,
    "pressure": 1013,
    "temp_min": 26.0,
    "temp_max": 29.0
  },
  "wind": {
    "speed": 5.2
  },
  "weather": [
    {
      "main": "Clouds",
      "description": "mây rải rác",
      "icon": "02d"
    }
  ],
  "visibility": 10000,
  "clouds": {
    "all": 40
  },
  "dt": 1234567890
}
```

### Response: Forecast (5 days)
```json
{
  "list": [
    {
      "dt": 1234567890,
      "main": {
        "temp": 27.0,
        "temp_min": 25.0,
        "temp_max": 29.0,
        "humidity": 70
      },
      "weather": [
        {
          "main": "Clear",
          "description": "clear sky",
          "icon": "01d"
        }
      ],
      "wind": {
        "speed": 4.5
      }
    },
    ...
  ]
}
```

---

## 🎯 Các Tính Năng Nâng Cao (Có Thể Mở Rộng)

### 1. Multi-language Support
```dart
// Thêm i18n với package: intl hoặc flutter_localizations
// Hỗ trợ: Tiếng Việt, Tiếng Anh, ...
```

### 2. Dark Mode
```dart
// Thêm ThemeData.dark()
// Tùy chọn trong Settings Screen
```

### 3. Weather Alerts/Notifications
```dart
// Dùng firebase_messaging hoặc local_notifications
// Thông báo khi có cảnh báo thời tiết
```

### 4. Nhiều Thành Phố Yêu Thích
```dart
// Lưu danh sách thành phố yêu thích
// Swipe hoặc tab để chuyển giữa các thành phố
```

### 5. Air Quality Index (AQI)
```dart
// OpenWeatherMap cũng có API về chất lượng không khí
// Thêm thông tin AQI vào card hiển thị
```

### 6. Widget Lockscreen
```dart
// Cho phép xem thời tiết trực tiếp từ lockscreen
```

---

## 📚 Tài Liệu Tham Khảo

- **OpenWeatherMap API Docs**: https://openweathermap.org/api
- **Flutter Documentation**: https://flutter.dev/docs
- **Provider Package**: https://pub.dev/packages/provider
- **Geolocator Package**: https://pub.dev/packages/geolocator
- **Shared Preferences**: https://pub.dev/packages/shared_preferences

---

## 👨‍💻 Lưu Ý Phát Triển

### Best Practices Được Áp Dụng:
✅ **Clean Architecture**: Tách biệt UI, Logic, Data  
✅ **Provider Pattern**: State management centralized  
✅ **Error Handling**: Try-catch, Fallback mechanisms  
✅ **Type Safety**: Strong typing, null-safety  
✅ **Performance**: Image caching, Data validation  
✅ **User Experience**: Loading states, Error messages  

### Điểm Có Thể Cải Thiện:
- 📌 Lưu dữ liệu dự báo vào cache (hiện chỉ lưu thời tiết hiện tại)
- 📌 Thêm unit tests & widget tests
- 📌 Implement local notifications
- 📌 Thêm tính năng so sánh thời tiết nhiều thành phố
- 📌 Tối ưu hóa Firebase analytics

---

## 📝 Tóm Tắt Kiến Trúc

```
┌──────────────────────────────────────┐
│      PRESENTATION LAYER (UI)         │
│  Screens, Widgets, State Listeners   │
└──────────┬───────────────────────────┘
           │ notifyListeners()
           │ Consumer<WeatherProvider>
┌──────────┴───────────────────────────┐
│    STATE MANAGEMENT LAYER            │
│         WeatherProvider              │
│  • currentWeather                    │
│  • forecast                          │
│  • state & errorMessage              │
└──────────┬───────────────────────────┘
           │ Depends on
    ┌──────┼──────────────┐
    │      │              │
┌───┴──────┴────┐  ┌─────┴─────────┐  ┌────────────────┐
│ WeatherService│  │LocationService│  │StorageService  │
│  • API Calls  │  │ • GPS/Address │  │ • Cache Mgmt   │
└───┬───────────┘  └────┬──────────┘  └────┬───────────┘
    │                   │                   │
    │  HTTP Calls        │ GPS + Geocoding   │ SharedPrefs
    ↓                   ↓                   ↓
OpenWeatherMap       Device Sensors      Local Storage
```

---

## 🎉 Kết Luận

Ứng dụng thời tiết này là một ví dụ hoàn chỉnh về cách xây dựng một ứng dụng Flutter thực tế với:
- 🏗️ Kiến trúc sạch (Clean Architecture)
- 🎯 State management chuyên nghiệp (Provider)
- 🌐 Tích hợp API bên thứ ba (OpenWeatherMap)
- 📍 Sử dụng GPS & Geocoding
- 💾 Caching & Offline support
- 🎨 UI/UX đẹp mắt

Bạn có thể sử dụng project này làm nền tảng để mở rộng thêm các tính năng khác!

---

**Phiên Bản:** 1.0.0  
**Ngôn Ngữ:** Dart + Flutter  
**API:** OpenWeatherMap  
**Cập Nhật Cuối:** 2024
