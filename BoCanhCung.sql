
-- TẠO DATABASE
CREATE DATABASE IF NOT EXISTS beetle_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE beetle_db;


-- BẢNG 1: Thông tin loài
CREATE TABLE species (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    class_name        VARCHAR(100) NOT NULL UNIQUE,
    ten_viet          VARCHAR(200),
    ten_khoa_hoc      VARCHAR(200),
    ho                VARCHAR(200),
    kich_thuoc        VARCHAR(100),
    mau_sac           TEXT,
    moi_truong        TEXT,
    dac_diem_sinh_hoc TEXT,
    gay_hai           TEXT,
    phong_chong       TEXT,
    muc_do_nguy_hiem  VARCHAR(50),
    hinh_anh_url      VARCHAR(500),
    created_at        DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- BẢNG 2: Lịch sử nhận diện
CREATE TABLE detection_history (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    device_id    VARCHAR(200),
    class_name   VARCHAR(100),
    confidence   FLOAT,
    bbox         VARCHAR(200),
    image_path   VARCHAR(500),
    detected_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;
USE beetle_db;

TRUNCATE TABLE species;

INSERT INTO species (
    class_name, ten_viet, ten_khoa_hoc, ho,
    kich_thuoc, mau_sac, moi_truong,
    dac_diem_sinh_hoc, gay_hai, phong_chong,
    muc_do_nguy_hiem, hinh_anh_url
)
VALUES
-- 1. CanhCam — Bọ Cánh Cam
(
    'CanhCam',
    'Bọ Cánh Cam',
    'Anomala cupripes',
    'Scarabaeidae',
    '15-20 mm',
    'Toàn thân màu xanh lục ánh kim loại, cánh cứng bóng có ánh đồng hoặc vàng cam khi phản chiếu ánh sáng',
    'Vườn cây ăn trái, vườn dừa, khu vực đất nông nghiệp vùng nhiệt đới',
    'Trải qua 4 giai đoạn biến thái hoàn toàn: trứng, ấu trùng, nhộng và thành trùng. Ấu trùng sống trong đất, thành trùng hoạt động mạnh vào ban đêm và bị thu hút bởi ánh sáng đèn.',
    'Thành trùng ăn lá cây, hoa và trái non vào ban đêm. Ấu trùng (sùng đất) ăn rễ cây con trong đất gây héo và chết cây. Gây hại nhiều trên cây ăn trái và cây công nghiệp.',
    'Biện pháp cơ học: Dùng bẫy đèn thu hút và tiêu diệt thành trùng vào ban đêm. Biện pháp canh tác: Cày xới đất để diệt ấu trùng và nhộng trong đất. Biện pháp sinh học: Sử dụng nấm Metarhizium anisopliae xử lý đất. Biện pháp hóa học: Dùng thuốc hạt rải vào đất khi mật độ sâu cao.',
    'Trung bình',
    ''
),

-- 2. bodua — Bọ Dừa
(
    'bodua',
    'Bọ Dừa',
    'Brontispa longissima Gestro',
    'Chrysomelidae',
    '9-10 mm dài, 2-2.25 mm ngang, râu dài 2.75 mm',
    'Thân dẹt, màu nâu vàng đến nâu đen, cánh cứng có rãnh dọc',
    'Vườn dừa, vườn cọ các tỉnh phía Nam Việt Nam. Xuất hiện tại Việt Nam từ cuối năm 1999.',
    'Vòng đời 130-135 ngày gồm 4 giai đoạn: trứng, ấu trùng, nhộng và thành trùng. Con cái bắt đầu đẻ trứng khi được 2 tuần tuổi, có thể đẻ đến 120 trứng trong suốt vòng đời. Có tập tính hoạt động về đêm, không thích ánh sáng.',
    'Thành trùng và ấu trùng đều gây hại. Chúng xâm nhập vào các kẽ lá dừa non còn xếp chưa bung ra, ăn biểu bì trên mặt lá non theo từng hàng song song với gân chính. Tạo thành những vết có màu nâu, làm cho lá bị cong vẹo và khô giống như bị cháy, bị rách và cây trở nên xơ xác. Nếu trên cây có từ 8 lá bị hại thì năng suất giảm, nặng hơn cây có thể bị chết.',
    'Biện pháp cơ học: Chăm sóc tốt cây dừa để rút ngắn thời gian nở bung bó lá ngọn; cắt bỏ tiêu hủy lá bị tấn công; đối với cây con trong vườn ươm nên bắt thủ công. Biện pháp hóa học: Dùng Padan 95SP, Actara 25WG, Diaphos 10GR trộn với mạt cưa túm vào bao vải mỏng treo ở ngọn cây (hiệu quả kéo dài đến 90 ngày); Actara 25WG bơm vào thân cây cách gốc 1-1.5m, đục lỗ nghiêng 45 độ sâu 3-4cm rồi bịt lại bằng đất sét. Biện pháp sinh học: Dùng ong ký sinh Asecodes hispinarum đẻ trứng vào nhộng bọ dừa để tiêu diệt.',
    'Cao',
    ''
),

-- 3. boha — Bọ Hà (Sâu Nái hại dừa)
(
    'boha',
    'Sâu Nái',
    'Parasa lepida',
    'Limacodidae',
    'Ấu trùng dài 25-30 mm, nhộng dài 15 mm',
    'Ấu trùng màu xanh lá cây, có nhiều chùm lông sắp xếp đều đặn dọc theo thân, 4 chùm lông ở gần đầu và phía sau đuôi màu đỏ. Thành trùng là bướm màu xanh lá cây với đốm màu nâu trên cánh.',
    'Vườn dừa, cây cọ và các cây lá dài. Phổ biến tại vùng nhiệt đới Đông Nam Á.',
    'Giai đoạn trứng khoảng 7 ngày; sâu non 40-45 ngày; nhộng 30-45 ngày; trưởng thành 7-10 ngày. Trứng trơn láng hình tròn hoặc bầu dục, được đẻ ở mặt dưới lá thành từng nhóm 10-20 trứng. Nhộng được bao bọc bởi kén màu nâu, bên ngoài phủ lớp tơ trắng.',
    'Khác với bọ dừa, sâu nái ăn lá dừa già. Giai đoạn ấu trùng là giai đoạn phá hoại chủ yếu. Ban đầu ấu trùng ăn lớp biểu bì bên dưới của lá, khi lớn chúng ăn toàn bộ phiến lá chỉ để lại gân lá. Trường hợp gây hại nặng tán lá trở nên xơ xác, cây không quang hợp được dẫn đến giảm năng suất dừa. Sâu rất ngứa khi chạm phải vì các lông nhọn tiết ra chất độc gây nóng bỏng khi tiếp xúc da người.',
    'Biện pháp sinh học: Sử dụng côn trùng ký sinh như ruồi và ong bắp cày, chúng đẻ trứng trên ấu trùng và nhộng của sâu nái. Biện pháp cơ học: Đối với dừa nhỏ, bắt và giết sâu non để giảm quần thể; dùng bẫy ánh sáng bắt bướm trưởng thành bay đêm, đặt khoảng 10 bẫy đèn/ha. Kiểm soát canh tác: Dùng máy kéo cày xới đất tiêu diệt kén. Biện pháp hóa học: Phun thuốc gốc cúc tổng hợp như Sherpa 25EC, Map-Permethrin 50EC, Cyperan 10EC khi mật độ cao.',
    'Cao',
    ''
),

-- 4. boray — Bọ Rầy (Rệp Dính hại dừa)
(
    'boray',
    'Rệp Dính',
    'Aspidiotus destructor',
    'Diaspididae',
    '1-2 mm',
    'Có lớp vỏ sáp hình tròn dẹt phủ bên ngoài, màu trắng xám đến nâu nhạt',
    'Vườn dừa đang lớn, cũng gây hại trên cam, quýt, mãng cầu. Phá hại chủ yếu vào mùa khô.',
    'Rệp dính là loài chích hút nhựa cây, thường tập trung thành quần thể lớn trên bề mặt lá, bông, mo và cuống trái dừa non. Khi phát hiện trên lá có một lớp muội đen (nấm bồ hóng) hoặc kiến hôi làm tổ ở những bẹ lá là dấu hiệu có rệp dính.',
    'Rệp dính chích hút nhựa từ bông, mo và cuống trái dừa non, làm suy yếu cây và giảm năng suất. Lớp muội đen (nấm bồ hóng) phát triển trên chất bài tiết của rệp bao phủ bề mặt lá, làm giảm khả năng quang hợp. Nếu gây hại nặng cây sẽ suy kiệt, trái nhỏ và rụng sớm.',
    'Biện pháp canh tác: Thường xuyên dọn sạch sẽ thông thoáng tán dừa; tiêu hủy những tàu lá bị rệp gây hại. Biện pháp hóa học: Dùng thuốc Admire 200OD, Yamida 10WP, Conphai 100SL, Maxfos 50EC, Mapy 48EC phun trên lá bị hại 2 lần cách nhau 7-10 ngày.',
    'Trung bình',
    ''
),
-- 5. bovoivoi — Bọ Vòi Voi

(
    'bovoivoi',
    'Bọ Vòi Voi',
    'Diocalandra frumenti',
    'Curculionidae',
    'Trưởng thành dài 7-8 mm, ngang 1.5 mm',
    'Trưởng thành là côn trùng bộ cánh cứng màu nâu đen, cánh trước có 2 đốm vàng ở đầu cánh và cuối cánh. Trưởng thành sợ ánh sáng, hoạt động mạnh lúc chiều tối.',
    'Vườn dừa, cây cọ dầu. Sống ở nơi tiếp xúc giữa hai trái hoặc gần cuống trái.',
    'Trải qua 4 giai đoạn: Trứng màu trắng trong dài 1-1.1mm, giai đoạn trứng 6-10 ngày; Ấu trùng màu vàng lợt có 5 tuổi (1-7.2mm), sống bằng cách đục thành đường hầm trong vỏ trái; Nhộng trần không tạo kén, màu trắng đục, dài 6.7-7.2mm, hóa nhộng trong đường đục, giai đoạn nhộng 10-16 ngày.',
    'Trái dừa bị hại thường có 3-5 con bọ vòi voi trưởng thành. Trái bị hại có nhiều vết nhựa chảy ra từ vết đục, tập trung quanh cuống trái, nhựa màu trong suốt sau chuyển sang vàng nâu và khô cứng. Ấu trùng đục vào vỏ trái, có thể đục vào tới gáo dừa giai đoạn trái non. Trái bị nhiều vết gây hại sẽ rụng sớm (tấn công trái dưới 3 tháng) và làm trái méo mó kích thước nhỏ (tấn công trái trên 3 tháng). Ngoài trái, chúng còn tấn công trên thân, gốc và rễ dừa.',
    'Biện pháp canh tác: Chăm sóc vườn dừa, cắt bỏ những tàu lá bên dưới, tiêu hủy những trái bị nhiễm để hạn chế phát tán lây lan. Biện pháp sinh học: Phun nấm đối kháng Metarhizium anisopliae (Ma). Biện pháp hóa học: Sử dụng các loại thuốc Abatox 1.8EC, Mapy 48EC, Regent 5SC phun xịt lên khắp các buồng trái non của cây dừa.',
    'Cao',
    ''
),

-- 6. duong — Đuông Dừa
(
    'duong',
    'Đuông Dừa',
    'Rhynchophorus ferrugineus',
    'Curculionidae',
    'Ấu trùng dài 50-60 mm, thành trùng dài 30-40 mm',
    'Thành trùng có màu nâu hơi đỏ hoặc đen, có một cái sừng dài với mũi sừng hơi cong xuống. Ấu trùng có màu kem, đàn hồi, không chân với đầu màu nâu.',
    'Vườn dừa các vùng nhiệt đới. Cây dừa từ 2-15 năm tuổi đều có thể bị tấn công, nhưng cây 3-6 năm tuổi dễ bị tấn công nhất.',
    'Vòng đời 195 ngày gồm 4 giai đoạn. Trứng: Con cái đẻ trung bình 240 trứng, nở sau 3-5 ngày, đẻ trên vết nứt và nơi bị tổn thương của thân. Ấu trùng: Giai đoạn gây hại chính, màu kem không chân, ăn mô gỗ dừa trong vòng 50 ngày. Nhộng: Nằm trong kén làm bằng mô gỗ dừa, phát triển 14-29 ngày. Thành trùng: Sống được 3-4 tháng, đẻ 70-140 trứng.',
    'Đuông là côn trùng gây hại nguy hiểm nhất vì rất khó phát hiện khi bắt đầu tấn công đọt non, đến khi phát hiện thì đỉnh sinh trưởng đã bị phá hủy và cây dừa chết không thể cứu được. Ấu trùng khoét lỗ nhỏ trên thân hoặc ngọn cây, ăn theo mọi hướng tạo lỗ lớn và sâu. Khi ấu trùng ăn đọt dừa, lá non bắt đầu héo và ngã xuống báo hiệu cây sắp chết.',
    'Biện pháp cơ học: Khoan sâu vào thân cây 10-25cm hướng lệch xuống 15cm bên trên vùng bị tấn công, cho thuốc Vibasu 10GR vào lỗ khoan, bịt kín bằng đất sét. Sau 3-4 ngày kiểm tra: nếu vẫn nghe tiếng rạo rạo thì xử lý thuốc lần hai. Biện pháp phòng ngừa: Tránh gây tổn thương trên thân dừa; dùng bột than sơn lên vết thương cây con; kiểm soát kiến vương vì vết đục của kiến vương tạo chỗ đẻ trứng cho đuông; đốn và đốt cây bị hại nặng; loại bỏ xác cây dừa non và gốc dừa chết. Thăm đồng thường xuyên để phát hiện kịp thời.',
    'Rất cao',
    ''
),
-- 7. kienduong — Kiến Vương (Kiến Dương)
(
    'kienduong',
    'Kiến Vương',
    'Oryctes rhinoceros L.',
    'Scarabaeidae',
    'Ấu trùng phát triển đầy đủ 60-105 mm, trứng đường kính 3-4 mm',
    'Thành trùng màu đen hơi nâu với 1 cái sừng tương đối dài ở trên đầu cong về phía sau. Ấu trùng có màu trắng đục, thường gập cong thân lại với đầu màu nâu và 3 đôi chân.',
    'Vườn dừa ở đủ mọi lứa tuổi. Đẻ trứng trong thân dừa và gốc dừa mục ẩm, đống rác, phân trâu bò, rơm mục, thân bắp, lá mía.',
    'Trải qua 4 giai đoạn phát triển. Trứng: Hình tròn màu trắng đường kính 3-4mm, nở sau 7-18 ngày. Ấu trùng: Màu trắng đục, gập cong thân, đầu nâu, 3 đôi chân, kích thước 60-105mm. Nhộng: Màu nâu nhạt, bao phủ bởi kén từ đất và xơ dừa, phát triển 14-29 ngày. Thành trùng: Sống được 4 tháng, con cái đẻ 70-140 trứng, ăn chồi và lá chưa tách trong bó lá ngọn.',
    'Kiến vương là côn trùng phổ biến và gây thiệt hại nhiều nhất cho cây dừa. Thành trùng tấn công cây dừa ở đủ mọi lứa tuổi, ăn các lá non đang phát triển, đục vào chồi và đỉnh tăng trưởng. Khi lá mọc ra có hình tam giác và lá chét bị cắt hình răng lược. Nếu liên tục bị tấn công cây sẽ mất sức phát triển do bộ lá bị hư hại. Nguy hiểm nhất là đuông và nấm sẽ xâm nhập vào thân dừa qua vết thương do kiến vương gây ra.',
    'Vệ sinh vườn: Dọn dẹp hoặc đốt đống rác, thân lá dừa hoai mục, không tạo môi trường cho kiến vương đẻ trứng. Kiểm tra định kỳ và bắt bằng tay. Biện pháp sinh học: Sử dụng nấm Metarhizium anisopliae (Ometar) ký sinh vào côn trùng. Biện pháp hóa học: Dùng mạt cưa trộn Regent 0.3GR hoặc Vibasu 10GR rải lên nách lá đọt vài tháng một lần. Dùng lưới cước cỡ mắt 2cm quấn kín 5-6 kẽ bẹ lá ngọn bẫy kiến vương. Nếu phát hiện tấn công, dùng Regent kết hợp Aliette bơm vào các lỗ đục.',
    'Rất cao',
    ''
);

UPDATE species SET hinh_anh_url = '/images/canhcam.jpg' WHERE class_name = 'CanhCam';
UPDATE species SET hinh_anh_url = '/images/bodua.jpg' WHERE class_name = 'bodua';
UPDATE species SET hinh_anh_url = '/images/boha.jpg' WHERE class_name = 'boha';
UPDATE species SET hinh_anh_url = '/images/boray.jpg' WHERE class_name = 'boray';
UPDATE species SET hinh_anh_url = '/images/bovoivoi.jpg' WHERE class_name = 'bovoivoi';
UPDATE species SET hinh_anh_url = '/images/duong.jpg' WHERE class_name = 'duong';
UPDATE species SET hinh_anh_url = '/images/kienduong.jpg' WHERE class_name = 'kienduong';

