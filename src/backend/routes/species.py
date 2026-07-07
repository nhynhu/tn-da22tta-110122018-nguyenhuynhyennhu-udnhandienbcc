from flask      import Blueprint, request, jsonify
from extensions import db
from models     import Species

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
        "mau_sac", "moi_truong", "dac_diem_sinh_hoc", "gay_hai",
        "phong_chong", "hinh_anh_url", "hinh_anh_gay_hai",
    ]
    for field in fields:
        if field in data:
            setattr(species, field, data[field])

    db.session.commit()
    return jsonify({"status": "updated", "data": species.to_dict()})
