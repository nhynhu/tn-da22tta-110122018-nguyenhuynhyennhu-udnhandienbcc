from datetime import datetime
from extensions import db


# Ánh xạ tới bảng species đã tạo trong MySQL
class Species(db.Model):
    __tablename__ = "species"

    id                      = db.Column(db.Integer,     primary_key=True)
    class_name              = db.Column(db.String(100), unique=True, nullable=False)
    ten_viet                = db.Column(db.String(200))
    ten_khoa_hoc            = db.Column(db.String(200))
    ho                      = db.Column(db.String(200))
    kich_thuoc              = db.Column(db.String(100))
    mau_sac                 = db.Column(db.Text)
    moi_truong              = db.Column(db.Text)
    dac_diem_sinh_hoc       = db.Column(db.Text)
    gay_hai                 = db.Column(db.Text)
    phong_chong             = db.Column(db.Text)
    muc_do_nguy_hiem        = db.Column(db.String(50))
    hinh_anh_url            = db.Column(db.String(500))
    created_at              = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at              = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self):
        return {
            "id"                : self.id,
            "class_name"        : self.class_name,
            "ten_viet"          : self.ten_viet,
            "ten_khoa_hoc"      : self.ten_khoa_hoc,
            "ho"                : self.ho,
            "kich_thuoc"        : self.kich_thuoc,
            "mau_sac"           : self.mau_sac,
            "moi_truong"        : self.moi_truong,
            "dac_diem_sinh_hoc" : self.dac_diem_sinh_hoc,
            "gay_hai"           : self.gay_hai,
            "phong_chong"       : self.phong_chong,
            "muc_do_nguy_hiem"  : self.muc_do_nguy_hiem,
            "hinh_anh_url"      : self.hinh_anh_url,
            "created_at"        : self.created_at.strftime("%Y-%m-%d %H:%M:%S"),
            "updated_at"        : self.updated_at.strftime("%Y-%m-%d %H:%M:%S"),
        }


# Ánh xạ tới bảng detection_history
class DetectionHistory(db.Model):
    __tablename__ = "detection_history"

    id          = db.Column(db.Integer,     primary_key=True)
    device_id   = db.Column(db.String(200))
    class_name  = db.Column(db.String(100))
    confidence  = db.Column(db.Float)
    bbox        = db.Column(db.String(200))
    image_path  = db.Column(db.String(500))
    detected_at = db.Column(db.DateTime, default=datetime.utcnow)

    def __init__(self, device_id=None, class_name=None, confidence=None, bbox=None, image_path=None, **kwargs):
        super().__init__(device_id=device_id, class_name=class_name, confidence=confidence, bbox=bbox, image_path=image_path, **kwargs)  # type: ignore

    def to_dict(self):
        return {
            "id"         : self.id,
            "device_id"  : self.device_id,
            "class_name" : self.class_name,
            "confidence" : self.confidence,
            "bbox"       : self.bbox,
            "image_path" : self.image_path,
            "detected_at": self.detected_at.strftime("%Y-%m-%d %H:%M:%S"),
        }
