-- TẠO DATABASE
CREATE DATABASE IF NOT EXISTS beetle_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE beetle_db;
 Drop table species;
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
	hinh_anh_url      VARCHAR(500),
    hinh_anh_gay_hai  VARCHAR(500)
);


SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;
USE beetle_db;

TRUNCATE TABLE species;

INSERT INTO species (
    class_name, ten_viet, ten_khoa_hoc, ho,
    kich_thuoc, mau_sac, moi_truong,
    dac_diem_sinh_hoc, gay_hai, phong_chong, hinh_anh_url, hinh_anh_gay_hai
)
VALUES
-- 0. BoDua — Bọ dừa
(
    'BoDua',
    'Bọ Dừa',
    'Brontispa longissima (Gestro)',
    'Ánh kim (Chrysomelidae)',
    'Thành trùng dài 8-12 mm',
    'Thân thuôn dài, màu nâu đỏ đến nâu đen bóng, cánh cứng mang các đường gân dọc rõ, đầu nhỏ và râu tương đối dài.',
    'Cây dừa và các loài cây họ Cau (Arecaceae). Có nguồn gốc từ vùng Đông Nam Á - Thái Bình Dương; tại Việt Nam bùng phát thành dịch từ cuối năm 1999, lan rộng khắp các tỉnh phía Nam.',
    'Vòng đời gồm bốn giai đoạn: trứng, ấu trùng, nhộng và trưởng thành. Trứng màu nâu sậm, hình hơi bầu dục, được đẻ riêng lẻ trên lá non chưa bung. Cả ấu trùng và thành trùng đều thích sống trong các tàu lá non còn xếp lại ở phần đọt.',
    'Cả ấu trùng và thành trùng đều cạp biểu bì mặt trong của lá non, tạo ra những vệt nâu chạy dọc theo gân lá. Khi mật độ cao, các vệt này liên kết lại làm lá khô cháy, quăn queo như bị lửa táp. Cây bị hại nặng mất khả năng quang hợp, sinh trưởng kém, giảm năng suất rõ rệt và có thể suy kiệt dần. Được xem là một trong những đối tượng gây hại nguy hiểm nhất trên cây dừa.',
    'Biện pháp sinh học: Phóng thích và bảo vệ thiên địch, đặc biệt là ong ký sinh Asecodes hispinarum và bọ đuôi kìm; sử dụng chế phẩm nấm ký sinh côn trùng (nấm xanh Metarhizium, nấm trắng Beauveria) phun lên đọt dừa.\nBiện pháp canh tác - thủ công: Vệ sinh vườn, cắt tỉa và tiêu hủy các tàu lá bị hại nặng nhằm giảm nguồn dịch.\nBiện pháp hóa học: Khi mật độ cao, dùng thuốc bảo vệ thực vật có tính lưu dẫn hoặc xông hơi, phun hoặc đặt vào nách lá non.',
    '/images/bodua.jpg',
    '/images/gay_hai/bodua.jpg'
),

