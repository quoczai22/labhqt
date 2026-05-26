-- ===================================================================
-- 1. TẠO CƠ SỞ DỮ LIỆU, TẠO BẢNG VÀ THÊM DỮ LIỆU
-- ===================================================================
CREATE DATABASE qlbh;
GO
USE qlbh;
GO

CREATE TABLE khachhg (
    makh varchar(10),
    tenkh nvarchar(30),
    dc nvarchar(30),
    dt varchar(10),
    CONSTRAINT pk_khachhg PRIMARY KEY (makh)
);

CREATE TABLE nhasx (
    mansx varchar(10),
    tennxs nvarchar(30),
    dc nvarchar(30),
    dt varchar(10),
    CONSTRAINT pk_nxs PRIMARY KEY (mansx)
);

CREATE TABLE ncc (
    mancc varchar(10),
    tenncc nvarchar(30),
    dc nvarchar(30),
    dt varchar(10),
    CONSTRAINT pk_ncc PRIMARY KEY (mancc)
);

CREATE TABLE hang (
    mahg varchar(10),
    tenhg nvarchar(30),
    dvt int,
    soluongton int,
    mansx varchar(10),
    tinhtrang nvarchar(10),
    CONSTRAINT pk_hg PRIMARY KEY (mahg),
    CONSTRAINT fk_hg_nxs FOREIGN KEY (mansx) REFERENCES nhasx (mansx)
);

SET DATEFORMAT dmy;
CREATE TABLE phieunhap (
    mapn varchar(10),
    ngaynhap date,
    mancc varchar(10),
    tiennhap int,
    CONSTRAINT pk_pn PRIMARY KEY (mapn),
    CONSTRAINT fk_pn_ncc FOREIGN KEY (mancc) REFERENCES ncc (mancc)
);

CREATE TABLE chitietpn (
    mapn varchar(10),
    mahg varchar(10),
    soluong int,
    gianhap float,
    thanhtien float,
    CONSTRAINT pk_ctpn PRIMARY KEY (mapn, mahg),
    CONSTRAINT fk_ctpn_pn FOREIGN KEY (mapn) REFERENCES phieunhap(mapn),
    CONSTRAINT fk_ctpn_hg FOREIGN KEY (mahg) REFERENCES hang(mahg)
);

CREATE TABLE hoadon (
    mahd varchar(10),
    ngayban date,
    makh varchar(10),
    tienban int,
    giamgia float,
    thanhtoan nvarchar(30),
    CONSTRAINT pk_hd PRIMARY KEY (mahd),
    CONSTRAINT fk_hd_kh FOREIGN KEY (makh) REFERENCES khachhg(makh)
);

CREATE TABLE chitiethd (
    mahd varchar(10),
    mahg varchar(10),
    soluong int,
    giaban float,
    thanhtien float,
    CONSTRAINT pk_cthd PRIMARY KEY (mahd, mahg),
    CONSTRAINT fk_cthd_hd FOREIGN KEY (mahd) REFERENCES hoadon(mahd),
    CONSTRAINT fk_cthd_hg FOREIGN KEY (mahg) REFERENCES hang(mahg)
);

CREATE TABLE donggia (
    mahg varchar(10),
    ngaycn date,
    gia float,
    CONSTRAINT pk_dg PRIMARY KEY (mahg, ngaycn),
    CONSTRAINT fk_dg_hg FOREIGN KEY (mahg) REFERENCES hang (mahg)
);
GO

-- Thêm dữ liệu
INSERT INTO khachhg VALUES
('KH01', N'Nguyễn Văn A', N'Quận 1, TP.HCM', '0901234567'),
('KH02', N'Trần Thị B', N'Quận 3, TP.HCM', '0902345678'),
('KH03', N'Lê Văn C', N'Hà Đông, Hà Nội', '0903456789');

INSERT INTO nhasx VALUES
('NSX01', N'Samsung', N'Hàn Quốc', '028111222'),
('NSX02', N'Apple', N'Mỹ', '028333444'),
('NSX03', N'Sony', N'Nhật Bản', '028555666');

