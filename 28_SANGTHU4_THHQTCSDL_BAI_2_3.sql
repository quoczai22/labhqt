 create database ql_banhang

 use ql_banhang

 create table khach(
 makh varchar(10),
 tenkh nvarchar(30),
 diachi nvarchar(30),
 dienthoai varchar(10)
 constraint pk_kh primary key (makh))

 create table hoadon(
 mahd varchar(10),
 ngaylap date,
 makh varchar(10)
 constraint pk_hd primary key (mahd),
 constraint fk_hd_kh foreign key (makh) references khach(makh))

 create table hang(
 mahg varchar(10),
 tenhg nvarchar(30),
 dvt nvarchar (7),
 nhasx nvarchar(10)
 constraint pk_hg primary key (mahg))

 create table chitiethd(
 mahd varchar(10),
 mahg varchar(10),
 soluong int,
 giaban float
 constraint pk_cthd primary key (mahd,mahg),
 constraint fk_cthd_hd foreign key (mahd) references hoadon(mahd),
 constraint fk_cthd_hg foreign key (mahg) references hang(mahg))

 create table phieunhap(
 mapn varchar(10),
 ngaylap date,
 mancc varchar(10)
 constraint pk_pn primary key (mapn))

 create table chitietpn(
 mapn varchar(10),
 mahg varchar(10),
 soluong int,
 gianhap float
 constraint pk_ctpn primary key (mapn,mahg),
 constraint fk_ctpn_pn foreign key (mapn) references phieunhap(mapn),
 constraint fk_ctpn_hg foreign key (mahg) references hang(mahg))

 INSERT INTO KHACH (MAKH, TENKH, DIACHI, DIENTHOAI) VALUES
('K01', 'LAN', 'TPHCM', '0943657644'),
('K02', 'MINH', N'HÀ NỘI', '0384535643'),
('K03', N'CHÂU', N'HÀ NỘI', '0908343533'),
('K04', N'TUẤN', 'LONG AN', '0378213242'),
('K05', N'BÌNH', N'ĐÀ NẴNG', '0983232223');

INSERT INTO HANG (MAHG, TENHG, DVT, nhasx) VALUES
('A01', N'Bình thuỷ tinh 1L', N'Bộ', 'Luminarc'),
('A02', N'Đèn để bàn RD', N'Bộ', N'Rạng Đông'),
('A03', N'Bút biết bảng TL', N'Cây', N'Thiên Long'),
('A04', N'Móc dán tường', N'Cái', N'Duy Tân'),
('A05', N'Bộ thước Eke', N'Bộ', 'Minh An'),
('A06', N'Hộp đựng bút', N'Cái', 'Minh An'),
('A07', N'Sổ tay', N'Quyển', N'Thành Tín');

INSERT INTO HOADON (MAHD, NGAYLAP, MAKH) VALUES
('HD001', '2023-03-22', 'K01'),
('HD002', '2023-04-10', 'K01'),
('HD003', '2023-06-09', 'K02'),
('HD004', '2023-06-17', 'K03');

INSERT INTO PHIEUNHAP (MAPN, NGAYLAP, MANCC) VALUES
('PN001', '2023-01-10', 'CC1'),
('PN002', '2023-02-15', 'CC1'),
('PN003', '2023-02-25', 'CC2');

INSERT INTO CHITIETPN (MAPN, MAHG, SOLUONG, GIANHAP) VALUES
('PN001', 'A01', 20, 77000),
('PN001', 'A02', 15, 32000),
('PN001', 'A03', 50, 7500),
('PN002', 'A04', 100, 2000),
('PN002', 'A05', 30, 5500),
('PN003', 'A06', 10, 16000),
('PN003', 'A07', 25, 12000);

INSERT INTO CHITIETHD (MAHD, MAHG, SOLUONG, GIABAN) VALUES
('HD001', 'A01', 1, 85000),
('HD001', 'A05', 2, 7000),
('HD002', 'A03', 5, 8500),
('HD002', 'A04', 10, 3000),
('HD003', 'A03', 3, 8500),
('HD004', 'A02', 4, 40000),
('HD004', 'A04', 2, 3000),
('HD004', 'A07', 3, 15000);

create view dsbh
as 
select h.makh,tenkh, sum(c.giaban) as doanhso
from khach k,hoadon h, chitiethd c
where h.makh=k.makh and c.mahd =h.mahd
group by  h.makh,tenkh

select *from dsbh

create view dshd
as 
select h.mahd, tenkh,sum( c.giaban) as tonggiatrihd
from hoadon h, khach k, chitiethd c
where h.makh=k.makh and c.mahd =h.mahd
group by  h.mahd, tenkh

select *from dshd

create view dshg
as 
select h.mahg,tenhg,dvt, sum(c.soluong) as tongslban
from hang h,chitiethd c
where h.mahg=c.mahg
group by h.mahg,tenhg,dvt

select *from dshg


create view dshgn
as 
select h.mahg,tenhg,dvt, sum(c.soluong) as tongslnhap
from hang h,chitietpn c
where h.mahg=c.mahg
group by h.mahg,tenhg,dvt

select *from dshgn

create view tkgt
as
select month(h.ngaylap) as thang,sum( c.giaban) as tonggiatrihd
from hoadon h, chitiethd c
where  c.mahd =h.mahd
group by  month(h.ngaylap)

select * from tkgt

create view tkln
as
select month(hd.ngaylap) as thang,sum(cthd.giaban-ctpn.gianhap) as tongloinhuan
from chitiethd cthd, hang hg, chitietpn ctpn,hoadon hd
where hg.mahg=ctpn.mahg and cthd.mahg=hg.mahg and hd.mahd=cthd.mahd
group by  month(hd.ngaylap)

select * from tkln

create view kethop
as
select tkln.thang,tkgt.tonggiatrihd,tkln.tongloinhuan
from tkgt,tkln
where tkgt.thang=tkln.thang

select * from kethop

create view dshgh
as
select hg.mahg,tenhg,dvt,sum(ctpn.soluong) as tongsln ,sum(cthd.soluong) as tongslb, sum(ctpn.soluong-cthd.soluong) as tongslconlai
from hang hg, chitietpn ctpn, chitiethd cthd
where hg.mahg=ctpn.mahg and cthd.mahg=hg.mahg
group by hg.mahg,tenhg,dvt

select * from dshgh

