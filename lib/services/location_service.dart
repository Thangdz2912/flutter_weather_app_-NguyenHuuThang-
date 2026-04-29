import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // 1. Kiểm tra và xin quyền truy cập vị trí một cách chuyên nghiệp
  Future<bool> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Kiểm tra xem dịch vụ định vị (GPS) trên máy đã bật chưa
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Có thể nhắc người dùng bật GPS tại đây
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Quyền bị từ chối lần 1
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Quyền bị từ chối vĩnh viễn (Người dùng đã chọn "Không bao giờ hỏi lại")
      return false;
    }

    return true;
  }

  // 2. Lấy tọa độ hiện tại với thời gian chờ (Timeout)
  Future<Position> getCurrentLocation() async {
    bool hasPermission = await checkPermission();

    if (!hasPermission) {
      throw 'Quyền truy cập vị trí bị từ chối hoặc GPS chưa bật';
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10), // Giới hạn 10 giây để tránh treo app
      );
    } catch (e) {
      // Nếu không lấy được vị trí chính xác cao, thử lấy vị trí có độ chính xác thấp hơn (nhanh hơn)
      return await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    }
  }

  // 3. Chuyển tọa độ thành tên thành phố (Tối ưu hóa lấy địa danh)
  Future<String> getCityName(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Ưu tiên lấy Locality (Thành phố), nếu null thì lấy Huyện hoặc Tỉnh
        return place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea ??
            'Vị trí chưa xác định';
      }
      return 'Không rõ vị trí';
    } catch (e) {
      return 'Không thể xác định tên thành phố';
    }
  }
}