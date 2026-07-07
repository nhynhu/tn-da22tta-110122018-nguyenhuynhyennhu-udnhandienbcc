# UD NHAN DIEN - He thong nhan dien bo canh cung

## Gioi thieu

Du an xay dung ung dung di dong nhan dien cac loai bo canh cung (Coleoptera) gay hai cay trong tai Viet Nam. He thong su dung mo hinh YOLOv11 (dinh dang ONNX) de phat hien va phan loai bo canh cung tu hinh anh hoac video do nguoi dung chup/quay, ket hop voi co so du lieu MySQL luu tru thong tin chi tiet ve tung loai.

Ung dung ho tro nhan dien 9 loai bo canh cung:

| STT | Class Name  | Ten Viet                |
|-----|-------------|-------------------------|
| 1   | BoDua       | Bo Dua                  |
| 2   | BoHa        | Bo Ha Khoai Lang        |
| 3   | BoNgau      | Bo Ngau                 |
| 4   | BoNhay      | Bo Nhay Soc Cong        |
| 5   | BoRay       | Bo Ray (Bu Ray)         |
| 6   | BoVoiVoi    | Bo Voi Voi Hai Dua      |
| 7   | CauCau      | Cau Cau Xanh            |
| 8   | DuongDua    | Duong Dua               |
| 9   | KienDuong   | Kien Vuong              |


## Kien truc he thong

```
src/
|-- BoCanhCung.sql          # Script khoi tao database MySQL
|-- backend/                # Flask API server (Python)
|   |-- app.py              # Diem khoi dong Flask, dang ky route
|   |-- config.py           # Cau hinh ket noi MySQL, duong dan model
|   |-- models.py           # ORM model (SQLAlchemy) - bang species
|   |-- extensions.py       # Khoi tao doi tuong SQLAlchemy
|   |-- discovery.py        # UDP Discovery server cho mang LAN
|   |-- best.onnx           # Mo hinh YOLOv11 da huan luyen (ONNX)
|   |-- requirements.txt    # Cac thu vien Python can thiet
|   |-- routes/
|   |   |-- predict.py      # API nhan dien anh va video
|   |   |-- species.py      # API CRUD thong tin loai
|   |-- images/             # Hinh anh cac loai bo canh cung
|   |-- processed_videos/   # Video ket qua sau xu ly
|   |-- .env                # Bien moi truong (MySQL, model path)
|
|-- beetle_app/             # Ung dung Flutter (Dart)
    |-- lib/
    |   |-- main.dart            # Diem khoi dong ung dung
    |   |-- config/              # Cau hinh ung dung
    |   |-- models/
    |   |   |-- prediction.dart  # Model ket qua nhan dien
    |   |   |-- species.dart     # Model thong tin loai
    |   |   |-- video_result.dart# Model ket qua video
    |   |-- screens/
    |   |   |-- home_screen.dart           # Man hinh chinh
    |   |   |-- camera_screen.dart         # Man hinh chup anh/quay video
    |   |   |-- result_screen.dart         # Man hinh ket qua nhan dien
    |   |   |-- species_list_screen.dart   # Danh sach cac loai
    |   |   |-- species_detail_screen.dart # Chi tiet 1 loai
    |   |   |-- video_playback_screen.dart # Phat video ket qua
    |   |-- services/
    |   |   |-- api_service.dart       # Goi API backend
    |   |   |-- discovery_service.dart  # Tu dong tim server qua UDP
    |   |-- widgets/
    |       |-- prediction_card.dart   # Widget hien thi ket qua
    |-- pubspec.yaml         # Cau hinh dependencies Flutter
    |-- android/             # Cau hinh Android native
    |-- ios/                 # Cau hinh iOS native
    |-- assets/              # Tai nguyen tinh (hinh anh)
```


## Cong nghe su dung

### Backend

- Ngon ngu: Python
- Framework: Flask
- Co so du lieu: MySQL (ket noi qua SQLAlchemy + PyMySQL)
- Mo hinh AI: YOLOv11 (Ultralytics), dinh dang ONNX
- Xu ly anh/video: OpenCV, Pillow
- Encode video: FFmpeg (H.264)
- Ket noi mang LAN: UDP Discovery (socket)

### Frontend (Mobile App)

- Framework: Flutter (Dart)
- SDK: >=3.12.0
- Cac thu vien chinh:
  - http - Goi API
  - image_picker - Chon anh tu thu vien
  - camera - Chup anh va quay video truc tiep
  - video_player - Phat video ket qua
  - cached_network_image - Cache hinh anh
  - google_fonts - Font chu
  - shimmer - Hieu ung loading
  - device_info_plus - Thong tin thiet bi


## Cai dat va chay

### Yeu cau he thong

- Python >= 3.9
- MySQL >= 8.0
- Flutter SDK >= 3.12.0
- FFmpeg (khong bat buoc, dung de encode video H.264)

