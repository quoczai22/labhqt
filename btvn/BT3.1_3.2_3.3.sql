-- ===================================================================
-- 1. TẠO CƠ SỞ DỮ LIỆU, TẠO BẢNG VÀ THÊM DỮ LIỆU
-- ===================================================================
CREATE DATABASE ql_sinhvien;
GO
USE ql_sinhvien;
GO

CREATE TABLE lop (
    malop varchar(10),
    tenlop nvarchar(30),
    siso int,
    CONSTRAINT pk_lop PRIMARY KEY (malop)
);

SET DATEFORMAT dmy;
CREATE TABLE sinhvien (
    masv varchar(10),
    hoten nvarchar(30),
    ngsinh date,
    gioitinh nvarchar(4),
    quequan nvarchar(30),
    malop varchar(10),
    diemtb float,
    xeploai nvarchar(10),
    CONSTRAINT pk_sinhvien PRIMARY KEY (masv),
    CONSTRAINT fk_sv_lop FOREIGN KEY (malop) REFERENCES lop (malop)
);

CREATE TABLE monhoc (
    mamh varchar(10),
    tenmh nvarchar(30),
    sotc int,
    batbuoc nvarchar(5),
    CONSTRAINT pk_mh PRIMARY KEY (mamh)
);

CREATE TABLE ketqua (
    masv varchar(10),
    mamh varchar(10),
    hocky nvarchar(10),
    diemthi float,
    CONSTRAINT pk_kq PRIMARY KEY (masv, mamh, hocky),
    CONSTRAINT fk_kq_sinhvien FOREIGN KEY (masv) REFERENCES sinhvien(masv),
    CONSTRAINT fk_kq_mh FOREIGN KEY(mamh) REFERENCES monhoc(mamh)
);
GO

-- Thêm dữ liệu bảng LOP
INSERT INTO lop (malop, tenlop, siso) VALUES 
('CNTT01', N'Công nghệ thông tin 1', 45),
('KTPM02', N'Kỹ thuật phần mềm 2', 40),
('KHMT01', N'Khoa học máy tính 1', 35);

-- Thêm dữ liệu bảng SINHVIEN (Bao gồm dữ liệu test cho Bài 3.2)
SET DATEFORMAT dmy;
INSERT INTO sinhvien (masv, hoten, ngsinh, gioitinh, quequan, malop, diemtb, xeploai) VALUES 
('SV01', N'Nguyễn Văn A', '15/05/2004', N'Nam', N'Hà Nội', 'CNTT01', 8.5, N'Giỏi'),
('SV02', N'Trần Thị B', '20/10/2004', N'Nữ', N'Đà Nẵng', 'CNTT01', 7.2, N'Khá'),
('SV03', N'Lê Hoàng C', '02/02/2003', N'Nam', N'TP.HCM', 'KTPM02', 6.0, N'Trung bình'),
('SV04', N'Phạm Minh D', '12/12/2004', N'Nam', N'Cần Thơ', 'KHMT01', 9.1, N'Xuất sắc'),
('SV001', N'Nguyễn Văn Khánh', '20/03/2002', N'Nam', N'TP.HCM', 'CNTT01', 4.5, NULL),
('SV002', N'Trần Thị Mai', '15/08/1990', N'Nữ', N'Hà Nội', 'CNTT01', 7.8, NULL);

-- Thêm dữ liệu bảng MONHOC
INSERT INTO monhoc (mamh, tenmh, sotc, batbuoc) VALUES 
('CSDL', N'Cơ sở dữ liệu', 3, N'Có'),
('CTDL', N'Cấu trúc dữ liệu', 4, N'Có'),
('TRR', N'Toán rời rạc', 3, N'Không'),
('MH01', N'Mạng máy tính', 3, N'Có');