INSERT INTO ncc VALUES
('NCC01', N'Thế Giới Di Động', N'TP.HCM', '18001060'),
('NCC02', N'FPT Shop', N'Hà Nội', '18006601');

INSERT INTO hang VALUES
('HG01', N'Galaxy S24', 1, 50, 'NSX01', N'Mới'),
('HG02', N'iPhone 15', 1, 30, 'NSX02', N'Mới'),
('HG03', N'Tai nghe Sony', 1, 100, 'NSX03', N'Mới'),
('HG04', N'iPad Pro', 1, 10, 'NSX02', N'Cũ');

INSERT INTO donggia VALUES
('HG01', '01/01/2026', 25000000),
('HG02', '01/01/2026', 30000000),
('HG03', '01/01/2026', 7500000);

INSERT INTO phieunhap VALUES
('PN01', '10/01/2026', 'NCC01', 500000000),
('PN02', '15/02/2026', 'NCC02', 300000000);

INSERT INTO hoadon VALUES
('HD01', '01/03/2026', 'KH01', 0, 0, '0'),
('HD02', '02/03/2026', 'KH02', 0, 0, '0'),
('HD03', '05/03/2026', 'KH01', 0, 0, '0');

INSERT INTO chitiethd VALUES
('HD01', 'HG01', 1, 0, 0),
('HD02', 'HG02', 1, 0, 0),
('HD02', 'HG03', 2, 0, 0),
('HD03', 'HG03', 2, 0, 0);
GO

-- ===================================================================
-- 2. TRIGGER, PROCEDURE, FUNCTION, CURSOR
-- ===================================================================

-- TRIGGER
-- Câu a
CREATE TRIGGER kt_pn_ngaynhap ON phieunhap 
FOR INSERT AS 
BEGIN 
    IF EXISTS (SELECT 1 FROM inserted WHERE CAST(ngaynhap AS date) <> CAST(GETDATE() AS date))
    BEGIN 
        RAISERROR(N'Lỗi: Ngày lập phiếu phải là ngày hiện tại', 16, 1);
        ROLLBACK TRAN;
    END
END;
GO

-- Câu b
CREATE TRIGGER kt_ngayban ON hoadon
FOR INSERT AS 
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE CAST(ngayban AS date) <> CAST(GETDATE() AS date))
    BEGIN 
        RAISERROR(N'Lỗi: Ngày lập hóa đơn phải là ngày hiện tại', 16, 1);
        ROLLBACK TRAN;
    END
END;
GO

-- Câu c: Khống chế nhập hàng
CREATE TRIGGER kt_nhaphang ON chitietpn
FOR INSERT AS 
BEGIN 
    SET NOCOUNT ON;
    UPDATE c
    SET c.thanhtien = i.soluong * i.gianhap
    FROM chitietpn c JOIN inserted i ON i.mapn = c.mapn AND i.mahg = c.mahg;

    UPDATE pn
    SET pn.tiennhap = (SELECT SUM(thanhtien) FROM chitietpn WHERE mapn = pn.mapn)
    FROM phieunhap pn JOIN inserted i ON i.mapn = pn.mapn;

    UPDATE hg
    SET hg.soluongton = hg.soluongton + i.soluong 
    FROM hang hg JOIN inserted i ON i.mahg = hg.mahg;
END;
GO

