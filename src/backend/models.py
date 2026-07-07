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
    hinh_anh_url            = db.Column(db.String(500))
    hinh_anh_gay_hai        = db.Column(db.String(500))

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
            "hinh_anh_url"      : self.hinh_anh_url,
            "hinh_anh_gay_hai"  : self.hinh_anh_gay_hai,
        }


