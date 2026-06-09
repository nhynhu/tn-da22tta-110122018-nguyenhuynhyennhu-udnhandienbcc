# 🐞 Beetle ID - Nhận Diện Bọ Cánh Cứng

Ứng dụng mobile Flutter dùng AI/ML để nhận diện và cung cấp thông tin chi tiết về các loài bọ cánh cứng (Coleoptera).

## 📋 Thông Tin Dự Án

| Thông số | Chi tiết |
|---------|---------|
| **Tên** | Beetle ID (Nhận diện bọ cánh cứng) |
| **Framework** | Flutter 3.12+ |
| **Ngôn ngữ** | Dart |
| **Platform** | Android, iOS |
| **Backend** | Flask Python (REST API) |
| **Ghi chú** | Ứng dụng hiện tại chạy thành công với backend tại `http://192.168.1.38:5000` |

---

## 🎯 Tính Năng Chính

### 1. **Nhận Diện Bọ (Predict)**
- Chụp ảnh từ camera hoặc chọn từ thư viện
- Gửi ảnh lên server AI/ML để phân tích
- Nhận kết quả:
  - Tên tiếng Việt của loài
  - Tên khoa học
  - Độ tin cậy (confidence) %
  - Bounding box (vị trí bọ trong ảnh)
  - Tính nguy hiểm (mức độ & mô tả)
  - Cách phòng chống
  - Hình ảnh minh họa

### 2. **Danh Sách Loài Bọ**
- Xem toàn bộ danh sách các loài bọ trong database
- Tìm kiếm và lọc theo tên
- Xem thông tin cơ bản của mỗi loài

### 3. **Chi Tiết Loài**
- Mô tả chi tiết mỗi loài:
  - Tên tiếng Việt & khoa học
  - Họ (Family)
  - Kích thước
  - Màu sắc
  - Môi trường sống
  - Tính chất gây hại
  - Cách phòng chống
  - Mức độ nguy hiểm
  - Hình ảnh đại diện

### 4. **Lịch Sử Nhận Diện**
- Lưu trữ lịch sử các lần nhận diện
- Hiển thị theo thiết bị (device_id)
- Xem lại kết quả cũ
- Giới hạn tối đa 20 mục gần nhất

### 5. **Phản Hồi (Feedback)**
- Gửi phản hồi khi nhận diện sai
- Báo cáo loài chính xác
- Thêm ghi chú chi tiết
- Giúp cải thiện mô hình AI

---

## 📁 Cấu Trúc Thư Mục

```
lib/
├── main.dart                 # Entry point, thiết lập theme & routing
├── config/
│   └── api_config.dart      # Cấu hình URL backend & endpoints
├── models/
│   ├── prediction.dart      # Model kết quả nhận diện
│   ├── species.dart         # Model thông tin loài
│   └── history.dart         # Model lịch sử nhận diện
├── services/
│   └── api_service.dart     # Xử lý tất cả API calls
├── screens/
│   ├── home_screen.dart     # Màn hình chính (3 tabs)
│   ├── result_screen.dart   # Hiển thị kết quả nhận diện
│   ├── species_list_screen.dart      # Danh sách loài
│   ├── species_detail_screen.dart    # Chi tiết loài
│   └── history_screen.dart  # Lịch sử nhận diện
└── widgets/
    ├── danger_badge.dart    # Widget hiển thị mức độ nguy hiểm
    ├── prediction_card.dart # Card hiển thị kết quả
    └── [Các widget khác]
```

---

## 🔌 API Endpoints

| Endpoint | Method | Mục đích | Timeout |
|----------|--------|---------|---------|
| `/api/predict` | POST | Nhận diện ảnh | 30s |
| `/api/species` | GET | Lấy danh sách loài | 15s |
| `/api/species/{className}` | GET | Lấy chi tiết loài | 15s |
| `/api/history` | GET | Lấy lịch sử | 15s |
| `/api/feedback` | POST | Gửi phản hồi | 15s |

### Backend Configuration

**File:** `lib/config/api_config.dart`

```dart
static const String baseUrl = 'http://192.168.1.38:5000';
```

**Chú ý:**
- Emulator Android: `10.0.2.2:5000`
- Thiết bị thực/Tablet: IP LAN của máy backend (vd: `192.168.1.38:5000`)
- iOS Simulator: `localhost:5000` (hoặc IP LAN)

---

## 📦 Dependencies Chính

| Package | Phiên bản | Mục đích |
|---------|----------|---------|
| `http` | ^1.2.0 | HTTP requests đến backend |
| `http_parser` | ^4.1.0 | Parse MIME types |
| `image_picker` | ^1.1.2 | Chọn ảnh từ camera/thư viện |
| `device_info_plus` | ^11.0.0 | Lấy device ID |
| `google_fonts` | ^6.2.1 | Font chữ (Material Design) |
| `shimmer` | ^3.0.0 | Loading animation |
| `cached_network_image` | ^3.4.1 | Cache ảnh từ network |
| `mime` | ^2.0.0 | Detect MIME type |

---

## 🎨 Thiết Kế UI/UX

### Theme
- **Giao diện:** Dark mode
- **Màu chính:** Xanh lá (`#4CAF50`)
- **Nền:** Xanh đậm (`#0A1A0F`)
- **Font:** Google Fonts (Inter)