-- Câu c (phần 2): Khống chế bán hàng (Sửa lỗi trigger đệ quy và ép kiểu)
CREATE TRIGGER kt_banhang ON chitiethd
FOR INSERT AS 
BEGIN 
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM hang hg JOIN inserted i ON i.mahg = hg.mahg WHERE i.soluong > hg.soluongton)
    BEGIN 
        RAISERROR(N'Không đủ hàng để bán', 16, 1);
        ROLLBACK TRAN;
        RETURN;
    END

    UPDATE cthd
    SET cthd.giaban = dg.gia,
        cthd.thanhtien = i.soluong * dg.gia
    FROM chitiethd cthd
    JOIN inserted i ON cthd.mahd = i.mahd AND cthd.mahg = i.mahg
    JOIN donggia dg ON i.mahg = dg.mahg
    WHERE dg.ngaycn = (SELECT MAX(ngaycn) FROM donggia WHERE mahg = i.mahg);

    UPDATE hd
    SET hd.tienban = (SELECT SUM(thanhtien) FROM chitiethd WHERE mahd = hd.mahd)
    FROM hoadon hd JOIN inserted i ON hd.mahd = i.mahd;

    UPDATE hd
    SET hd.giamgia = CASE 
                        WHEN hd.tienban >= 500000 THEN 0.1
                        WHEN hd.tienban >= 200000 THEN 0.05
                        ELSE 0
                     END
    FROM hoadon hd JOIN inserted i ON hd.mahd = i.mahd;

    UPDATE hd
    SET hd.thanhtoan = CAST((hd.tienban - (hd.tienban * hd.giamgia)) AS NVARCHAR(30))
    FROM hoadon hd JOIN inserted i ON hd.mahd = i.mahd;

    UPDATE hg
    SET hg.soluongton = hg.soluongton - i.soluong,
        hg.tinhtrang = CASE WHEN (hg.soluongton - i.soluong) = 0 THEN N'het hang' ELSE hg.tinhtrang END
    FROM hang hg JOIN inserted i ON hg.mahg = i.mahg;
END;
GO

-- PROCEDURE
-- Câu a
CREATE PROC hd_khach @makh varchar(10)
AS BEGIN
    SELECT * FROM hoadon WHERE makh = @makh;
END;
GO

-- Câu b
CREATE PROC ngaylaphd @mahd varchar(10)
AS BEGIN 
    SELECT ngayban, tienban FROM hoadon WHERE mahd = @mahd;
END;
GO

-- Câu c
CREATE PROC pro_hang @mahg varchar(10)
AS BEGIN
    SELECT hg.tenhg, hg.soluongton, nsx.tennxs 
    FROM hang hg JOIN nhasx nsx ON hg.mansx = nsx.mansx 
    WHERE hg.mahg = @mahg;
END;
GO

-- Câu d
CREATE PROC pro_dshg @mansx varchar(10)
AS BEGIN
    SELECT mahg, tenhg, dvt FROM hang WHERE mansx = @mansx;
END;
GO

-- Câu e
CREATE PROC pro_kh_hd @mahd varchar(10)
AS BEGIN 
    SELECT k.*, hd.* FROM khachhg k JOIN hoadon hd ON hd.makh = k.makh WHERE hd.mahd = @mahd;
END;
GO

-- Câu f (Sửa lỗi subquery khi khách có nhiều hóa đơn)
CREATE PROC pro_ghichukh @makh varchar(10)
AS BEGIN 
    SET NOCOUNT ON;
    DECLARE @doanhso float;
    
    SELECT @doanhso = SUM(TRY_CAST(hd.thanhtoan AS FLOAT))
    FROM hoadon hd
    WHERE hd.makh = @makh;

    IF @doanhso >= 10000000
        SELECT 'VIP' AS XepLoaiKH;
    ELSE IF @doanhso >= 6000000 AND @doanhso < 10000000
        SELECT N'KH thành viên' AS XepLoaiKH;
    ELSE 
        SELECT N'KH thân thiết' AS XepLoaiKH;
END;
GO

-- Câu g 
CREATE PROC sp_tra_ve_dongia_moinhat @mahg varchar(10)
AS BEGIN
    SELECT gia
    FROM donggia
    WHERE MAHG = @mahg AND ngaycn = (SELECT MAX(ngaycn) FROM donggia WHERE mahg = @mahg);
END;
GO