-- Thêm dữ liệu bảng KETQUA
INSERT INTO ketqua (masv, mamh, hocky, diemthi) VALUES 
('SV01', 'CSDL', 'HK1-2025', 9.0),
('SV01', 'CTDL', 'HK1-2025', 8.0),
('SV02', 'CSDL', 'HK1-2025', 7.5),
('SV03', 'CSDL', 'HK1-2025', 5.5),
('SV04', 'TRR', 'HK2-2025', 9.5),
('SV01', 'MH01', '4', 6.0);
GO

-- ===================================================================
-- BÀI TẬP 3.1: KHAI BÁO BIẾN
-- ===================================================================
DECLARE @hoten VARCHAR(20);
DECLARE @tuoi INT;

SET @hoten = 'Nguyen Van Khanh';
SELECT @tuoi = 20;

SELECT @hoten AS [Họ Tên], @tuoi AS [Tuổi];
PRINT N'Sinh viên: ' + @hoten + N' - Tuổi: ' + CAST(@tuoi AS VARCHAR(3));
GO

-- ===================================================================
-- BÀI TẬP 3.2: CẤU TRÚC ĐIỀU KHIỂN
-- ===================================================================
-- Khai báo và gán giá trị cho SV001
DECLARE @ht1 NVARCHAR(30), @ns1 DATE;
SET @ht1 = (SELECT hoten FROM sinhvien WHERE masv = 'SV001');
SET @ns1 = (SELECT ngsinh FROM sinhvien WHERE masv = 'SV001');
PRINT N'Sinh viên ' + ISNULL(@ht1, '') + N' có ngày sinh là: ' + CONVERT(VARCHAR, @ns1, 103);

-- Khai báo và gán giá trị cho SV002
DECLARE @ht2 NVARCHAR(30), @ns2 DATE;
SELECT @ht2 = hoten, @ns2 = ngsinh FROM sinhvien WHERE masv = 'SV002';
SELECT @ht2 AS HoTen_SV002, @ns2 AS NgSinh_SV002;

-- IF...ELSE kiểm tra điểm trung bình
DECLARE @dtb_sv1 FLOAT;
SELECT @dtb_sv1 = diemtb FROM sinhvien WHERE masv = 'SV001';

IF @dtb_sv1 < 5
    PRINT N'Kết quả học lực SV001: Yếu';
ELSE IF @dtb_sv1 >= 5 AND @dtb_sv1 < 7
    PRINT N'Kết quả học lực SV001: Trung bình';
ELSE IF @dtb_sv1 >= 7 AND @dtb_sv1 < 8
    PRINT N'Kết quả học lực SV001: Khá';
ELSE
    PRINT N'Kết quả học lực SV001: Giỏi';

-- Kiểm tra tuổi sinh viên SV001
DECLARE @tuoi_sv1 INT;
SELECT @tuoi_sv1 = DATEDIFF(YEAR, ngsinh, GETDATE()) FROM sinhvien WHERE masv = 'SV001';

IF @tuoi_sv1 > 30
BEGIN
    SELECT hoten, DATEDIFF(YEAR, ngsinh, GETDATE()) AS Tuoi, diemtb 
    FROM sinhvien 
    WHERE masv = 'SV001';
END
ELSE
BEGIN
    PRINT N'Sinh vien nay duoi 30 tuoi.';
END

-- IF EXISTS kiểm tra danh sách
IF EXISTS (SELECT 1 FROM sinhvien WHERE diemtb > 5)
BEGIN
    SELECT * FROM sinhvien WHERE diemtb > 5;
END
ELSE
BEGIN
    PRINT N'Khong co sinh vien nao tren trung binh.';
END
GO

-- ===================================================================
-- BÀI TẬP 3.3: TRIGGER, PROCEDURE, FUNCTION, CURSOR
-- ===================================================================