### Navigation
- **Bottom Tab Navigation** với 3 tab:
  1. 🏠 Home - Chụp/chọn ảnh nhận diện
  2. 📚 Danh sách loài
  3. 📋 Lịch sử nhận diện

### Các Màn Hình Chính

1. **Home Screen**
   - Nút chụp camera & chọn ảnh từ thư viện
   - Animation pulse effect
   - Bottom navigation

2. **Result Screen**
   - Hiển thị ảnh đã chọn
   - Kết quả nhận diện (tên, độ tin cậy, bounding box)
   - Thông tin chi tiết (nguy hiểm, phòng chống)
   - Nút Feedback

3. **Species List Screen**
   - Danh sách tất cả loài
   - Scroll & tải dữ liệu
   - Nhấn vào xem chi tiết

4. **Species Detail Screen**
   - Thông tin chi tiết loài
   - Hình ảnh, mô tả chi tiết
   - Có/không hoàn toàn dữ liệu từ API

5. **History Screen**
   - Danh sách lịch sử nhận diện
   - Lọc theo device
   - Tối đa 20 mục

---

## 🔄 Quy Trình Hoạt Động

### 1. Nhận Diện Ảnh
```
User chọn ảnh → Gửi tới /api/predict → Backend xử lý → Trả kết quả
                                        (AI Model)
        ↓
Hiển thị kết quả trên Result Screen
        ↓
User có thể gửi Feedback nếu sai
```

### 2. Xem Danh Sách Loài
```
Load Species List Screen → Gọi /api/species → Lấy danh sách
                                  ↓
                         Hiển thị dưới dạng list
                                  ↓
                    User nhấn → /api/species/{className}
```

### 3. Lịch Sử
```
Load History Screen → Gọi /api/history?device_id={id} → Hiển thị list
```

---

## 🐛 Xử Lý Lỗi

### SocketException (Kết nối mạng)
```dart
on SocketException {
  // "Không thể kết nối đến server"
  // Kiểm tra: Backend chạy? IP đúng? WiFi kết nối?
}
```

### Timeout Errors
- Predict: 30 giây
- Các API khác: 15 giây
- → Hiển thị thông báo lỗi cho user

### Server Errors (4xx, 5xx)
- Kiểm tra status code
- Hiển thị error message từ response hoặc generic message

---

## 🚀 Cách Chạy

### Requirements
- Flutter 3.12+
- Dart 3.1+
- Android 21+ hoặc iOS 12+
- Backend Flask chạy tại `http://192.168.1.38:5000`

### Steps
```bash
# 1. Clone hoặc mở project
cd d:/UDNhanDien/beetle_app

# 2. Cài dependencies
flutter pub get

# 3. Chạy app
flutter run

# 4. Thay URL backend nếu khác
# Edit: lib/config/api_config.dart -> baseUrl
```

---

## 📝 Chi Tiết Models

### Prediction (Kết quả nhận diện)
```dart
- className: string (class_name từ model)
- confidence: double (0.0 - 1.0)
- bbox: List<double> ([x, y, width, height])
- tenViet: string (tên tiếng Việt)
- tenKhoaHoc: string (tên khoa học)
- gayHai: string (mô tả tính gây hại)
- phongChong: string (cách phòng chống)
- mucDoNguyHiem: string (mức độ nguy hiểm)
- hinhAnhUrl: string (URL hình ảnh)
```

### Species (Thông tin loài)
```dart
- id: int
- className: string
- tenViet: string
- tenKhoaHoc: string
- ho: string (Family)
- kichThuoc: string
- mauSac: string
- moiTruong: string (habitat)
- gayHai: string
- phongChong: string
- mucDoNguyHiem: string
- hinhAnhUrl: string
```

### DetectionHistoryItem (Lịch sử)
```dart
- id: int
- deviceId: string
- className: string
- confidence: double
- timestamp: string
- imageUrl: string (optional)
```

---

## 🔐 Bảo Mật

- ✅ HTTPS có thể được bật trên production
- ✅ Device ID được gửi kèm mỗi request (tracking)
- ✅ Image size bị giới hạn (1280x1280, quality 85%)
- ✅ Timeout bảo vệ chống resource exhaustion

---

## 📊 Backend Requirements

Backend Flask cần cung cấp:
1. **ML Model** cho phân loại bọ (trained model)
2. **Database** lưu danh sách loài & metadata
3. **Image Processing** API cho prediction
4. **Feedback Storage** để cải thiện model

---

## 📝 Lưu Ý

- Ứng dụng hiện tại **chưa có offline mode** - cần kết nối internet
- **Không có authentication** - cho phép anonymous access
- **Device tracking** thông qua device_id để lịch sử
- **Image caching** được bật - tải nhanh hơn lần 2

---

## 🎯 Trạng Thái Hiện Tại

✅ **Đã hoạt động:** Kết nối backend thành công tại `192.168.1.38:5000`

⚠️ **Cần kiểm tra:**
- [ ] Tất cả endpoints API hoạt động?
- [ ] Kết quả nhận diện chính xác?
- [ ] Lịch sử lưu đúng?
- [ ] Performance ổn định?

---

*Cập nhật lần cuối: 03/06/2026*