-- FUNCTION
-- Câu a (Sửa lỗi COUNT)
CREATE FUNCTION fun_slhd (@makh varchar(10))
RETURNS INT 
AS BEGIN
    DECLARE @soluong int; 
    SELECT @soluong = COUNT(DISTINCT mahd) FROM hoadon WHERE makh = @makh;
    RETURN ISNULL(@soluong, 0);
END;
GO

-- Câu b
CREATE FUNCTION fun_gthd(@mahd varchar(10))
RETURNS INT
AS BEGIN 
    DECLARE @giatrihd int;
    SELECT @giatrihd = tienban FROM hoadon WHERE mahd = @mahd;
    RETURN ISNULL(@giatrihd, 0);
END;
GO

-- Câu c
CREATE FUNCTION fun_tongsoban(@mahg varchar(10), @ngayban date)
RETURNS INT
AS BEGIN 
    DECLARE @tongslban int;
    SELECT @tongslban = SUM(c.soluong) 
    FROM hoadon hd JOIN chitiethd c ON c.mahd = hd.mahd 
    WHERE hd.ngayban = @ngayban AND c.mahg = @mahg;
    RETURN ISNULL(@tongslban, 0);
END;
GO

-- Câu d
CREATE FUNCTION fun_dskh(@makh varchar(10))
RETURNS FLOAT
AS BEGIN 
    DECLARE @dskh float; 
    SELECT @dskh = SUM(TRY_CAST(thanhtoan AS FLOAT)) FROM hoadon WHERE makh = @makh;
    RETURN ISNULL(@dskh, 0);
END;
GO

-- Câu e
CREATE FUNCTION fun_dsmathang(@mancc varchar(10))
RETURNS TABLE 
AS RETURN (
    SELECT hg.mahg, hg.tenhg, SUM(ctpn.soluong) AS tongsoluong 
    FROM hang hg 
    JOIN chitietpn ctpn ON ctpn.mahg = hg.mahg 
    JOIN phieunhap pn ON pn.mapn = ctpn.mapn 
    WHERE pn.mancc = @mancc 
    GROUP BY hg.mahg, hg.tenhg 
);
GO

-- Câu f
CREATE FUNCTION fun_dscacmathang(@mahd varchar(10))
RETURNS TABLE
AS RETURN (
    SELECT hg.mahg, hg.tenhg, cthd.soluong, cthd.giaban, cthd.thanhtien 
    FROM hang hg 
    JOIN chitiethd cthd ON cthd.mahg = hg.mahg 
    WHERE cthd.mahd = @mahd
);
GO 

-- Câu g
CREATE FUNCTION fun_thongtin_chitiet (@mahg varchar(10))
RETURNS TABLE 
AS RETURN (
    SELECT 
        hg.mahg, 
        hg.tenhg,
        (SELECT SUM(soluong) FROM chitietpn WHERE mahg = hg.mahg) as soluongnhap,
        (SELECT SUM(soluong) FROM chitiethd WHERE mahg = hg.mahg) as soluongxuat,
        hg.soluongton as soluongconlai
    FROM hang hg
    WHERE hg.mahg = @mahg
);
GO

-- CURSOR 
-- Câu a
CREATE PROC sp_hien_thi_makh_tenkh_doanhso AS
BEGIN
    DECLARE cur_cau_a CURSOR FOR 
        SELECT kh.makh, kh.tenkh, SUM(TRY_CAST(hd.thanhtoan AS FLOAT)) as doanhso
        FROM khachhg kh JOIN hoadon hd ON kh.makh = hd.makh
        GROUP BY kh.makh, kh.tenkh;

    OPEN cur_cau_a;
    DECLARE @makh_cur varchar(10), @tenkh_cur nvarchar(50), @doanhso_cur float;
    
    PRINT N'Mã KH | Tên Khách Hàng | Doanh Số';
    PRINT '-----------------------------------';

    FETCH NEXT FROM cur_cau_a INTO @makh_cur, @tenkh_cur, @doanhso_cur;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT @makh_cur + ' - ' + @tenkh_cur + ' - ' + CAST(ISNULL(@doanhso_cur, 0) AS varchar(20));
        FETCH NEXT FROM cur_cau_a INTO @makh_cur, @tenkh_cur, @doanhso_cur;
    END
    CLOSE cur_cau_a;
    DEALLOCATE cur_cau_a;
