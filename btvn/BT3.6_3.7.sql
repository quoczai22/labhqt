-- ===================================================================
-- 1. TẠO CƠ SỞ DỮ LIỆU, TẠO BẢNG VÀ THÊM DỮ LIỆU
-- ===================================================================
CREATE DATABASE qldh; 
GO
USE qldh;
GO

CREATE TABLE nhacungcap (
    mancc varchar(10), tenncc nvarchar(30), dchi nvarchar(30), dthoai int,
    CONSTRAINT pk_ncc PRIMARY KEY (mancc)
);

CREATE TABLE mathang (
    mamh varchar(10), tenmh nvarchar(30), dvt nvarchar(10), quycach nvarchar(50), slton int, dg float,
    CONSTRAINT pk_mh PRIMARY KEY(mamh)
);

CREATE TABLE cungung (
    mancc varchar(10), mamh varchar(10),
    CONSTRAINT pk_cu PRIMARY KEY (mancc, mamh),
    CONSTRAINT fk_cu_ncc FOREIGN KEY (mancc) REFERENCES nhacungcap(mancc),
    CONSTRAINT fk_cu_mh FOREIGN KEY (mamh) REFERENCES mathang(mamh)
);

SET DATEFORMAT dmy;
CREATE TABLE dathang (
    sodh varchar(10), ngaydh date, mancc varchar(10), sl_mathang int, ghichu nvarchar(30), thanhtien float,
    CONSTRAINT pk_dh PRIMARY KEY (sodh),
    CONSTRAINT fk_dh_ncc FOREIGN KEY(mancc) REFERENCES nhacungcap(mancc)
);

CREATE TABLE ctdh (
    sodh varchar(10), mamh varchar(10), sldat int, dg int,
    CONSTRAINT pk_ctdh PRIMARY KEY (sodh, mamh),
    CONSTRAINT fk_ctdh_dh FOREIGN KEY (sodh) REFERENCES dathang(sodh),
    CONSTRAINT fk_ctdh_mh FOREIGN KEY (mamh) REFERENCES mathang(mamh)
);

CREATE TABLE giaohang (
    sogh varchar(10), ngaygh date, sodh varchar(10),
    CONSTRAINT pk_gh PRIMARY KEY(sogh),
    CONSTRAINT fk_gh_dh FOREIGN KEY (sodh) REFERENCES dathang(sodh)
);

CREATE TABLE ctgh (
    sogh varchar(10), mamh varchar(10), slgiao int,
    CONSTRAINT pk_ctgh PRIMARY KEY(sogh, mamh),
    CONSTRAINT fk_ctgh_gh FOREIGN KEY(sogh) REFERENCES giaohang(sogh),
    CONSTRAINT fk_ctgh_mh FOREIGN KEY(mamh) REFERENCES mathang(mamh)
);
GO

-- Thêm dữ liệu
INSERT INTO nhacungcap VALUES
('NCC01', N'Công ty Minh Anh', N'Quận 1, TP.HCM', 0901234567),
('NCC02', N'Tổng kho Hòa Phát', N'Dĩ An, Bình Dương', 0283344556),
('NCC03', N'Điện máy Xanh', N'Quận Tân Phú, TP.HCM', 0988776655);

INSERT INTO mathang VALUES
('MH01', N'Thép cuộn', N'Tấn', N'Thùng', 100, 15000000),
('MH02', N'Xi măng', N'Bao', N'Thùng', 500, 90000),
('MH03', N'Gạch men', N'Thùng', N'Hộp', 200, 250000),
('MH04', N'Ống nhựa', N'Cây', N'Chai', 150, 45000);

INSERT INTO cungung VALUES
('NCC01', 'MH01'),
('NCC01', 'MH02'),
('NCC02', 'MH01'),
('NCC02', 'MH03'),
('NCC03', 'MH04');

INSERT INTO dathang VALUES
('DH01', '10/04/2026', 'NCC01', 2, N'Giao gấp trong tuần', 0),
('DH02', '12/04/2026', 'NCC02', 1, N'Hàng đặt theo dự án', 0),
('DH03', '15/04/2026', 'NCC03', 1, NULL, 0);

INSERT INTO ctdh VALUES
('DH01', 'MH01', 5, 15000000),
('DH01', 'MH02', 50, 90000),
('DH02', 'MH03', 100, 250000),
('DH03', 'MH04', 30, 45000);

INSERT INTO giaohang VALUES
('GH01', '13/04/2026', 'DH01'),
('GH02', '16/04/2026', 'DH02'),
('GH03', '18/04/2026', 'DH03');

INSERT INTO ctgh VALUES
('GH01', 'MH01', 5),
('GH01', 'MH02', 30), 
('GH02', 'MH03', 100),
('GH03', 'MH04', 30);
GO