-- 1. BoHa — Bọ hà khoai lang
(
    'BoHa',
    'Bọ Hà Khoai Lang',
    'Cylas formicarius (Fabricius)',
    'Vòi voi (Curculionidae)',
    'Thành trùng dài 5-8 mm, ấu trùng dài 7-10 mm',
    'Thân thuôn dài trông gần giống con kiến nên dân gian còn gọi là "kiến ăn khoai"; phần đầu và cánh cứng màu xanh đen bóng ánh kim, phần ngực và chân màu nâu đỏ (cam).',
    'Ký chủ chính là cây khoai lang. Điều kiện khô nóng, đất nứt nẻ rất thuận lợi cho bọ hà phát triển.',
    'Còn gọi là sùng khoai lang hay mọt khoai lang. Khi bị động có tập tính giả chết. Trứng hình bầu dục dài khoảng 0,7 mm, được đẻ rải rác trong các lỗ nhỏ trên củ hoặc thân gần mặt đất. Ấu trùng màu trắng ngà, không chân, dài khoảng 7-10 mm, đục thành đường hầm ngoằn ngoèo bên trong củ. Vòng đời hoàn chỉnh kéo dài khoảng 33 ngày.',
    'Là dịch hại quan trọng nhất trên cây khoai lang. Khi cây chưa có củ, bọ sống trong thân (dây khoai) với mật số thấp; khi củ hình thành chúng sinh sản nhanh và chuyển sang phá củ. Ấu trùng đục rỗng ruột củ tạo các đường hầm, kích thích củ tiết độc tố tự vệ khiến củ có vị đắng và mùi khó chịu, mất hoàn toàn giá trị thương phẩm. Thành trùng còn ăn biểu bì thân, lá và phá rễ làm cây còi cọc, lá vàng úa. Ở vùng đất khô hạn có thể gây thất thu 40-50% sản lượng.',
    'Biện pháp canh tác: Luân canh cây trồng, đặc biệt trồng khoai sau vụ lúa nước để cắt đứt vòng đời và hạn chế tỷ lệ củ bị hại; chọn hom giống sạch, vun gốc kín để tránh củ lộ ra mặt đất và bị đẻ trứng.\nBiện pháp sinh học - cơ giới: Sử dụng bẫy pheromone giới tính để dẫn dụ và tiêu diệt thành trùng đực; bảo vệ thiên địch tự nhiên như kiến, nhện, bọ rùa.\nBiện pháp vệ sinh - hóa học: Thu gom, tiêu hủy dây và củ bị hại sau thu hoạch; sử dụng thuốc bảo vệ thực vật khi cần thiết.',
    '/images/boha.jpg',
    '/images/gay_hai/boha.jpg'
),

-- 2. BoNgau — Bọ ngâu
(
    'BoNgau',
    'Bọ Ngâu',
    'Adoretus sp. / Anomala sp.',
    'Bọ hung (Scarabaeidae)',
    'Thành trùng (Anomala) dài 10-12 mm, rộng 5-6 mm',
    'Tùy loài, thành trùng có màu xanh, đen hoặc nâu; ở loài Anomala, thành trùng màu đen bóng với các sọc xuôi chạy dọc theo cánh, râu ngắn nhưng chân và hàm rất khỏe.',
    'Loài đa thực trên nhiều cây ăn trái và cây trồng như sầu riêng, nhãn. Phổ biến ở nơi đất ẩm, nhiều xác thực vật và chất hữu cơ, đặc biệt ở những vườn mới khai hoang gần tán rừng.',
    'Là tên gọi dân gian của nhóm bọ cánh cứng ăn lá thuộc các giống Adoretus và Anomala; ở nhiều nơi còn được gọi là "bù rầy". Thành trùng có kiểu miệng nhai, ban ngày ẩn nấp dưới lớp đất mặt hoặc trong tán cây rậm, đến chiều tối và ban đêm mới bay ra cắn phá. Vòng đời gồm bốn giai đoạn: trứng, ấu trùng, nhộng, trưởng thành; ấu trùng là dạng sùng trắng sống trong đất. Xuất hiện theo mùa, gây hại nặng nhất vào đầu và cuối mùa mưa.',
    'Loài đa thực. Thành trùng tấn công đọt non, lá non và cả lá đã trưởng thành, gặm khuyết hoặc ăn trụi lá làm thủng lá, suy giảm nghiêm trọng diện tích quang hợp, khiến cây còi cọc. Vào giai đoạn cây ra hoa, mùi hương dẫn dụ bọ ngâu đến cắn phá bông, gây thối nhũn và rụng bông, ảnh hưởng lớn đến thụ phấn và đậu trái. Vết thương do bọ ngâu gây ra tạo điều kiện cho nấm khuẩn xâm nhập. Giai đoạn ấu trùng, sùng đất ăn rễ làm cây thiếu dinh dưỡng và suy yếu.',
    'Biện pháp cơ giới: Dùng bẫy đèn đồng loạt vào chiều tối tại các khu vực xuất hiện nhiều bọ ngâu để thu hút và tiêu diệt thành trùng; kết hợp bắt thủ công.\nBiện pháp canh tác: Thường xuyên thăm vườn để phát hiện sớm; đậy kín các đống ủ phân hữu cơ; cày xới, phơi ải đất để diệt ấu trùng và nhộng.\nBiện pháp sinh học: Sử dụng chế phẩm sinh học như Bacillus thuringiensis (Bt) và nấm xanh Metarhizium anisopliae; bảo vệ thiên địch tự nhiên.\nBiện pháp hóa học: Khi mật độ cao, phun thuốc trừ sâu vào lúc chiều tối - thời điểm thành trùng hoạt động mạnh.',
    '/images/bongau.jpg',
    '/images/gay_hai/bongau.jpg'
),