-- TRIGGER
-- Câu a: Cập nhật sĩ số lớp (Sửa lỗi trigger chạy trên bảng SINHVIEN thay vì bảng LOP)
CREATE TRIGGER trg_capnhat_siso ON sinhvien
FOR INSERT, UPDATE, DELETE AS
BEGIN 
    SET NOCOUNT ON;
    UPDATE lop
    SET siso = (SELECT COUNT(*) FROM sinhvien WHERE sinhvien.malop = lop.malop)
    WHERE malop IN (SELECT malop FROM inserted UNION SELECT malop FROM deleted);
END;
GO

-- Câu b: Đăng ký tối đa 5 môn (Sửa lỗi loại bỏ COMMIT TRAN)
CREATE TRIGGER tri_dangkymon ON ketqua
FOR INSERT, UPDATE AS 
BEGIN   
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM ketqua kq
        WHERE kq.masv IN (SELECT masv FROM inserted)
        GROUP BY kq.masv, kq.hocky
        HAVING COUNT(kq.mamh) > 5
    )
    BEGIN
        RAISERROR(N'Mỗi sinh viên chỉ được đăng ký tối đa 5 môn trong mỗi học kỳ!', 16, 1);
        ROLLBACK TRAN;
    END
END;
GO

-- Câu c: Đăng ký tối đa 10 tín chỉ bắt buộc (Sửa điều kiện BATBUOC)
CREATE TRIGGER tri_dangkytc ON ketqua
FOR INSERT, UPDATE AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM ketqua kq
        JOIN monhoc mh ON kq.mamh = mh.mamh
        WHERE kq.masv IN (SELECT masv FROM inserted) AND mh.batbuoc = N'Có'
        GROUP BY kq.masv, kq.hocky
        HAVING SUM(mh.sotc) > 10
    )
    BEGIN
        RAISERROR(N'Mỗi sinh viên chỉ được đăng ký tối đa 10 tín chỉ của môn bắt buộc!', 16, 1);
        ROLLBACK TRAN;
    END
END;
GO

-- Câu d: Tự động tính ĐTB và Xếp loại (Sửa trigger chạy trên bảng KETQUA)
CREATE TRIGGER trg_ktra_dtb ON ketqua
FOR INSERT, UPDATE, DELETE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE s
    SET s.diemtb = T.dtb_moi,
        s.xeploai = CASE
            WHEN T.dtb_moi < 5 THEN N'Yếu'
            WHEN T.dtb_moi < 7 THEN N'Trung bình'
            WHEN T.dtb_moi < 8 THEN N'Khá'
            ELSE N'Giỏi'
        END
    FROM sinhvien s
    JOIN (
        SELECT k.masv, 
               SUM(k.diemthi * m.sotc) * 1.0 / SUM(m.sotc) AS dtb_moi
        FROM ketqua k
        JOIN monhoc m ON k.mamh = m.mamh
        WHERE k.masv IN (SELECT masv FROM inserted UNION SELECT masv FROM deleted)
        GROUP BY k.masv
    ) T ON s.masv = T.masv;
END;
GO

-- PROCEDURE
-- Câu a
CREATE PROC themmotlop 
    @tenlop nvarchar(30),
    @malop varchar(10)
AS BEGIN
    IF EXISTS (SELECT 1 FROM lop WHERE malop = @malop)
    BEGIN 
        PRINT N'Mã lớp đã tồn tại'
        RETURN 
    END 
    INSERT INTO lop (malop, tenlop, siso) VALUES (@malop, @tenlop, 0)
    PRINT N'Thêm một lớp mới thành công'
END;
GO

-- Câu b
CREATE PROC them_mot_sv 
    @masv varchar(10),
    @tensv nvarchar(30)
AS BEGIN 
    IF EXISTS (SELECT 1 FROM sinhvien WHERE masv = @masv)
    BEGIN 
        PRINT N'Lỗi mã sinh viên tồn tại'
        RETURN
    END 
    INSERT INTO sinhvien (masv, hoten, diemtb, xeploai) VALUES (@masv, @tensv, NULL, NULL)
END;
GO

