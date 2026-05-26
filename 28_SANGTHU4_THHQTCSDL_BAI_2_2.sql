 create database ql_sinhvien
 on primary
  (
 name=ql_sinhvien_data,
 filename='E:\LuuDuLieuSinhVien\SANGTHU4_THHQTCSDL\ql_sinhvien_data.mdf',
 size=15mb,
 maxsize=30mb,
 filegrowth=10%
 )
 log on
 (
 name=ql_sinhvien_log,
 filename='E:\LuuDuLieuSinhVien\SANGTHU4_THHQTCSDL\ql_sinhvien_log.ldf',
 size=10mb,
 maxsize=20mb,
 filegrowth=15%
 )

 use ql_sinhvien

 create table khoa(
 makhoa varchar(10),
 tenkhoa nvarchar(30)
 constraint pk_kh primary key (makhoa))

 create table lop(
 malop varchar(10),
 tenlop nvarchar(30),
 sisodk int,
 makhoa varchar(10)
 constraint pk_l primary key (malop),
 constraint fk_l_kh foreign key (makhoa) references khoa (makhoa))

 create table sinhvien(
 masv varchar(10),
 hoten nvarchar(30),
 ngsinh date,
 dchi nvarchar(30),
 gioitinh nvarchar(7),
 malop varchar(10)
 constraint pk_sv primary key (masv),
 constraint fk_sv_l foreign key (malop) references lop(malop))

 create table monhoc(
 mamh varchar(10),
 tenmh nvarchar(30),
 sotc int
 constraint pk_mh primary key (mamh))

 create table ketqua(
 masv varchar(10),
 mamh varchar(10),
 diem float
 constraint pk_kq primary key (masv,mamh),
 constraint fk_kq_sv foreign key (masv) references sinhvien(masv),
 constraint fk_kq_mh foreign key (mamh) references monhoc(mamh))

INSERT INTO KHOA (MAKHOA, TENKHOA) VALUES
('01', N'Công nghệ thông tin'),
('02', N'Điện - Điện tử'),
('03', N'Công nghệ Thực phẩm');

-- Thêm dữ liệu cho bảng LOP
INSERT INTO LOP (MALOP, TENLOP, MAKHOA) VALUES
('L001', '15CNTT1', '01'),
('L002', '15CNTT2', '01'),
('L003', '14ATTT', '01'),
('L004', '14DTVT', '02'),
('L005', '16ATTP1', '03'),
('L006', '16ATTP2', '03');

-- Thêm dữ liệu cho bảng SINHVIEN
INSERT INTO SINHVIEN (MASV, HOTEN, NGSINH, DCHI, GIOITINH, MALOP) VALUES
('SV01', N'Nguyễn Thị Lan', '2005-07-15', N'TPHCM', N'Nam', 'L001'),
('SV02', N'Trần Thanh Tùng', '2005-05-19', N'Vũng Tàu', N'Nam', 'L001'),
('SV03', N'Trương Thị Huệ', '2002-08-31', N'Đà Nẵng', N'Nữ', 'L001'),
('SV04', N'Lê Văn Khánh', '2002-01-18', N'Vũng Tàu', N'Nam', 'L002'),
('SV05', N'Ngô Đình Việt', '2004-09-27', N'Đà Nẵng', N'Nam', 'L003'),
('SV06', N'Trần Thị Liễu', '2003-02-18', N'TPHCM', N'Nữ', 'L003'),
('SV07', N'Trần Thanh Nam', '2004-06-22', N'Đồng Nai', N'Nam', 'L004'),
('SV08', N'Phạm Hoài Phong', '2003-12-08', N'Tiền Giang', N'Nam', 'L004'),
('SV09', N'Trần Thị Tố Anh', '2004-11-28', N'TPHCM', N'Nữ', 'L005'),
('SV10', N'Đỗ Thị Hạnh', '2004-04-26', N'Đồng Nai', N'Nữ', 'L006');

-- Thêm dữ liệu cho bảng MONHOC
INSERT INTO MONHOC (MAMH, TENMH, SOTC) VALUES
('M001', N'Toán cao cấp A1', 3),
('M002', N'Lịch sử đảng', 2),
('M003', N'Chính trị', 2),
('M004', N'Cơ sở dữ liệu', 4),
('M005', N'Hệ quản trị CSDL', 4),
('M006', N'Lập trình C', 3),
('M007', N'Xử lý ảnh', 2),
('M008', N'Tin học cơ bản', 3),
('M009', N'Mạng máy tính', 2),
('M010', N'Toán rời rạc', 2),
('M011', N'Lập trình web', 3),
('M012', N'Công nghệ Java', 3);