END;
GO

-- Câu b
CREATE PROC sp_thong_ke_nhap_xuat @tungay date, @denngay date AS
BEGIN
    DECLARE cur_cau_b CURSOR FOR 
        SELECT 
            hg.mahg, hg.tenhg, 
            (SELECT SUM(ctpn.soluong) FROM chitietpn ctpn JOIN phieunhap pn ON ctpn.mapn = pn.mapn WHERE ctpn.mahg = hg.mahg AND pn.ngaynhap BETWEEN @tungay AND @denngay),
            (SELECT SUM(cthd.soluong) FROM chitiethd cthd JOIN hoadon hd ON cthd.mahd = hd.mahd WHERE cthd.mahg = hg.mahg AND hd.ngayban BETWEEN @tungay AND @denngay)
        FROM hang hg;

    OPEN cur_cau_b;
    DECLARE @mahg_cur varchar(10), @tenhg_cur nvarchar(50), @tongnhap_cur int, @tongxuat_cur int;

    PRINT N'Thống kê từ ' + CONVERT(varchar, @tungay, 103) + N' đến ' + CONVERT(varchar, @denngay, 103);
    
    FETCH NEXT FROM cur_cau_b INTO @mahg_cur, @tenhg_cur, @tongnhap_cur, @tongxuat_cur;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT @mahg_cur + ' - ' + @tenhg_cur + ' - Nhập: ' + CAST(ISNULL(@tongnhap_cur, 0) AS varchar(10)) 
              + ' - Xuất: ' + CAST(ISNULL(@tongxuat_cur, 0) AS varchar(10));
        FETCH NEXT FROM cur_cau_b INTO @mahg_cur, @tenhg_cur, @tongnhap_cur, @tongxuat_cur;
    END
    CLOSE cur_cau_b;
    DEALLOCATE cur_cau_b;
END;
GO

-- Câu c
CREATE PROC sp_hien_thi_thong_tin @mahd varchar(10) AS
BEGIN   
    IF NOT EXISTS (SELECT 1 FROM hoadon WHERE mahd = @mahd)
    BEGIN
        PRINT N'Lỗi: Không tìm thấy hóa đơn ' + @mahd;
        RETURN;
    END

    DECLARE cur_cau_c CURSOR FOR 
        SELECT hg.mahg, hg.tenhg, cthd.soluong, cthd.giaban, cthd.thanhtien
        FROM hang hg JOIN chitiethd cthd ON hg.mahg = cthd.mahg
        WHERE cthd.mahd = @mahd;

    OPEN cur_cau_c;
    DECLARE @mahang_cur varchar(10), @tenhang_cur nvarchar(50), @soluongban_cur int, @giaban_cur float, @thanhtien_cur float;

    PRINT N'Chi tiết hóa đơn: ' + @mahd;
    PRINT '------------------------------------------------------------';

    FETCH NEXT FROM cur_cau_c INTO @mahang_cur, @tenhang_cur, @soluongban_cur, @giaban_cur, @thanhtien_cur;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT @mahang_cur + ' | ' + @tenhang_cur + ' | SL: ' + CAST(@soluongban_cur AS varchar(10)) 
              + ' | Đơn giá: ' + CAST(@giaban_cur AS varchar(20)) + ' | Thành tiền: ' + CAST(@thanhtien_cur AS varchar(20));
        FETCH NEXT FROM cur_cau_c INTO @mahang_cur, @tenhang_cur, @soluongban_cur, @giaban_cur, @thanhtien_cur;
    END
    CLOSE cur_cau_c;
    DEALLOCATE cur_cau_c;
END;
GO