-- Câu c (Bạn ghi gộp trong bài nộp, tôi tách ra cho rõ ràng)
CREATE PROC sp_ThemSinhVienLop
    @masv varchar(10),
    @hoten nvarchar(30),
    @malop varchar(10)
AS BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM lop WHERE malop = @malop)
    BEGIN
        PRINT N'Lỗi lớp không tồn tại'
        RETURN
    END
    INSERT INTO sinhvien (masv, hoten, malop) VALUES (@masv, @hoten, @malop)
END;
GO

-- Câu d
CREATE PROC sp_congdiemsv
    @masv varchar(10),
    @mamh varchar(10),
    @hocky nvarchar(10)
AS BEGIN 
    UPDATE ketqua
    SET diemthi = diemthi + 1
    WHERE masv = @masv AND mamh = @mamh AND hocky = @hocky;
    
    UPDATE ketqua
    SET diemthi = 10
    WHERE masv = @masv AND mamh = @mamh AND hocky = @hocky AND diemthi > 10;
    
    PRINT N'Thành công'
END;
GO

-- Câu e
CREATE PROC truyenmasv @masv varchar(10)
AS BEGIN
    SELECT s.hoten, s.ngsinh, s.gioitinh, l.tenlop 
    FROM sinhvien s 
    JOIN lop l ON l.malop = s.malop 
    WHERE s.masv = @masv
END;
GO

-- Câu f
CREATE PROC travedtbxl @masv varchar(10)
AS BEGIN 
    SELECT diemtb, xeploai FROM sinhvien WHERE masv = @masv
END;
GO

-- Câu g 
CREATE PROC dssvlop @malop varchar(10)
AS BEGIN 
    SELECT s.masv, s.hoten FROM sinhvien s JOIN lop l ON l.malop = s.malop WHERE l.malop = @malop
END;
GO

-- Câu h 
CREATE PROC tongsv @mamh varchar(10), @hocky nvarchar(10)
AS BEGIN
    SELECT COUNT(s.masv) FROM sinhvien s JOIN ketqua k ON k.masv = s.masv 
    WHERE k.mamh = @mamh AND k.hocky = @hocky 
END;
GO

-- Câu i
CREATE PROC bathamso 
    @masv varchar(10),
    @mamh varchar(10),
    @hocky nvarchar(10)
AS BEGIN 
    SET NOCOUNT ON;
    DECLARE @diem float;
    SELECT @diem = diemthi 
    FROM ketqua 
    WHERE masv = @masv AND mamh = @mamh AND hocky = @hocky;
    
    IF NOT EXISTS (SELECT 1 FROM ketqua WHERE masv = @masv AND mamh = @mamh AND hocky = @hocky)
        PRINT N'Chưa đăng ký'
    ELSE IF @diem IS NULL
        PRINT N'Chưa có điểm'
    ELSE IF @diem >= 5
        PRINT N'Đạt'
    ELSE
        PRINT N'Không đạt'
END;
GO

-- Câu j
CREATE PROC thutucj
    @masv varchar(10),
    @hocky nvarchar(10)
AS BEGIN 
    DECLARE @dtb float
    SELECT @dtb = AVG(k.diemthi) 
    FROM sinhvien s JOIN ketqua k ON k.masv = s.masv 
    WHERE s.masv = @masv AND k.hocky = @hocky;
    
    IF @dtb >= 8
        SELECT N'Khen thưởng' AS KetQua, @dtb AS DiemTrungBinh;
    ELSE 
        SELECT N'Không khen thưởng' AS KetQua, @dtb AS DiemTrungBinh;
END;
GO

-- FUNCTION
-- Câu a
CREATE FUNCTION fn_sotinchi (@mamh varchar(10))
RETURNS INT 
AS BEGIN 
    DECLARE @sotinchi int;
    SELECT @sotinchi = sotc FROM monhoc WHERE mamh = @mamh;
    RETURN ISNULL(@sotinchi, 0);
END;
GO

