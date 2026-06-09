create database QLBH
go

use QLBH
go

create table HOADON
(
    MAHD varchar(10),
    TENKH nvarchar(30)
)
go

insert into HOADON
values
('HD01', N'Quoc'),
('HD02', N'Hieu'),
('HD03', N'Nam')
go

backup database QLBH
to disk='E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\QLBH_full.bak'
with init
go

insert into HOADON
values ('HD04', N'Pham Van D')
go

backup log QLBH
to disk='E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\QLBH_log_t2.trn'
with init
go

insert into HOADON
values
('HD05', N'Hoang Van E');
go

backup database QLBH
to disk='E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\QLBH_diff_t3.bak'
with differential
go

insert into HOADON
values
('HD07', N'Le Van G');
go

backup log QLBH
to disk='E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\QLBH_log_t3.trn'
with init
go

 --b2 restore full
 use master
 go

 restore database QLBH
 from disk ='E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\QLBH_full.bak'
 with norecovery, replace
 go 
 --b3 restore diff gan nhat 
 restore database QLBH
 from disk ='E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\QLBH_diff_t3.bak'
 with norecovery
 go
 --b4 restore log sau diff
  restore log QLBH
 from disk ='E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\QLBH_log_t3.trn'
 with recovery
 go