-- 3. BoNhay — Bọ nhảy sọc cong
(
    'BoNhay',
    'Bọ Nhảy Sọc Cong',
    'Phyllotreta striolata (Fabricius)',
    'Ánh kim (Chrysomelidae)',
    'Thành trùng dài 2-2,5 mm',
    'Cơ thể hình bầu dục, kích thước nhỏ, cánh cứng màu đen bóng, giữa mỗi cánh có một vạch màu vàng nhạt cong hình củ lạc rất đặc trưng. Chân sau to khỏe.',
    'Chủ yếu trên các cây rau họ Thập tự (cải, su hào, súp lơ). Gây hại mạnh trong các tháng mùa khô, nặng nhất vào khoảng tháng 2-3.',
    'Còn gọi là bọ nhảy sọc cong vỏ lạc. Chân sau to khỏe giúp chúng nhảy xa và bay nhanh khi bị động, đồng thời có tập tính giả chết. Mỗi con cái có thể đẻ tới khoảng 200 trứng dưới đất gần gốc cây; trứng nhỏ, màu vàng nhạt. Ấu trùng màu trắng ngà đến vàng nhạt, hình ống, sống trong đất. Vòng đời kéo dài khoảng 47-107 ngày.',
    'Thành trùng gặm lá và thân tạo thành những lỗ thủng tròn nhỏ; khi mật độ cao làm mất diện tích quang hợp, lá vàng sớm, cây còi cọc - gây hại nặng nhất ở giai đoạn cây con. Ấu trùng sống dưới đất, cắn phá rễ và củ (đối với cải củ), tạo các đường lõm ngoằn ngoèo hoặc lỗ ăn sâu làm củ và rễ dễ thối. Là đối tượng khó phòng trừ, có thể gây mất trắng nếu không xử lý kịp thời.',
    'Biện pháp canh tác: Làm đất kỹ, phơi ải tối thiểu 10-15 ngày trước khi trồng để diệt sâu non và nhộng trong đất; dọn sạch tàn dư vụ trước; luân canh rau họ Thập tự với cây trồng khác, đặc biệt là cây trồng nước.\nBiện pháp cơ giới: Dùng bẫy dính màu vàng và bắt thủ công vào sáng sớm hoặc chiều mát khi bọ hoạt động.\nBiện pháp hóa học: Phun thuốc bảo vệ thực vật luân phiên hoạt chất để tránh kháng thuốc, tập trung vào giai đoạn cây con.',
    '/images/bonhay.jpg',
    '/images/gay_hai/bonhay.jpg'
),

