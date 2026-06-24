import os
from flask       import Flask, jsonify, send_from_directory
from flask_cors  import CORS
from ultralytics import YOLO

from config         import Config
from extensions     import db
from routes.predict import predict_bp
from routes.species import species_bp


def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    # Kết nối tới database (KHÔNG tạo bảng, bảng đã có sẵn)
    db.init_app(app)
    CORS(app)

    # Tải mô hình YOLOv11 1 lần khi server khởi động
    print(" Đang tải mô hình YOLOv11n...")
    app.config["YOLO_MODEL"]     = YOLO(Config.MODEL_PATH, task="detect")
    app.config["CONF_THRESHOLD"] = Config.CONF_THRESHOLD
    print(" Tải mô hình thành công!")

    # Đăng ký các route
    app.register_blueprint(predict_bp, url_prefix="/api")
    app.register_blueprint(species_bp, url_prefix="/api")

    print(" Đã kết nối tới MySQL!")

    # Phục vụ ảnh tĩnh từ thư mục image/
    IMAGE_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "image")

    @app.route("/images/<path:filename>")
    def serve_image(filename):
        return send_from_directory(IMAGE_DIR, filename)

    # Trang chủ kiểm tra server
    @app.route("/")
    def home():
        return jsonify({
            "status" : "running",
            "message": "Beetle Detection API đang hoạt động",
            "endpoints": [
                "POST /api/predict",
                "GET  /api/species",
                "GET  /api/history",
            ]
        })

    return app


if __name__ == "__main__":
    app = create_app()
    print(" Server đang chạy tại: http://localhost:5000")
    app.run(host="0.0.0.0", port=5000, debug=False)