-- Câu b (Sửa lỗi dùng SUM sai yêu cầu đề bài)
CREATE FUNCTION fn_tongdtb (@masv varchar(10))
RETURNS FLOAT
AS BEGIN 
    DECLARE @diemtb float
    SELECT @diemtb = diemtb FROM sinhvien WHERE masv = @masv;
    RETURN ISNULL(@diemtb, 0);
END;
GO

-- Câu c
CREATE FUNCTION fn_tongsv (@mamh varchar(10), @hocky nvarchar(10))
RETURNS INT 
AS BEGIN
    DECLARE @tongsv int
    SELECT @tongsv = COUNT(DISTINCT masv) 
    FROM ketqua k JOIN monhoc m ON m.mamh = k.mamh 
    WHERE m.mamh = @mamh AND k.hocky = @hocky;
    RETURN ISNULL(@tongsv, 0);
END;
GO

-- Câu d
CREATE FUNCTION fn_diemthisv (@masv varchar(10) , @mamh varchar(10), @hocky nvarchar(10))
RETURNS FLOAT
AS BEGIN 
    DECLARE @diemthisv float 
    SELECT @diemthisv = diemthi FROM ketqua WHERE masv = @masv AND mamh = @mamh AND hocky = @hocky;
    RETURN ISNULL(@diemthisv, 0);
END;
GO

-- Câu e
CREATE FUNCTION fn_tongsotcsv (@masv varchar(10), @hocky nvarchar(10))
RETURNS INT 
AS BEGIN 
    DECLARE @tongsotcsv int 
    SELECT @tongsotcsv = SUM(sotc) 
    FROM monhoc m JOIN ketqua k ON k.mamh = m.mamh 
    WHERE k.masv = @masv AND k.hocky = @hocky AND k.diemthi >= 5;
    RETURN ISNULL(@tongsotcsv, 0);
END;
GO

-- Câu f (Sửa lỗi cú pháp Inline Function)
CREATE FUNCTION fn_danhsachsv (@malop varchar(10))
RETURNS TABLE
AS RETURN (
    SELECT masv, hoten, ngsinh FROM sinhvien WHERE malop = @malop
);
GO

-- Câu g
CREATE FUNCTION fn_danhsachsvduoitb (@mamh varchar(10), @hocky nvarchar(10))
RETURNS TABLE 
AS RETURN (
    SELECT s.masv, s.hoten, s.ngsinh, l.tenlop 
    FROM sinhvien s 
    JOIN lop l ON l.malop = s.malop 
    JOIN ketqua k ON k.masv = s.masv 
    WHERE k.mamh = @mamh AND k.hocky = @hocky AND k.diemthi < 5
);
GO

-- Câu h
CREATE FUNCTION fn_dssvchuadk (@mamh varchar(10))
RETURNS TABLE 
AS RETURN (
    SELECT s.masv, s.hoten, s.ngsinh 
    FROM sinhvien s 
    WHERE NOT EXISTS (SELECT 1 FROM ketqua k WHERE k.masv = s.masv AND k.mamh = @mamh)
);
GO

-- Câu i
CREATE FUNCTION fn_danhsachmh (@masv varchar(10))
RETURNS TABLE 
AS RETURN (
    SELECT m.mamh, m.tenmh, MAX(k.diemthi) AS DiemCaoNhat  
    FROM monhoc m 
    JOIN ketqua k ON k.mamh = m.mamh 
    WHERE k.masv = @masv 
    GROUP BY m.mamh, m.tenmh
);
GO

-- CURSOR
-- Câu a
DECLARE hien_thi_mon_hoc_ten_tongsv CURSOR FOR 
SELECT mh.MAMH, mh.TENMH, COUNT(kq.MASV) as TONGSV
FROM MONHOC mh JOIN KETQUA kq ON mh.MAMH = kq.MAMH 
GROUP BY mh.MAMH, mh.TENMH;

