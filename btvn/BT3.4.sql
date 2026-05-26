-- ===================================================================
-- 1. TẠO CƠ SỞ DỮ LIỆU, TẠO BẢNG VÀ THÊM DỮ LIỆU
-- ===================================================================
CREATE DATABASE ql_tv;
GO
USE ql_tv;
GO

SET DATEFORMAT dmy;
CREATE TABLE sach (
    mash varchar(10),
    tensh nvarchar(30),
    tacgia nvarchar(30),
    loai nvarchar(30),
    tinhtrang int,
    CONSTRAINT pk_sach PRIMARY KEY (mash)
);

CREATE TABLE docgia (
    madg varchar(10),
    tendg nvarchar(30),
    ngsinh date,
    phai nvarchar(5),
    diachi nvarchar(30),
    CONSTRAINT pk_dg PRIMARY KEY (madg)
);

CREATE TABLE muonsach (
    madg varchar(10),
    mash varchar(10),
    ngaymuon date,
    ngaytra date,
    CONSTRAINT pk_ms PRIMARY KEY (madg, mash, ngaymuon),
    CONSTRAINT fk_ms_dg FOREIGN KEY (madg) REFERENCES docgia(madg),
    CONSTRAINT fk_ms_sh FOREIGN KEY (mash) REFERENCES sach(mash)
);
GO

-- Thêm dữ liệu
INSERT INTO sach (mash, tensh, tacgia, loai, tinhtrang) VALUES
('S01', N'Đắc Nhân Tâm', 'Dale Carnegie', N'Kỹ năng', 1),
('S02', N'Lược sử thời gian', 'Stephen Hawking', N'Khoa học tự nhiên', 1),
('S03', N'Tôi thấy hoa vàng', N'Nguyễn Nhật Ánh', N'Truyện', 0),
('S04', N'Nhà giả kim', 'Paulo Coelho', N'Truyện', 1),
('S05', N'Lập trình SQL', 'Microsoft', N'Kỹ năng', 0);

INSERT INTO docgia (madg, tendg, ngsinh, phai, diachi) VALUES
('DG01', N'Nguyễn Văn An', '15/05/2005', N'Nam', N'TP. Hồ Chí Minh'),
('DG02', N'Trần Thị Bình', '20/10/2004', N'Nữ', N'Hà Nội'),
('DG03', N'Lê Minh Cường', '05/12/1998', N'Nam', N'Đà Nẵng'),
('DG04', N'Phạm Mỹ Hạnh', '12/02/2006', N'Nữ', N'Cần Thơ');

INSERT INTO muonsach (madg, mash, ngaymuon, ngaytra) VALUES
('DG01', 'S01', '01/04/2026', '10/04/2026'), 
('DG01', 'S02', '15/04/2026', NULL),        
('DG02', 'S01', '20/04/2026', NULL),        
('DG03', 'S04', '10/03/2026', '20/03/2026'), 
('DG04', 'S02', '25/04/2026', NULL);        
GO

-- ===================================================================
-- 2. TRIGGER, PROCEDURE, FUNCTION, CURSOR
-- ===================================================================

-- TRIGGER
-- Câu 1a
CREATE TRIGGER kt_tuoi ON docgia
FOR INSERT, UPDATE AS 
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE DATEDIFF(YEAR, ngsinh, GETDATE()) < 15)
    BEGIN 
        RAISERROR(N'Lỗi: Phát hiện độc giả dưới 15 tuổi. Giao dịch bị hủy!', 16, 1);
        ROLLBACK TRANSACTION; 
    END
END;
GO

