 
 create database qlhv
 go

use qlhv
go 

create table khoahoc(
makh varchar(10) ,
tenkh nvarchar(10),
thoiluong int,
constraint pk_kh primary key (makh))
go

insert into khoahoc values
('kh01',N'tieng anh',3),
('kh02',N'tieng anh',3),
('kh03',N'tieng anh',3);

--fullbackup
backup database qlhv
to disk = 'E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\fullqlhv.bak'
with init
go

insert into khoahoc values
('kh04',N'tiengtrung',6)

--diff l1
backup database qlhv
to disk = 'E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\diffqlhv.bak'
with differential
go

insert into khoahoc values
('kh05',N'tieng han',12)

--log
backup log qlhv
to disk = 'E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\logqlhv_t2.trn'
with init
go

insert into khoahoc values
('kh06',N'tieng nhat',6)
--log l2
backup log qlhv
to disk = 'E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\logqlhv_t3.trn'
with init
go

 --b2 restore full
 use master
 go

 restore database qlhv
 from disk ='E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\fullqlhv.bak'
 with norecovery, replace
 go 
 --b3 restore diff gan nhat 
 restore database qlhv
 from disk ='E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\diffqlhv.bak'
 with norecovery
 go
 --b4 restore log sau diff
 restore log qlhv
 from disk ='E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\logqlhv_t2.trn'
 with norecovery
 go

 restore log qlhv
 from disk ='E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\logqlhv_t3.trn'
 with recovery
 go