-- 4. BoRay — Bọ rầy / Bù rầy
(
    'BoRay',
    'Bọ Rầy (Bù Rầy)',
    'Holotrichia sauteri (Moser)',
    'Bọ hung (Scarabaeidae), phân họ Melolonthinae',
    'Ấu trùng dài trung bình 3 cm, trứng kích thước 2-3 mm',
    'Thành trùng là bọ cánh cứng màu nâu. Ấu trùng (sùng đất) có thân màu trắng ngà đến trắng xanh hoặc vàng, thường cuộn cong hình chữ C, có ba đôi chân ngực dễ thấy.',
    'Thường sinh sống và sinh sản ở bãi bồi ven sông, vùng đất pha cát nhiều lá mục hoặc ven sườn đồi. Ký chủ gồm nhiều cây trồng như mía, ngô, gừng, khoai lang, bầu bí và hoa màu.',
    'Còn gọi là bù rầy, đuông đất, sùng trắng hay sùng đất. Thành trùng hoạt động mạnh vào các tháng mùa mưa (khoảng tháng 8-10). Con cái dùng chân đào xới đất gần gốc cây rồi đẻ khoảng 15-17 trứng. Giai đoạn ấu trùng kéo dài rất lâu, gần một năm (khoảng 270-300 ngày) mới hóa nhộng.',
    'Giai đoạn gây hại nghiêm trọng nhất là ấu trùng (sùng đất). Chúng đào hang dưới gốc và gặm phá bộ rễ của nhiều loại cây trồng như mía, ngô, gừng, khoai lang, bầu bí và hoa màu, làm cây giảm khả năng hút nước và dinh dưỡng, còi cọc, héo và chết. Do ấu trùng sống sâu trong đất sát vùng rễ và có vòng đời kéo dài, đây là đối tượng khó phòng trừ hơn nhiều so với kiến vương hay đuông dừa, có thể gây hại liên tục qua nhiều vụ.',
    'Biện pháp canh tác: Cày bừa, phơi ải đất kỹ trước khi trồng để diệt trứng và ấu trùng; bón phân hữu cơ đã hoai mục hoàn toàn, tránh dùng phân chuồng tươi làm nơi đẻ trứng; luân canh với cây trồng nước.\nBiện pháp cơ giới: Dùng bẫy đèn bắt thành trùng vào các tháng mùa mưa nhằm hạn chế sinh sản; thu gom, tiêu diệt ấu trùng khi làm đất.\nBiện pháp hóa học: Trộn thuốc bảo vệ thực vật dạng hạt vào đất khi làm đất để tiêu diệt ấu trùng mới nở.',
    '/images/boray.jpg',
    '/images/gay_hai/boray.jpg'
),

-- 5. BoVoiVoi — Bọ vòi voi hại dừa
(
    'BoVoiVoi',
    'Bọ Vòi Voi Hại Dừa',
    'Diocalandra frumenti (Fabricius)',
    'Vòi voi (Curculionidae)',
    'Thành trùng dài 7-8 mm, rộng 1,5 mm',
    'Thành trùng màu nâu đen, trên cánh trước có các đốm vàng đặc trưng ở đầu cánh và cuối cánh, đầu kéo dài thành vòi.',
    'Một trong những loài gây hại phổ biến trên dừa tại các tỉnh Đồng bằng sông Cửu Long, trong đó có Trà Vinh. Thành trùng sợ ánh sáng, thường ẩn ở chỗ tiếp xúc giữa hai trái hoặc gần cuống trái.',
    'Thành trùng hoạt động mạnh vào lúc chiều tối. Trứng được đẻ trên vỏ trái gần cuống hoặc bên trong đường hầm có sẵn; ấu trùng màu vàng nhạt, đục thành đường hầm trong vỏ trái. Vòng đời kéo dài khoảng 2-3 tháng, trải qua bốn giai đoạn: trứng, ấu trùng, nhộng, trưởng thành.',
    'Gây hại trên nhiều bộ phận của cây dừa gồm rễ, thân và đặc biệt là trái. Ấu trùng đục đường hầm trong vỏ trái gần cuống, làm trái chậm phát triển, rụng non hoặc giảm chất lượng; mỗi buồng trái bị hại thường có một vài thành trùng cư trú. Khi tấn công cuống lá và bẹ lá, vết đục làm lá biến vàng và dễ đổ gãy, biểu hiện bắt đầu từ các lá phía ngoài rồi lan dần vào trong.',
    'Biện pháp canh tác: Vệ sinh vườn dừa thông thoáng, thu gom và tiêu hủy trái rụng, bẹ lá khô để hạn chế nơi trú ẩn và đẻ trứng; bón phân, tưới tiêu hợp lý giúp cây khỏe.\nBiện pháp sinh học: Bảo vệ và lợi dụng thiên địch như kiến vàng (Oecophylla smaragdina), ong ký sinh Spathius apicalis và các loài bọ ăn thịt; sử dụng chế phẩm nấm xanh Metarhizium anisopliae.\nBiện pháp hóa học: Khi mật độ cao, dùng thuốc bảo vệ thực vật phù hợp rải gốc hoặc phun lên buồng, cuống trái vào thời điểm thành trùng hoạt động.',
    '/images/bovoivoi.jpg',
    '/images/gay_hai/bovoivoi.jpg'
),

