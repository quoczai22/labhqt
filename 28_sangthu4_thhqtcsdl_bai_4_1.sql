create database db1
go 
use db1
go

create table khach(
makh varchar(10),
tenkh nvarchar(30),
diachi nvarchar(30))
go

insert into khach values 
('kh01', N'quoc', 'aa'),
('kh02', N'quoc', 'aa'),
('kh03', N'quoc', 'aa')
go

--full t2
backup database db1
to disk = 'E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\db1_full.bak'
with init
go

insert into khach values 
('kh04', N'quoc', 'aa')
 go

 --diff t3
backup database db1
to disk = 'E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\db1_diff.bak'
with differential
go

insert into khach values 
('kh05', N'quoc', 'aa')
 go

 --diff t4
 backup database db1
to disk = 'E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\db1_diff_t4.bak'
with differential
go

insert into khach values 
('kh06', N'quoc', 'aa')
 go

 --diff t5
  backup database db1
to disk = 'E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\db1_diff_t5.bak'
with differential
go

insert into khach values 
('kh07', N'quoc', 'aa')
 go

 --b1 backup log
 backup log db1
 to disk='E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\db1_log.trn'
 go
 --b2 restore full
 use master
 go

 restore database db1
 from disk ='E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\db1_full.bak'
 with norecovery, replace
 go 
 --b3 restore diff gan nhat 
 restore database db1
 from disk ='E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\db1_diff_t5.bak'
 with norecovery
 go
 --b4 restore log sau diff
  restore log db1
 from disk ='E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\db1_log.trn'
 with recovery
 go
