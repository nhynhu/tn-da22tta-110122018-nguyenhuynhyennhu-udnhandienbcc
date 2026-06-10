from flask      import Blueprint, request, jsonify
from extensions import db
from models     import Species, DetectionHistory

species_bp = Blueprint("species", __name__)


@species_bp.route("/species", methods=["GET"])
def get_all():
    """Đọc danh sách tất cả loài"""
    species_list = Species.query.order_by(Species.ten_viet).all()
    return jsonify([s.to_dict() for s in species_list])


@species_bp.route("/species/<class_name>", methods=["GET"])
def get_one(class_name):
    """Đọc thông tin 1 loài"""
    species = Species.query.filter_by(class_name=class_name).first()
    if not species:
        return jsonify({"status": "error", "message": "Không tìm thấy loài"}), 404
    return jsonify(species.to_dict())


@species_bp.route("/species/<class_name>", methods=["PUT"])
def update(class_name):
    """Cập nhật thông tin loài"""
    species = Species.query.filter_by(class_name=class_name).first()
    if not species:
        return jsonify({"status": "error", "message": "Không tìm thấy loài"}), 404

    data   = request.get_json()
    fields = [
        "ten_viet", "ten_khoa_hoc", "ho", "kich_thuoc",
        "mau_sac", "moi_truong", "gay_hai",
        "phong_chong", "muc_do_nguy_hiem", "hinh_anh_url",
    ]
    for field in fields:
        if field in data:
            setattr(species, field, data[field])

    db.session.commit()
    return jsonify({"status": "updated", "data": species.to_dict()})


@species_bp.route("/history", methods=["GET"])
def get_history():
    """Đọc lịch sử nhận diện"""
    device_id = request.args.get("device_id")
    limit     = int(request.args.get("limit", 20))

    results = db.session.query(DetectionHistory, Species.ten_viet).\
        outerjoin(Species, DetectionHistory.class_name == Species.class_name).\
        order_by(DetectionHistory.detected_at.desc())

    if device_id:
        results = results.filter(DetectionHistory.device_id == device_id)

    history_list = []
    for history, ten_viet in results.limit(limit).all():
        d = history.to_dict()
        d["ten_viet"] = ten_viet or ""
        history_list.append(d)

    return jsonify(history_list)


@species_bp.route("/history/<int:history_id>", methods=["DELETE"])
def delete_history_item(history_id):
    """Xóa 1 mục lịch sử nhận diện"""
    item = DetectionHistory.query.filter_by(id=history_id).first()
    if not item:
        return jsonify({"status": "error", "message": "Không tìm thấy mục lịch sử"}), 404

    db.session.delete(item)
    db.session.commit()
    return jsonify({"status": "success", "message": "Đã xóa mục lịch sử"})


@species_bp.route("/history", methods=["DELETE"])
def clear_history():
    """Xóa toàn bộ lịch sử của 1 thiết bị"""
    device_id = request.args.get("device_id")
    if not device_id:
        return jsonify({"status": "error", "message": "Thiếu device_id"}), 400

    DetectionHistory.query.filter_by(device_id=device_id).delete()
    db.session.commit()
    return jsonify({"status": "success", "message": "Đã xóa toàn bộ lịch sử"})
