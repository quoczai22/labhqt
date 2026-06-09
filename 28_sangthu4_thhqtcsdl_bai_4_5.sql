create database QLDH
go

use QLDH
go

create table DONHANG
(
    MADH varchar(10),
    TENDH nvarchar(30)
)
go

insert into DONHANG
values
('DH01', N'But'),
('DH02', N'Tay'),
('DH03', N'Tap')
go

backup database QLDH
to disk='E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\QLDH_full.bak'
with init
go

insert into DONHANG values
('DH04', N'Tap')
go

backup log QLDH
to disk='E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\QLDH_log_t2.trn'
with init
go

insert into DONHANG values
('DH06', N'Tap')
go

backup database QLDH
to disk='E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\QLDH_diff_t3.bak'
with differential
go

insert into DONHANG values
('DH05', N'Tap')
go

backup log QLDH
to disk='E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\QLDH_log_t4.trn'
with init
go

 --b2 restore full
 use master
 go

 restore database QLDH
 from disk ='E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\QLDH_full.bak'
 with norecovery, replace
 go 

 --b3 restore diff gan nhat 
 restore database QLDH
 from disk ='E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\QLDH_diff_t3.bak'
 with norecovery
 go
 --b4 restore log sau diff
  restore log QLDH
 from disk ='E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\QLDH_log_t4.trn'
 with recovery
 go