-- Thêm dữ liệu cho bảng KETQUA
INSERT INTO KETQUA (MASV, MAMH, DIEM) VALUES
('SV01', 'M001', 8),
('SV01', 'M002', 4),
('SV01', 'M003', 6),
('SV02', 'M001', 4),
('SV02', 'M004', 5),
('SV03', 'M002', 7),
('SV03', 'M006', 9),
('SV04', 'M004', 10),
('SV05', 'M005', 6),
('SV06', 'M006', 9),
('SV07', 'M008', 7),
('SV08', 'M001', 3),
('SV08', 'M002', 8),
('SV09', 'M003', 6),
('SV10', 'M002', 5);

-- [SỬA LỖI 1] Thêm join bảng khoa để lọc đúng theo tên khoa (tenkhoa),
-- không phải tên lớp (tenlop)
select sv.masv,sv.hoten
from sinhvien sv, lop l, khoa kh
where sv.malop=l.malop and l.makhoa=kh.makhoa
and kh.tenkhoa=N'Công nghệ thông tin'

-- [SỬA LỖI 2] Sửa 'SV001' thành 'SV01' cho đúng với dữ liệu đã insert
select kq.diem
from ketqua kq
join sinhvien sv on sv.masv=kq.masv
where sv.masv='SV01'

select sv.*
from sinhvien sv  
join ketqua kq on kq.masv=sv.masv
where kq.diem<5

select sv.masv,sv.hoten,(sum(kq.diem*mh.sotc)/sum(mh.sotc)) as dtb
from sinhvien sv, ketqua kq,monhoc mh
where sv.masv=kq.masv and mh.mamh=kq.mamh
group by sv.masv,sv.hoten

select sv.masv,sv.hoten,mh.sotc
from sinhvien sv, monhoc mh,ketqua kq
where sv.masv=kq.masv and kq.mamh=mh.mamh and kq.diem>=5

select sv.masv,sv.hoten
from sinhvien sv
where not exists (select 1 from ketqua kq where kq.masv=sv.masv )

select l.malop,l.tenlop ,count(masv) as soluongsv
from sinhvien sv, lop l
where sv.malop=l.malop 
group by l.malop,l.tenlop 
having count(masv)>=all(select count(masv) from sinhvien sv group by sv.malop )

create view dssv 
as 
select kh.makhoa,kh.tenkhoa,count(sv.masv) as slsv
from sinhvien sv, lop l, khoa kh
where sv.malop=l.malop and kh.makhoa=l.makhoa
group by kh.makhoa,kh.tenkhoa

select *
from dssv

create view dsmh 
as 
select mh.mamh,mh.tenmh,count(sv.masv) as slsv
from sinhvien sv,ketqua kq, monhoc mh
where sv.masv=kq.masv and kq.mamh=mh.mamh
group by  mh.mamh,mh.tenmh

select *
from dsmh

-- [SỬA LỖI 3] Đổi count(distinct case...) thành sum(case...)
-- count(distinct case...) luôn trả về 1 hoặc 2 vì CASE chỉ ra giá trị 0 hoặc 1
create view dsmhlonhonnam 
as 
select mh.mamh,mh.tenmh,mh.sotc,
sum(case when kq.diem>=5 then 1 else 0 end) as dat,
sum(case when kq.diem<5 then 1 else 0 end) as rot
from sinhvien sv,ketqua kq, monhoc mh
where sv.masv=kq.masv and kq.mamh=mh.mamh 
group by  mh.mamh,mh.tenmh,mh.sotc

select *
from dsmhlonhonnam

-- [SỬA LỖI 4] Sửa gioitinh='nam' thành gioitinh=N'Nam' cho đúng với
-- dữ liệu đã insert (dùng N'' và chữ hoa đầu)
create view tksv
as 
select l.malop,tenlop,
sum(case when sv.gioitinh=N'Nam' then 1 else 0 end) as slsvnam,
sum(case when sv.gioitinh=N'Nữ' then 1 else 0 end) as slsvnu,
count(sv.masv) as slsv
from sinhvien sv,lop l
where l.malop=sv.malop 
group by l.malop,tenlop

select *
from tksv

create view tkttsv
as 
select sv.masv,hoten,sum(mh.sotc) as tongtinchi, sum(case when kq.diem>=5 then 1 else 0 end) as tongtichluy, (sum(kq.diem*mh.sotc)/sum(mh.sotc)) as dtb
from sinhvien sv,ketqua kq , monhoc mh
where kq.masv=sv.masv and kq.mamh =mh.mamh
group by sv.masv,hoten

select *
from tkttsv