-- ===================================================================
-- 2. TRIGGER, PROCEDURE, FUNCTION, CURSOR
-- ===================================================================

-- TRIGGER
-- Câu a
CREATE TRIGGER kt_slton ON mathang
FOR INSERT, UPDATE AS 
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE slton <= 0)
    BEGIN 
        RAISERROR(N'Lỗi: Số lượng tồn phải lớn hơn 0', 16, 1);
        ROLLBACK TRAN;
    END
END;
GO

-- Câu b
CREATE TRIGGER kt_dvt ON mathang
FOR INSERT, UPDATE AS 
BEGIN 
    IF EXISTS(SELECT 1 FROM inserted WHERE dvt NOT IN (N'lốc', N'chai', N'thùng', N'túi', N'bao', N'bình', N'hộp', N'hũ', N'gói', N'kg', N'Tấn', N'Cây'))
    BEGIN
        RAISERROR(N'Lỗi đơn vị tính', 16, 1);
        ROLLBACK TRAN;
    END
END;
GO

-- Câu c
CREATE TRIGGER kt_quycach ON mathang
FOR INSERT, UPDATE AS 
BEGIN
    IF EXISTS(SELECT 1 FROM inserted WHERE quycach NOT IN (N'chai', N'gói', N'thùng', N'hộp', N'Hộp', N'Chai', N'Thùng'))
    BEGIN
        RAISERROR(N'Lỗi quy cách', 16, 1);
        ROLLBACK TRAN;
    END
END;
GO

-- Câu d
CREATE TRIGGER kt_dathang ON dathang
FOR INSERT, UPDATE AS 
BEGIN
    IF EXISTS(SELECT 1 FROM inserted WHERE sl_mathang > 3)
    BEGIN 
        RAISERROR(N'Lỗi: Số lượng mặt hàng đặt không được vượt quá 3', 16, 1);
        ROLLBACK TRAN;
    END
END;
GO