### 1. Khoi tao co so du lieu

Mo MySQL va chay file SQL de tao database va nhap du lieu mau:

```sql
source BoCanhCung.sql
```

Hoac dung cong cu quan ly MySQL (MySQL Workbench, phpMyAdmin, ...) de import file `BoCanhCung.sql`.

### 2. Cai dat va chay Backend

```bash
cd src/backend

# Tao moi truong ao
python -m venv venv

# Kich hoat moi truong ao
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Cai dat cac thu vien
pip install -r requirements.txt

# Cau hinh file .env (chinh sua neu can)
# MYSQL_USER=root
# MYSQL_PASSWORD=
# MYSQL_HOST=localhost
# MYSQL_PORT=3306
# MYSQL_DB=beetle_db
# MODEL_PATH=best.onnx
# CONF_THRESHOLD=0.25

# Chay server
python app.py
```

Server se khoi dong tai `http://<LAN_IP>:5000` va UDP Discovery tai port `5001`.

### 3. Cai dat va chay Flutter App

```bash
cd src/beetle_app

# Lay cac package
flutter pub get

# Chay ung dung (ket noi thiet bi hoac emulator)
flutter run
```

Ung dung Flutter se tu dong tim server backend thong qua UDP Discovery tren mang LAN.


## API Endpoints

### Nhan dien anh

```
POST /api/predict
Content-Type: multipart/form-data

Tham so:
  - image: file anh (bat buoc)
  - device_id: ma thiet bi (tuy chon)

Tra ve:
  - status: "success" hoac "error"
  - count: so luong doi tuong phat hien
  - predictions: danh sach ket qua (class_name, confidence, bbox, thong tin loai)
```

### Nhan dien video

```
POST /api/predict_video
Content-Type: multipart/form-data

Tham so:
  - video: file video (bat buoc)
  - device_id: ma thiet bi (tuy chon)

Tra ve:
  - status: "success" hoac "error"
  - video_url: duong dan video ket qua (da ve khung nhan dien)
  - fps, frames: thong tin video
  - detections: danh sach loai phat hien (class_name, ten_viet, count, confidence)
```

### Danh sach loai

```
GET /api/species
Tra ve: danh sach tat ca cac loai bo canh cung trong database

GET /api/species/<class_name>
Tra ve: thong tin chi tiet 1 loai

PUT /api/species/<class_name>
Body: JSON chua cac truong can cap nhat
Tra ve: thong tin loai sau khi cap nhat
```

### Phat video ket qua

```
GET /api/processed_videos/<filename>
Tra ve: file video da xu ly
```


## Co che UDP Discovery

He thong su dung giao thuc UDP de ung dung Flutter tu dong tim thay server backend tren cung mang LAN ma khong can nhap IP thu cong.

Quy trinh:

1. Backend khoi dong UDP server lang nghe tren port 5001
2. Flutter app gui broadcast message "BEETLE_DISCOVER" tren mang LAN
3. Backend nhan message va tra ve dia chi IP + port cua Flask server
4. Flutter tu dong cap nhat baseUrl de goi API


## Co so du lieu

Database `beetle_db` gom 1 bang chinh:

### Bang `species`

| Cot               | Kieu du lieu  | Mo ta                         |
|--------------------|---------------|-------------------------------|
| id                 | INT (PK)      | Khoa chinh, tu tang           |
| class_name         | VARCHAR(100)  | Ten lop (dung cho YOLO)       |
| ten_viet           | VARCHAR(200)  | Ten tieng Viet                |
| ten_khoa_hoc       | VARCHAR(200)  | Ten khoa hoc (Latin)          |
| ho                 | VARCHAR(200)  | Ho (Family)                   |
| kich_thuoc         | VARCHAR(100)  | Kich thuoc                    |
| mau_sac            | TEXT          | Mo ta mau sac                 |
| moi_truong         | TEXT          | Moi truong song               |
| dac_diem_sinh_hoc  | TEXT          | Dac diem sinh hoc             |
| gay_hai            | TEXT          | Tinh hinh gay hai             |
| phong_chong        | TEXT          | Bien phap phong chong         |
| hinh_anh_url       | VARCHAR(500)  | Duong dan hinh anh minh hoa   |
| hinh_anh_gay_hai   | VARCHAR(500)  | Duong dan hinh anh gay hai    |


## Cau truc model YOLO

- Mo hinh: YOLOv11n (nano)
- Dinh dang: ONNX (best.onnx)
- Nguong tin cay mac dinh: 0.25 (cau hinh), 0.60 (nhan dien thuc te)
- So lop: 9 loai bo canh cung
- Task: Object Detection


## Thong tin du an

- De tai: Ung dung nhan dien bo canh cung
- Sinh vien: Nguyen Huynh Yen Nhu
- Lop: DA22TTA
- Ma so: tn-da22tta-nguyenhuynhyennhu-udnhandienbcc
