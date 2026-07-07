import os
import json
import uuid
import subprocess

import cv2
import numpy as np
from flask import (
    Blueprint, request, jsonify, current_app, send_from_directory
)
from PIL import Image, ImageDraw, ImageFont
from io import BytesIO

from extensions import db
from models import Species

predict_bp = Blueprint("predict", __name__)

# Thư mục lưu video đã xử lý (cùng cấp với app.py)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROCESSED_DIR = os.path.join(BASE_DIR, "processed_videos")

# Font hỗ trợ tiếng Việt (tự chọn theo hệ điều hành)
FONT_PATH = (
    "C:/Windows/Fonts/arial.ttf"
    if os.name == "nt"
    else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
)

# Chạy model mỗi SKIP frame; các frame còn lại dùng lại khung gần nhất.
# Tăng để nhanh hơn (3-5), giảm để khung bám sát hơn (1-2).
FRAME_SKIP = 3
# Chỉ lấy kết quả có độ tin cậy >= 60%
MIN_CONFIDENCE = 0.6

# ================================================================== #
#  Helper
# ================================================================== #
def _load_font(size):
    try:
        return ImageFont.truetype(FONT_PATH, size)
    except Exception:
        return ImageFont.load_default()


def _draw_labels(frame_bgr, labels, font):
    """Vẽ tất cả nhãn (tiếng Việt) trong 1 lần chuyển PIL cho nhanh."""
    img = Image.fromarray(cv2.cvtColor(frame_bgr, cv2.COLOR_BGR2RGB))
    draw = ImageDraw.Draw(img)
    for x1, y1, text in labels:
        tb = draw.textbbox((0, 0), text, font=font)
        tw, th = tb[2] - tb[0], tb[3] - tb[1]
        ty = max(0, y1 - th - 8)
        draw.rectangle([x1, ty, x1 + tw + 10, ty + th + 8], fill=(0, 255, 0))
        draw.text((x1 + 5, ty + 3), text, font=font, fill=(0, 0, 0))
    return cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)


def _species_ten_viet(class_name, cache):
    """Lấy tên tiếng Việt của loài, có cache để khỏi query DB mỗi frame."""
    if class_name not in cache:
        sp = Species.query.filter_by(class_name=class_name).first()
        cache[class_name] = sp.ten_viet if sp and sp.ten_viet else class_name
    return cache[class_name]


# ================================================================== #
#  POST /api/predict  -  nhận diện 1 ảnh
# ================================================================== #
@predict_bp.route("/predict", methods=["POST"])
def predict():
    """
    Flutter gọi: POST http://<ip>:5000/api/predict
    Body: form-data, key = "image", value = file ảnh
    """
    if "image" not in request.files:
        return jsonify({"status": "error", "message": "Thiếu file ảnh"}), 400

    file = request.files["image"]
    if file.filename == "":
        return jsonify({"status": "error", "message": "File ảnh trống"}), 400

    try:
        img = Image.open(BytesIO(file.read())).convert("RGB")

        model = current_app.config["YOLO_MODEL"]
        conf_thres = current_app.config["CONF_THRESHOLD"]
        results = model(img, conf=MIN_CONFIDENCE)[0]

        device_id = request.form.get("device_id", "unknown")

        predictions = []
        for box in results.boxes:
            class_name = results.names[int(box.cls)]
            confidence = round(float(box.conf), 4)
            bbox = box.xyxyn[0].tolist()

            species = Species.query.filter_by(class_name=class_name).first()

            predictions.append({
                "class_name":        class_name,
                "confidence":        confidence,
                "bbox":              bbox,
                "ten_viet":          species.ten_viet          if species else "",
                "ten_khoa_hoc":      species.ten_khoa_hoc      if species else "",
                "ho":                species.ho                if species else "",
                "kich_thuoc":        species.kich_thuoc        if species else "",
                "mau_sac":           species.mau_sac           if species else "",
                "moi_truong":        species.moi_truong        if species else "",
                "dac_diem_sinh_hoc": species.dac_diem_sinh_hoc if species else "",
                "gay_hai":           species.gay_hai           if species else "",
                "phong_chong":       species.phong_chong       if species else "",
                "hinh_anh_url":      species.hinh_anh_url      if species else "",
                "hinh_anh_gay_hai":  species.hinh_anh_gay_hai  if species else "",
            })


        return jsonify({
            "status": "success",
            "count": len(predictions),
            "predictions": predictions,
        })

    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