-- Câu e
CREATE TRIGGER kt_gh ON giaohang
FOR INSERT, UPDATE AS 
BEGIN 
    IF EXISTS (
        SELECT 1 FROM inserted i 
        JOIN dathang dh ON i.sodh = dh.sodh 
        WHERE DATEDIFF(DAY, dh.ngaydh, i.ngaygh) > 7
    )
    BEGIN 
        RAISERROR(N'Lỗi: Ngày giao hàng không được quá 7 ngày kể từ ngày đặt hàng!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Câu f
CREATE TRIGGER kt_dh ON dathang
FOR INSERT, UPDATE AS 
BEGIN 
    IF EXISTS (SELECT 1 FROM inserted i LEFT JOIN nhacungcap ncc ON i.mancc = ncc.mancc WHERE ncc.mancc IS NULL)
    BEGIN
        RAISERROR(N'Lỗi: Mã nhà cung cấp không tồn tại!', 16, 1);
        ROLLBACK TRAN;
    END 
END;
GO

-- Câu g
CREATE TRIGGER kt_ghcodh ON giaohang
FOR INSERT, UPDATE AS 
BEGIN
    IF EXISTS (SELECT 1 FROM inserted i LEFT JOIN dathang dh ON dh.sodh = i.sodh WHERE dh.sodh IS NULL)
    BEGIN
        RAISERROR(N'Lỗi: Số đặt hàng không tồn tại!', 16, 1);
        ROLLBACK TRAN;
    END
END;
GO

-- Câu h (Sửa lỗi biến subquery trả về nhiều kết quả)
CREATE TRIGGER kt_tongslgh ON ctgh
FOR INSERT, UPDATE AS 
BEGIN 
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN giaohang gh ON i.sogh = gh.sogh
        JOIN ctdh ct ON gh.sodh = ct.sodh AND i.mamh = ct.mamh
        WHERE (
            SELECT SUM(ctg.slgiao) 
            FROM ctgh ctg 
            JOIN giaohang g ON ctg.sogh = g.sogh 
            WHERE g.sodh = gh.sodh AND ctg.mamh = i.mamh
        ) > ct.sldat
    )
    BEGIN
        RAISERROR(N'Lỗi: Tổng số lượng giao vượt quá số lượng đặt hàng của mặt hàng này!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Câu i
CREATE TRIGGER kt_soluong_mathang_no_var ON ctdh
FOR INSERT, UPDATE, DELETE AS 
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM dathang dh
        WHERE dh.sodh IN (SELECT sodh FROM inserted UNION SELECT sodh FROM deleted)
          AND dh.sl_mathang <> (SELECT COUNT(*) FROM ctdh WHERE ctdh.sodh = dh.sodh)
    )
    BEGIN
        RAISERROR(N'Lỗi: Số lượng mặt hàng khai báo trong Đơn hàng không khớp với số dòng chi tiết thực tế!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Câu j (Sửa logic cộng sai thành trừ kho)
CREATE TRIGGER up_slton ON ctgh
FOR INSERT AS 
BEGIN
    SET NOCOUNT ON;
    UPDATE mathang
    SET slton = slton - i.slgiao
    FROM mathang mh JOIN inserted i ON mh.mamh = i.mamh;
END;
GO

-- Câu k
CREATE TRIGGER cap_nhat_thanh_tien ON CTDH
FOR INSERT, UPDATE, DELETE AS
BEGIN
    UPDATE DATHANG
    SET THANHTIEN = (SELECT SUM(SLDAT * DG) FROM CTDH WHERE SODH = DATHANG.SODH)
    WHERE SODH IN (SELECT SODH FROM inserted UNION SELECT SODH FROM deleted);
END;
GO

-- PROCEDURE
-- Câu a
CREATE PROC pro_tenvadc @sodh varchar(10)
AS BEGIN 
    SELECT tenncc, dchi FROM nhacungcap ncc JOIN dathang dh ON dh.mancc = ncc.mancc WHERE dh.sodh = @sodh;
END;
GO

-- Câu b
CREATE PROC pro_dsdh @mancc varchar(10)
AS BEGIN 
    SELECT * FROM dathang dh WHERE dh.mancc = @mancc;
END;
GO

-- Câu c
CREATE PROC pro_thanhtien @sogh varchar(10)
AS BEGIN
    SELECT thanhtien FROM dathang dh JOIN giaohang gh ON gh.sodh = dh.sodh WHERE gh.sogh = @sogh;
END;
GO

-- Câu d
CREATE PROC pro_dsmh @mancc varchar(10)
AS BEGIN
    SELECT mh.* FROM mathang mh JOIN cungung cu ON cu.mamh = mh.mamh WHERE cu.mancc = @mancc;
END;
GO

-- FUNCTION
-- Câu a (Sửa lỗi Inline Function)
CREATE FUNCTION fun_mh ()
RETURNS TABLE
AS RETURN (
    SELECT DISTINCT mh.mamh, dh.sl_mathang, dh.thanhtien
    FROM mathang mh
    JOIN cungung cu ON cu.mamh = mh.mamh 
    JOIN dathang dh ON dh.mancc = cu.mancc
);
GO

-- Câu b
CREATE FUNCTION fun_dsdh(@thang int ,@nam int)
RETURNS TABLE 
AS RETURN (
    SELECT * FROM dathang WHERE MONTH(ngaydh) = @thang AND YEAR(ngaydh) = @nam
);
GO

-- Câu c
CREATE FUNCTION fun_ds(@mamh varchar(10))
RETURNS @ds TABLE (mamh varchar(10), tenmh nvarchar(30), sl_dagiao int, sl_chuagiao int)
AS BEGIN
    INSERT INTO @ds
    SELECT 
        ctdh.MAMH, 
        mh.TENMH, 
        ISNULL((SELECT SUM(ctg.SLGIAO) FROM CTGH ctg JOIN GIAOHANG gh ON ctg.SOGH = gh.SOGH WHERE gh.SODH = ctdh.SODH AND ctg.MAMH = ctdh.MAMH), 0),
        ctdh.SLDAT - ISNULL((SELECT SUM(ctg.SLGIAO) FROM CTGH ctg JOIN GIAOHANG gh ON ctg.SOGH = gh.SOGH WHERE gh.SODH = ctdh.SODH AND ctg.MAMH = ctdh.MAMH), 0)
    FROM CTDH ctdh JOIN MATHANG mh ON ctdh.MAMH = mh.MAMH
    WHERE mh.mamh = @mamh;
    RETURN;
END;
GO

-- Câu d
CREATE FUNCTION fun_bangthongke (@ngaybatdau date, @ngayketthuc date)
RETURNS TABLE
AS RETURN (
    SELECT mh.mamh, mh.tenmh, SUM(ct.sldat) AS tong_sl_dat
    FROM mathang mh
    JOIN ctdh ct ON mh.mamh = ct.mamh
    JOIN dathang dh ON ct.sodh = dh.sodh
    WHERE dh.ngaydh BETWEEN @ngaybatdau AND @ngayketthuc
    GROUP BY mh.mamh, mh.tenmh
);
GO

-- CURSOR
-- Câu a
ALTER TABLE giaohang ADD thanhtien money;
GO

CREATE PROC sp_cap_nhat_thanhtien_gh AS
BEGIN
    DECLARE cur_cau_4a CURSOR FOR SELECT sogh FROM giaohang;
    OPEN cur_cau_4a;
    
    DECLARE @sogh_cur varchar(10), @thanhtien_cur money;

    FETCH NEXT FROM cur_cau_4a INTO @sogh_cur;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @thanhtien_cur = SUM(ctg.slgiao * ctd.dg)
        FROM ctgh ctg
        JOIN giaohang gh ON ctg.sogh = gh.sogh
        JOIN ctdh ctd ON gh.sodh = ctd.sodh AND ctg.mamh = ctd.mamh
        WHERE ctg.sogh = @sogh_cur;

        UPDATE giaohang SET thanhtien = ISNULL(@thanhtien_cur, 0) WHERE sogh = @sogh_cur;

        FETCH NEXT FROM cur_cau_4a INTO @sogh_cur;
    END  
    CLOSE cur_cau_4a;
    DEALLOCATE cur_cau_4a;
END;
GO

-- Câu b
CREATE PROC sp_ds_mh_nhap_ncc @mancc varchar(10) AS
BEGIN
    DECLARE cur_cau_4b CURSOR FOR 
    SELECT mh.MAMH, mh.TENMH, SUM(ctg.SLGIAO)
    FROM MATHANG mh JOIN CTGH ctg ON mh.MAMH = ctg.MAMH 
    JOIN GIAOHANG gh ON ctg.SOGH = gh.SOGH 
    JOIN DATHANG dh ON gh.SODH = dh.SODH
    WHERE dh.MANCC = @mancc
    GROUP BY mh.MAMH, mh.TENMH;
    
    OPEN cur_cau_4b;    
    DECLARE @mamh_cur varchar(10), @tenmh_cur nvarchar(50), @tongnhap_cur int;
    
    FETCH NEXT FROM cur_cau_4b INTO @mamh_cur, @tenmh_cur, @tongnhap_cur;    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT @mamh_cur + ' - ' + @tenmh_cur + ' - ' + CAST(@tongnhap_cur AS varchar(20));
        FETCH NEXT FROM cur_cau_4b INTO @mamh_cur, @tenmh_cur, @tongnhap_cur;
    END    
    CLOSE cur_cau_4b;
    DEALLOCATE cur_cau_4b;
END;
GO

-- ===================================================================
-- BÀI TẬP 3.7: HỆ THỐNG ĐẶT PHÒNG KHÁCH SẠN (CAPSTONE PROJECT)
-- ===================================================================
CREATE DATABASE ql_khachsan;
GO
USE ql_khachsan;
GO

-- 1. TẠO BẢNG & THÊM DỮ LIỆU
CREATE TABLE Phong (
    MaPhong varchar(10), LoaiPhong nvarchar(30), TrangThai nvarchar(20),
    CONSTRAINT pk_phong PRIMARY KEY (MaPhong)
);

CREATE TABLE PhieuDat (
    MaPhieu varchar(10), MaPhong varchar(10), NgayDat Date,
    CONSTRAINT pk_phieu PRIMARY KEY (MaPhieu),
    CONSTRAINT fk_phieu_phong FOREIGN KEY (MaPhong) REFERENCES Phong(MaPhong)
);

CREATE TABLE HoaDon (
    MaHD varchar(10), MaPhieu varchar(10), ThanhTien float, NgayThanhToan date,
    CONSTRAINT pk_hd_ks PRIMARY KEY (MaHD),
    CONSTRAINT fk_hd_phieu FOREIGN KEY (MaPhieu) REFERENCES PhieuDat(MaPhieu)
);
GO

INSERT INTO Phong VALUES ('P101', N'Phòng Đơn', N'Trống'), ('P102', N'Phòng Đôi', N'Trống');
INSERT INTO PhieuDat VALUES ('PD01', 'P101', '01/05/2026');
INSERT INTO HoaDon VALUES ('HD01', 'PD01', 500000, '02/05/2026');
GO

-- 2. CÀI ĐẶT CHỨC NĂNG (TRIGGER, FUNCTION)
-- Yêu cầu 1: Trigger tự động cập nhật trạng thái phòng khi có phiếu đặt mới
CREATE TRIGGER trg_DatPhong ON PhieuDat
FOR INSERT AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Phong SET TrangThai = N'Đã thuê'
    WHERE MaPhong IN (SELECT MaPhong FROM inserted);
END;
GO

-- Yêu cầu 2: Hàm thống kê doanh thu theo tháng
CREATE FUNCTION fn_DoanhThuThang (@thang INT, @nam INT) 
RETURNS FLOAT AS
BEGIN
    DECLARE @tongtien FLOAT;
    SELECT @tongtien = SUM(ThanhTien) 
    FROM HoaDon 
    WHERE MONTH(NgayThanhToan) = @thang AND YEAR(NgayThanhToan) = @nam;
    RETURN ISNULL(@tongtien, 0);
END;
GO