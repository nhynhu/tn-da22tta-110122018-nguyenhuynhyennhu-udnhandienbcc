
-- TẠO DATABASE
CREATE DATABASE IF NOT EXISTS beetle_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE beetle_db;

 
CREATE TABLE IF NOT EXISTS species (
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
-- 0. BoDua — Bọ Dừa
(
    'BoDua',
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
    '/images/bodua.jpg'
),
 
-- 1. BoHa — (DB ghi là Sâu Nái — XEM GHI CHÚ CUỐI FILE)
(
    'BoHa',
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
    '/images/boha.jpg'
),
 
-- 2. BoNgau — Bọ Ngâu (MỚI THÊM — CẦN BỔ SUNG THÔNG TIN, xem ghi chú)
(
    'BoNgau',
    'Bọ Ngâu',
    '(Cần xác minh tên khoa học theo nguồn của bạn)',
    '(Cần bổ sung)',
    '(Cần bổ sung)',
    '(Cần bổ sung) - Mô tả màu sắc, hình thái của thành trùng và ấu trùng.',
    '(Cần bổ sung) - Môi trường sống và cây ký chủ.',
    '(Cần bổ sung) - Vòng đời và các giai đoạn phát triển.',
    '(Cần bổ sung) - Cách thức và mức độ gây hại.',
    '(Cần bổ sung) - Các biện pháp phòng chống.',
    'Trung bình',
    '/images/bongau.jpg'
),
 
-- 3. BoNhay — Bọ Nhảy Sọc Cong (MỚI THÊM)
(
    'BoNhay',
    'Bọ Nhảy Sọc Cong',
    'Phyllotreta striolata',
    'Chrysomelidae',
    'Trưởng thành dài 2-2.5 mm, ấu trùng dài khoảng 4 mm',
    'Trưởng thành hình bầu dục, cánh cứng màu đen bóng, giữa mỗi cánh có một vạch màu vàng nhạt cong hình vỏ lạc (vỏ đậu phộng). Chân sau to khỏe nên có sức nhảy xa.',
    'Gây hại chủ yếu trên rau họ thập tự (cải, su hào, súp lơ) và một số cây họ cà. Phát sinh nhiều trong mùa khô, gây hại nặng nhất ở giai đoạn cây con.',
    'Vòng đời 47-107 ngày, gồm 4 giai đoạn: trứng, sâu non, nhộng và trưởng thành. Trứng rất nhỏ màu vàng nhạt, được đẻ dưới đất gần gốc cây, mỗi con cái có thể đẻ tới 200 trứng. Ấu trùng hình ống màu vàng nhạt, sống trong đất. Thành trùng nhanh nhẹn, có tính giả chết khi bị động, hoạt động mạnh vào sáng sớm và chiều mát.',
    'Thành trùng gặm lá tạo thành những lỗ nhỏ li ti hoặc lỗ răng cưa trên lá, mật độ cao làm lá xơ xác và cây còi cọc, chậm phát triển. Ấu trùng sống trong đất cắn phá rễ và củ, tạo những đường lõm ngoằn ngoèo làm rễ và củ dễ bị thối.',
    'Biện pháp canh tác: Làm đất kỹ, phơi khô đất tối thiểu 10-15 ngày trước khi trồng để diệt sâu non và nhộng còn trong đất; vệ sinh đồng ruộng, dọn sạch tàn dư vụ trước. Biện pháp cơ học: Dùng bẫy dính bắt thành trùng. Biện pháp hóa học và sinh học: Phun thuốc trừ sâu sinh học hoặc hóa học vào lúc sáng sớm hoặc chiều mát khi bọ hoạt động.',
    'Trung bình',
    '/images/bonhay.jpg'
),
 
-- 4. BoRay — (DB ghi là Rệp Dính — XEM GHI CHÚ CUỐI FILE)
(
    'BoRay',
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
    '/images/boray.jpg'
),
 
-- 5. BoVoiVoi — Bọ Vòi Voi
(
    'BoVoiVoi',
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
    '/images/bovoivoi.jpg'
),
 
-- 6. CauCau — Câu Cấu Xanh (MỚI THÊM)
(
    'CauCau',
    'Câu Cấu Xanh',
    'Hypomeces squamosus',
    'Curculionidae',
    'Trưởng thành dài 7-15 mm',
    'Trưởng thành là bọ cánh cứng, toàn thân phủ một lớp vảy ánh kim màu xanh vàng; con cái màu xanh, con đực màu vàng. Đầu kéo dài như một cái vòi, mắt lồi, miệng có vòi nhai.',
    'Cây có múi (cam, quýt, bưởi), xoài, ổi và nhiều loại cây ăn trái khác. Phổ biến ở đồng bằng sông Cửu Long, gây hại nặng nhất vào các tháng mùa khô.',
    'Trải qua 4 giai đoạn: trứng, sâu non, nhộng và thành trùng. Trứng hình bầu dục dài khoảng 1mm, màu trắng ngà, được đẻ rải rác trên mặt đất quanh gốc cây. Sâu non màu trắng sữa, mình hơi cong, không chân, sống trong đất ăn chất hữu cơ và rễ cây. Nhộng màu trắng ngà nằm trong đất. Thành trùng bò chậm chạp, có tính giả chết buông mình rơi xuống đất khi bị động, hoạt động vào sáng sớm và chiều mát.',
    'Cả thành trùng và ấu trùng đều gây hại. Thành trùng cắn gặm lá, ăn khuyết lá, đọt non và trái non; khi mật độ cao có thể ăn trụi lá làm cây giảm sức sinh trưởng rõ rệt. Ấu trùng sống trong đất đục phá rễ và gốc cây.',
    'Biện pháp cơ học: Lợi dụng đặc tính giả chết, rung cây hoặc dùng sào gạt mạnh trên tán cho thành trùng rơi xuống tấm bạt trải dưới gốc rồi thu gom; bắt bằng tay khi cây ra đọt non. Biện pháp canh tác: Vệ sinh vườn thông thoáng, cày xới đất để diệt ấu trùng. Biện pháp hóa học: Rải thuốc hạt Basudin 10H, Diaphos 10G quanh gốc cây 1-2 lần/năm; phun thuốc có hoạt chất Lambda-cyhalothrin hoặc Profenofos vào lúc chiều mát khi cây vừa ra đọt non.',
    'Trung bình',
    '/images/caucau.jpg'
),
 
-- 7. DuongDua — Đuông Dừa
(
    'DuongDua',
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
    '/images/duongdua.jpg'
),
 
-- 8. KienDuong — Kiến Vương
(
    'KienDuong',
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
    '/images/kienduong.jpg'
);

