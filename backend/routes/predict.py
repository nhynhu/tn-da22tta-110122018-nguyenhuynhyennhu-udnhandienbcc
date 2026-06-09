import json
from flask      import Blueprint, request, jsonify, current_app
from PIL        import Image
from io         import BytesIO
from extensions import db
from models     import Species, DetectionHistory

predict_bp = Blueprint("predict", __name__)


@predict_bp.route("/predict", methods=["POST"])
def predict():
    """
    Flutter gọi: POST http://localhost:5000/api/predict
    Body: form-data, key = "image", value = file ảnh
    """

    if "image" not in request.files:
        return jsonify({"status": "error", "message": "Thiếu file ảnh"}), 400

    file = request.files["image"]
    if file.filename == "":
        return jsonify({"status": "error", "message": "File ảnh trống"}), 400

    try:
        # Đọc ảnh
        img = Image.open(BytesIO(file.read())).convert("RGB")

        # Chạy mô hình YOLOv11
        model      = current_app.config["YOLO_MODEL"]
        conf_thres = current_app.config["CONF_THRESHOLD"]
        results    = model(img, conf=conf_thres)[0]

        device_id = request.form.get("device_id", "unknown")

        predictions = []
        for box in results.boxes:
            class_name = results.names[int(box.cls)]
            confidence = round(float(box.conf), 4)
            bbox       = box.xyxyn[0].tolist()

            # Đọc thông tin loài từ MySQL (SELECT)
            species = Species.query.filter_by(class_name=class_name).first()

            # Ghi lịch sử vào MySQL (INSERT)
            db.session.add(DetectionHistory(
                device_id  = device_id,
                class_name = class_name,
                confidence = confidence,
                bbox       = json.dumps(bbox),
            ))

            predictions.append({
                "class_name"       : class_name,
                "confidence"       : confidence,
                "bbox"             : bbox,
                "ten_viet"         : species.ten_viet         if species else "",
                "ten_khoa_hoc"     : species.ten_khoa_hoc     if species else "",
                "gay_hai"          : species.gay_hai          if species else "",
                "phong_chong"      : species.phong_chong      if species else "",
                "muc_do_nguy_hiem" : species.muc_do_nguy_hiem if species else "",
                "hinh_anh_url"     : species.hinh_anh_url     if species else "",
            })

        db.session.commit()

        return jsonify({
            "status"      : "success",
            "count"       : len(predictions),
            "predictions" : predictions,
        })

    except Exception as e:
        db.session.rollback()
        return jsonify({"status": "error", "message": str(e)}), 500