OPEN hien_thi_mon_hoc_ten_tongsv;
DECLARE @mamh_cur varchar(10), @tenmh_cur nvarchar(40), @tongsv_cur int;

FETCH NEXT FROM hien_thi_mon_hoc_ten_tongsv INTO @mamh_cur, @tenmh_cur, @tongsv_cur;
WHILE @@FETCH_STATUS = 0
BEGIN 
    PRINT @mamh_cur + ' - ' + @tenmh_cur + ' - ' + CAST(@tongsv_cur AS varchar);
    FETCH NEXT FROM hien_thi_mon_hoc_ten_tongsv INTO @mamh_cur, @tenmh_cur, @tongsv_cur;
END
CLOSE hien_thi_mon_hoc_ten_tongsv;
DEALLOCATE hien_thi_mon_hoc_ten_tongsv;
GO

-- Câu b
DECLARE hien_thi_masv_hoten_gioitinh_tuoi CURSOR FOR 
SELECT MASV, HOTEN, GIOITINH, YEAR(GETDATE()) - YEAR(ngsinh) as tuoi
FROM SINHVIEN;

OPEN hien_thi_masv_hoten_gioitinh_tuoi;
DECLARE @msv_cur varchar(10), @hoten_cur nvarchar(30), @gioitinh_cur nvarchar(5), @tuoi_cur int;

FETCH NEXT FROM hien_thi_masv_hoten_gioitinh_tuoi INTO @msv_cur, @hoten_cur, @gioitinh_cur, @tuoi_cur;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @msv_cur + ' - ' + @hoten_cur + ' - ' + @gioitinh_cur + ' - ' + CAST(@tuoi_cur AS varchar(10));
    FETCH NEXT FROM hien_thi_masv_hoten_gioitinh_tuoi INTO @msv_cur, @hoten_cur, @gioitinh_cur, @tuoi_cur;
END
CLOSE hien_thi_masv_hoten_gioitinh_tuoi;
DEALLOCATE hien_thi_masv_hoten_gioitinh_tuoi;
GO

-- Câu c
DECLARE cong_diem CURSOR FOR 
SELECT kq.MASV, mh.MAMH
FROM KETQUA kq JOIN MONHOC mh ON kq.MAMH = mh.MAMH 
WHERE mh.MAMH = 'MH01' AND kq.HOCKY = '4';

OPEN cong_diem;
DECLARE @masinhvien_cur varchar(10), @mamonhoc_cur varchar(10);

FETCH NEXT FROM cong_diem INTO @masinhvien_cur, @mamonhoc_cur;
WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE KETQUA
    SET DIEMTHI = CASE WHEN DIEMTHI + 1 > 10 THEN 10 ELSE DIEMTHI + 1 END
    WHERE MASV = @masinhvien_cur AND MAMH = @mamonhoc_cur AND HOCKY = '4';
    
    FETCH NEXT FROM cong_diem INTO @masinhvien_cur, @mamonhoc_cur;
END
CLOSE cong_diem;
DEALLOCATE cong_diem;
GO

-- Câu d
ALTER TABLE SINHVIEN ADD SOTCTICHLUY int;
GO

DECLARE tongtc CURSOR FOR SELECT MASV FROM SINHVIEN;
OPEN tongtc;
DECLARE @massv_cur VARCHAR(10), @tongtc_cur INT;

FETCH NEXT FROM tongtc INTO @massv_cur;
WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @tongtc_cur = ISNULL(SUM(mh.SOTC), 0)
    FROM KETQUA kq INNER JOIN MONHOC mh ON kq.MAMH = mh.MAMH
    WHERE kq.MASV = @massv_cur AND kq.DIEMTHI >= 5;

    UPDATE SINHVIEN SET SOTCTICHLUY = @tongtc_cur WHERE MASV = @massv_cur;
    
    FETCH NEXT FROM tongtc INTO @massv_cur;
END
CLOSE tongtc;
DEALLOCATE tongtc;
GO