-- Câu b
CREATE TRIGGER kt_phai ON docgia 
FOR INSERT, UPDATE AS 
BEGIN 
    IF EXISTS (SELECT 1 FROM inserted WHERE phai NOT IN (N'Nam', N'Nữ'))
    BEGIN
        RAISERROR(N'Lỗi: Giới tính phải là Nam hoặc Nữ', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Câu c (Sửa lỗi cho đúng dữ liệu)
CREATE TRIGGER kt_loai ON sach
FOR INSERT, UPDATE AS 
BEGIN 
    IF EXISTS (SELECT 1 FROM inserted WHERE loai NOT IN (N'Khoa học tự nhiên', N'Xã hội', N'Kinh tế', N'Truyện', N'Kỹ năng'))
    BEGIN 
        RAISERROR(N'Lỗi: Thể loại sách không hợp lệ!', 16, 1);
        ROLLBACK TRAN;
    END
END;
GO

-- Câu d (Sửa lỗi khóa tinhtrang = 0 khi mượn)
CREATE TRIGGER kt_muon ON muonsach
FOR INSERT AS 
BEGIN 
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 
        FROM muonsach m JOIN inserted i ON i.madg = m.madg
        WHERE m.ngaytra IS NULL
        GROUP BY m.madg
        HAVING COUNT(m.mash) > 3
    )
    BEGIN
        RAISERROR(N'Lỗi: Độc giả không được mượn quá 3 cuốn sách chưa trả!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    UPDATE sach SET tinhtrang = 0 
    FROM sach s JOIN inserted i ON s.mash = i.mash;
    PRINT N'Hệ thống: Đã cập nhật tình trạng sách thành Đã mượn.';
END;
GO

-- Câu e (Sửa lỗi khóa tinhtrang = 1 khi trả)
CREATE TRIGGER kt_dg_tra ON muonsach
FOR UPDATE AS 
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(ngaytra)
    BEGIN
        UPDATE sach SET tinhtrang = 1 
        FROM sach s JOIN inserted i ON s.mash = i.mash
        WHERE i.ngaytra IS NOT NULL; 
        
        PRINT N'Hệ thống: Đã cập nhật tình trạng sách thành Chưa mượn.';
    END
END;
GO

-- PROCEDURE
-- Câu a
CREATE PROC tenvadc @madg varchar(10)
AS BEGIN 
    IF EXISTS (SELECT 1 FROM docgia WHERE madg = @madg)
    BEGIN
        SELECT tendg, diachi FROM docgia WHERE madg = @madg;
    END
    ELSE 
    BEGIN
        PRINT N'Lỗi mã độc giả không tồn tại';
    END
END;
GO

-- Câu b
CREATE PROC nxb_tg @mash varchar(10)
AS BEGIN 
    IF EXISTS(SELECT 1 FROM sach WHERE mash = @mash)
    BEGIN 
        SELECT tensh, tacgia FROM sach WHERE mash = @mash;
    END
    ELSE 
    BEGIN 
        PRINT N'Lỗi mã sách không tồn tại';
    END
END;
GO

-- Câu c
CREATE PROC slsh_dgmuonchuatra @madg varchar(10)
AS BEGIN 
    IF EXISTS (SELECT 1 FROM muonsach WHERE madg = @madg AND ngaytra IS NULL)
    BEGIN 
        SELECT COUNT(mash) as SL_Sach_No FROM muonsach WHERE madg = @madg AND ngaytra IS NULL;
    END
    ELSE
    BEGIN
        PRINT N'Độc giả không nợ sách hoặc mã không tồn tại';
    END
END;
GO

-- Câu d
CREATE PROC dgdangmuonsh @mash varchar(10)
AS BEGIN 
    IF EXISTS (SELECT 1 FROM docgia d JOIN muonsach m ON m.madg = d.madg WHERE mash = @mash AND m.ngaytra IS NULL)
        SELECT tendg FROM docgia d JOIN muonsach m ON m.madg = d.madg WHERE mash = @mash AND m.ngaytra IS NULL;
    ELSE
        PRINT N'Chưa có ai mượn cuốn sách này';
END;
GO 

-- Câu e
CREATE PROC soshmadgmuon 
    @madg varchar(10),
    @ngaymuon date
AS BEGIN 
    IF EXISTS (SELECT 1 FROM muonsach WHERE madg = @madg AND ngaymuon = @ngaymuon)
        SELECT COUNT(mash) as SoSach FROM muonsach WHERE madg = @madg AND ngaymuon = @ngaymuon;
    ELSE
        PRINT N'Không có dữ liệu';
END;
GO

-- Câu f
CREATE PROC ngaymuongannhat @mash varchar(10)
AS BEGIN
    IF EXISTS (SELECT 1 FROM muonsach WHERE mash = @mash)
    BEGIN
        DECLARE @ngay int, @thang int, @nam int;
        SELECT @ngay = DAY(MAX(ngaymuon)),
               @thang = MONTH(MAX(ngaymuon)),
               @nam = YEAR(MAX(ngaymuon))
        FROM muonsach
        WHERE mash = @mash;
        SELECT @ngay AS Ngay, @thang AS Thang, @nam AS Nam;
    END
    ELSE
    BEGIN
        PRINT N'Lỗi mã sách không tồn tại';
    END
END;
GO

-- FUNCTION
-- Câu a (Sửa lỗi kiểu dữ liệu bị lỗi font tiếng Việt)
CREATE FUNCTION fn_tendg_dc (@madg varchar(10))
RETURNS NVARCHAR(100)
AS BEGIN 
    DECLARE @tendg nvarchar(30), @dc nvarchar(30);
    SELECT @tendg = tendg, @dc = diachi FROM docgia WHERE madg = @madg;
    RETURN ISNULL(@tendg, N'Không rõ tên') + ' - ' + ISNULL(@dc, N'Không rõ địa chỉ');
END;
GO 

-- Câu b
CREATE FUNCTION fn_dsdgchuatra (@mash varchar(10))
RETURNS TABLE 
AS RETURN (
    SELECT DISTINCT d.madg, d.tendg FROM docgia d 
    JOIN muonsach m ON m.madg = d.madg 
    WHERE m.ngaytra IS NULL AND m.mash = @mash
);
GO

-- Câu c
CREATE FUNCTION fn_datungmuon(@mash varchar(10))
RETURNS TABLE 
AS RETURN (
    SELECT DISTINCT d.madg, d.tendg FROM docgia d 
    JOIN muonsach m ON m.madg = d.madg 
    WHERE m.mash = @mash 
);
GO

-- Câu d
CREATE FUNCTION fn_tongsh (@madg varchar(10), @thang int)
RETURNS TABLE
AS RETURN (
    SELECT COUNT(mash) AS TongSoLuong FROM muonsach 
    WHERE madg = @madg AND MONTH(ngaymuon) = @thang
);
GO

-- CURSOR 
-- Câu a
DECLARE hien_thi_madg_tendg_soluong CURSOR FOR 
SELECT dg.MADG, dg.TENDG, COUNT(ms.MASH) as TONGSOSACH
FROM DOCGIA dg JOIN MUONSACH ms ON dg.MADG = ms.MADG 
WHERE ms.NGAYMUON = '2026-04-12'
GROUP BY dg.MADG, dg.TENDG;

OPEN hien_thi_madg_tendg_soluong;
DECLARE @madg_cur varchar(10), @tendg_cur nvarchar(50), @tongsosach_cur int;

FETCH NEXT FROM hien_thi_madg_tendg_soluong INTO @madg_cur, @tendg_cur, @tongsosach_cur;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @madg_cur + ' - ' + @tendg_cur + ' - ' + CAST(@tongsosach_cur AS varchar(20));
    FETCH NEXT FROM hien_thi_madg_tendg_soluong INTO @madg_cur, @tendg_cur, @tongsosach_cur;
END
CLOSE hien_thi_madg_tendg_soluong;
DEALLOCATE hien_thi_madg_tendg_soluong;
GO

-- Câu b
DECLARE hien_thi_mash_tensh CURSOR FOR 
SELECT MASH, TENSH
FROM SACH
WHERE TINHTRANG = 1; -- Quy ước 1 là Sẵn sàng (chưa mượn)

OPEN hien_thi_mash_tensh;
DECLARE @masach_cur varchar(10), @tensh_cur nvarchar(50);

FETCH NEXT FROM hien_thi_mash_tensh INTO @masach_cur, @tensh_cur;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @masach_cur + ' - ' + @tensh_cur;
    FETCH NEXT FROM hien_thi_mash_tensh INTO @masach_cur, @tensh_cur;
END
CLOSE hien_thi_mash_tensh;
DEALLOCATE hien_thi_mash_tensh;
GO

-- Câu c
ALTER TABLE DOCGIA ADD SOLANMUON int;
GO
UPDATE DOCGIA SET SOLANMUON = 0;
GO

CREATE PROC sp_cap_nhat_so_lan_muon AS
BEGIN
    DECLARE cap_nhat_so_lan_muon CURSOR FOR 
    SELECT MADG, COUNT(DISTINCT NGAYMUON) as SOLANMUON
    FROM MUONSACH
    GROUP BY MADG;
    
    OPEN cap_nhat_so_lan_muon;
    DECLARE @madg_cur VARCHAR(10), @solan_cur int;
    
    FETCH NEXT FROM cap_nhat_so_lan_muon INTO @madg_cur, @solan_cur;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE DOCGIA SET SOLANMUON = @solan_cur WHERE MADG = @madg_cur;
        FETCH NEXT FROM cap_nhat_so_lan_muon INTO @madg_cur, @solan_cur;
    END
    CLOSE cap_nhat_so_lan_muon;
    DEALLOCATE cap_nhat_so_lan_muon;
END;
GO

-- Câu d
ALTER TABLE MUONSACH ADD QUAHAN nvarchar(20);
GO

DECLARE cap_nhat_qua_han CURSOR FOR 
SELECT MADG, MASH, DATEDIFF(DAY, NGAYMUON, GETDATE())
FROM MUONSACH
WHERE NGAYTRA IS NULL;

OPEN cap_nhat_qua_han;
DECLARE @madocgia_cur varchar(10), @masach_cur varchar(10), @songay_cur int, @trangthai_cur nvarchar(20);

FETCH NEXT FROM cap_nhat_qua_han INTO @madocgia_cur, @masach_cur, @songay_cur;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF @songay_cur > 60
        SET @trangthai_cur = N'Quá hạn';
    ELSE
        SET @trangthai_cur = NULL;

    UPDATE MUONSACH
    SET QUAHAN = @trangthai_cur
    WHERE MADG = @madocgia_cur AND MASH = @masach_cur AND NGAYTRA IS NULL;

    FETCH NEXT FROM cap_nhat_qua_han INTO @madocgia_cur, @masach_cur, @songay_cur;
END
CLOSE cap_nhat_qua_han;
DEALLOCATE cap_nhat_qua_han;
GO