-- 6. CauCau — Câu cấu xanh
(
    'CauCau',
    'Câu Cấu Xanh',
    'Hypomeces squamosus (Fabricius)',
    'Vòi voi (Curculionidae)',
    'Thành trùng dài 10-15 mm, rộng 6-7 mm; ấu trùng dài 15-20 mm',
    'Cơ thể hình bầu dục, toàn thân phủ một lớp vảy bột màu vàng tươi óng ánh khi mới vũ hóa, sau chuyển dần sang xanh nhạt hoặc xám trắng ánh kim; mắt lồi, miệng dạng vòi (mõ) khỏe.',
    'Loài côn trùng đa thực, gây hại trên nhiều loại cây như xoài, cam, quýt, bưởi, ổi, tiêu, sầu riêng và cao su. Phát sinh quanh năm.',
    'Thường sống thành từng cụm 3-4 con, ẩn dưới mặt lá và có tập tính giả chết - buông mình rơi xuống đất khi bị động. Trứng màu trắng ngà, hình bầu dục dài khoảng 1 mm, đẻ rải rác trên mặt đất quanh gốc cây. Ấu trùng màu vàng nhạt, dài 15-20 mm, không chân, sống trong đất.',
    'Là loài đa thực (ăn tạp). Thành trùng gặm khuyết lá non, lộc non, đọt và cả hoa, quả non, làm cây sinh trưởng và phát triển kém. Ấu trùng sống trong đất, cắn phá rễ và gốc cây, làm cây suy yếu từ dưới lên. Do thường bị xem nhẹ trong công tác phòng trừ, loài này dễ gây thiệt hại tích lũy đáng kể qua thời gian.',
    'Biện pháp thủ công: Lợi dụng tập tính giả chết, rung cây hoặc quơ mạnh trên tán vào sáng sớm để thu gom thành trùng rơi xuống, kết hợp bắt tay khi cây ra đọt non.\nBiện pháp canh tác: Cày xới đất quanh gốc để tiêu diệt ấu trùng và nhộng; vệ sinh vườn, làm sạch cỏ dại để giảm nơi trú ẩn.\nBiện pháp hóa học: Khi mật độ cao, phun thuốc trừ sâu vào buổi chiều mát - thời điểm thành trùng hoạt động mạnh.',
    '/images/caucau.jpg',
    '/images/gay_hai/caucau.jpg'
),