# ================================================================== #
#  POST /api/predict_video  -  nhận diện cả video
# ================================================================== #
@predict_bp.route("/predict_video", methods=["POST"])
def predict_video():
    """
    Flutter gọi: POST http://<ip>:5000/api/predict_video
    Body: form-data, key = "video", value = file video
    """
    if "video" not in request.files:
        return jsonify({"status": "error", "message": "Thiếu file video"}), 400

    file = request.files["video"]
    if file.filename == "":
        return jsonify({"status": "error", "message": "File video trống"}), 400

    device_id = request.form.get("device_id", "unknown")
    model = current_app.config["YOLO_MODEL"]
    conf_thres = current_app.config["CONF_THRESHOLD"]

    upload_dir = os.path.join(BASE_DIR, "uploads_tmp")
    os.makedirs(upload_dir, exist_ok=True)
    os.makedirs(PROCESSED_DIR, exist_ok=True)

    in_path = os.path.join(upload_dir, f"{uuid.uuid4().hex}_{file.filename}")
    file.save(in_path)

    out_name = f"{uuid.uuid4().hex}.mp4"
    out_path_raw = os.path.join(PROCESSED_DIR, f"raw_{out_name}")
    out_path = os.path.join(PROCESSED_DIR, out_name)

    try:
        cap = cv2.VideoCapture(in_path)
        if not cap.isOpened():
            return jsonify({"status": "error", "message": "Không mở được video"}), 400

        fps = cap.get(cv2.CAP_PROP_FPS) or 25
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

        fourcc = cv2.VideoWriter_fourcc(*"mp4v")
        writer = cv2.VideoWriter(out_path_raw, fourcc, fps, (width, height))

        font = _load_font(max(18, height // 30))
        species_cache = {}      # class_name -> ten_viet
        detected = {}           # class_name -> tóm tắt

        last_boxes = []         # khung của lần nhận diện gần nhất
        last_labels = []
        frame_idx = 0

        # ---- Xử lý từng frame ----
        while True:
            ret, frame = cap.read()
            if not ret:
                break
            frame_idx += 1

            # Chỉ chạy YOLO ở 1/FRAME_SKIP số frame
            if frame_idx % FRAME_SKIP == 1:
                results = model(frame, conf=MIN_CONFIDENCE, verbose=False)[0]
                last_boxes, last_labels = [], []

                for box in results.boxes:
                    conf = float(box.conf)
                    x1, y1, x2, y2 = map(int, box.xyxy[0].tolist())
                    class_name = results.names[int(box.cls)]
                    ten_viet = _species_ten_viet(class_name, species_cache)

                    last_boxes.append((x1, y1, x2, y2))
                    last_labels.append((x1, y1, f"{ten_viet} {conf * 100:.0f}%"))

                    d = detected.setdefault(
                        class_name,
                        {"count": 0, "max_conf": 0.0, "ten_viet": ten_viet},
                    )
                    d["count"] += 1
                    d["max_conf"] = max(d["max_conf"], conf)

            # Vẽ khung gần nhất lên MỌI frame (kể cả frame bỏ qua)
            for (x1, y1, x2, y2) in last_boxes:
                cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
            if last_labels:
                frame = _draw_labels(frame, last_labels, font)

            writer.write(frame)

        cap.release()
        writer.release()

        # ---- Re-encode sang H.264 để Flutter phát được ----
        try:
            subprocess.run(
                [
                    "ffmpeg", "-y",
                    "-i", out_path_raw,
                    "-c:v", "libx264",
                    "-preset", "fast",
                    "-crf", "23",
                    "-pix_fmt", "yuv420p",
                    "-movflags", "+faststart",
                    out_path,
                ],
                check=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            try:
                os.remove(out_path_raw)
            except OSError:
                pass
        except Exception as ffmpeg_err:
            # Không có ffmpeg hoặc lỗi -> dùng file raw luôn
            print(f"Lỗi encode video bằng ffmpeg: {ffmpeg_err}")
            os.replace(out_path_raw, out_path)



        # ---- URL khớp đúng IP/port mà Flutter gọi ----
        video_url = f"{request.scheme}://{request.host}/api/processed_videos/{out_name}"

        return jsonify({
            "status": "success",
            "video_url": video_url,
            "fps": fps,
            "frames": frame_idx,
            "detections": [
                {
                    "class_name": cn,
                    "ten_viet": d["ten_viet"],
                    "count": d["count"],
                    "confidence": round(d["max_conf"] * 100, 1),
                }
                for cn, d in detected.items()
            ],
        })

    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

    finally:
        # Xóa file upload tạm
        try:
            os.remove(in_path)
        except OSError:
            pass


# ================================================================== #
#  GET /api/processed_videos/<filename>  -  phục vụ video kết quả
# ================================================================== #
@predict_bp.route("/processed_videos/<path:filename>")
def serve_processed_video(filename):
    return send_from_directory(PROCESSED_DIR, filename)