-- 7. DuongDua — Đuông dừa
(
    'DuongDua',
    'Đuông Dừa',
    'Rhynchophorus ferrugineus (Olivier)',
    'Vòi voi (Curculionidae)',
    'Thành trùng dài 2-4 cm, ấu trùng dài 40-50 mm, nhộng dài 35 mm',
    'Thành trùng là bọ cánh cứng kích thước lớn, màu nâu đỏ (nâu rỉ sắt), có vòi dài đặc trưng. Ấu trùng màu trắng sữa hoặc vàng nhạt, thân mập tròn không chân.',
    'Ký chủ chính là cây dừa và các cây họ Cau như cau, chà là, cọ.',
    'Còn gọi là sâu đuông. Trứng màu trắng sữa, bóng, dài khoảng 2,5 mm, nở sau 3-4 ngày. Ấu trùng gồm khoảng 13 đốt, miệng cứng rất phát triển, cuối đuôi dẹp. Nhộng ban đầu màu trắng sữa rồi chuyển nâu. Ấu trùng đuông được xem là món đặc sản ở nhiều địa phương miền Tây.',
    'Thường là côn trùng xâm nhập thứ cấp: thành trùng tìm đến đẻ trứng ở những vết thương, vết nứt trên thân hoặc đọt dừa, đặc biệt là các vết do kiến vương tạo ra. Ấu trùng nở ra đục khoét sâu vào thân và đỉnh sinh trưởng, ăn rỗng phần mô mềm bên trong. Triệu chứng ban đầu là vài lỗ nhỏ trên thân hoặc đọt, có mùn gỗ và ít nhựa màu nâu chảy ra; sau đó mô bên trong lên men, bốc mùi hôi, lá khô và rụng dần từ đọt xuống, cuối cùng cây có thể chết. Là dịch hại đặc biệt nguy hiểm, có khả năng gây chết cây hàng loạt, nhất là trên vườn dừa tơ.',
    'Biện pháp phòng ngừa: Phòng trừ kiến vương triệt để vì đây là tác nhân tạo "cửa ngõ" cho đuông xâm nhập; tránh gây tổn thương cơ giới cho thân dừa và xử lý kịp thời các vết thương, vết nứt.\nBiện pháp canh tác: Vệ sinh vườn, dọn bỏ xác cây dừa chết, gốc mục - nơi đuông thường đẻ trứng.\nBiện pháp cơ giới - hóa học: Sử dụng bẫy pheromone dẫn dụ thành trùng; khi phát hiện cây bị hại có thể khoan lỗ tại điểm bị tấn công, bơm thuốc trừ sâu vào rồi bịt kín bằng đất sét.',
    '/images/duongdua.jpg',
    '/images/gay_hai/duongdua.jpg'
),

-- 8. KienDuong — Kiến vương
(
    'KienDuong',
    'Kiến Vương',
    'Oryctes rhinoceros (Linnaeus)',
    'Bọ hung (Scarabaeidae), phân họ Dynastinae',
    'Thành trùng dài 35-50 mm',
    'Thành trùng có thân cứng chắc, màu nâu đen bóng; con đực mang một sừng cong đặc trưng trên đầu (giống sừng tê giác), sừng con đực dài hơn con cái. Ấu trùng hình chữ C, màu trắng đục, đầu màu nâu.',
    'Hiện diện hầu như quanh năm tại các vùng trồng dừa Đồng bằng sông Cửu Long. Ấu trùng thường sống trong các đống phân chuồng, rác mục và xác thực vật đang phân hủy.',
    'Còn gọi là bọ hung tê giác một sừng. Vòng đời gồm bốn giai đoạn: trứng, ấu trùng, nhộng, thành trùng. Hiện diện quanh năm với một số đợt cao điểm gây hại trong năm.',
    'Giai đoạn gây hại chính là thành trùng. Kiến vương đục vào phần mô mềm ở cuối bẹ lá, bó lá ngọn và đỉnh sinh trưởng của cây dừa để ăn các lá non đang phát triển. Khi lá bung ra sẽ mang hình tam giác hoặc bị cắt hình răng lược rất đặc trưng; chúng còn cắn phá bông mo và hoa dừa làm rụng hoa. Cây bị tấn công liên tục sẽ mất sức, kém phát triển, trường hợp nặng có thể chết. Nguy hiểm hơn, vết thương do kiến vương tạo ra chính là điều kiện thuận lợi để đuông dừa và nấm bệnh xâm nhập, gây hại thứ cấp.',
    'Biện pháp canh tác - thủ công: Vệ sinh vườn, dọn sạch và xử lý các đống rác mục, phân chuồng, gốc dừa mục - nơi kiến vương đẻ trứng và ấu trùng phát triển; bắt thủ công thành trùng trong các nách lá, dùng móc sắt kéo bắt khi phát hiện hang.\nBiện pháp hóa học: Rải thuốc hạt vào các nách lá non (5-8 nách lá trên cùng) vào đầu mùa mưa để phòng ngừa; bỏ thuốc hạt vào hang rồi bịt kín khi cây đã bị tấn công.\nBiện pháp sinh học: Bảo vệ thiên địch như kiến vàng; sử dụng bẫy pheromone tập hợp để giảm mật số quần thể.',
    '/images/kienduong.jpg',
    '/images/gay_hai/kienduong.jpg'
);