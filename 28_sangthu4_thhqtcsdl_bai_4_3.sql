
use qlhv
go

create table lophoc(
malh varchar(10) primary key,
 tenlop nvarchar(30),
 ngaybd date ,
 ngaykt date,
 makh varchar(10),
 constraint fk_lh_kh foreign key (makh) references khoahoc(makh)) 
 
 insert into lophoc values
 ('lh1', N'tieng anh 1', '20240211', '20240411', 'kh01'),
  ('lh2', N'tieng anh 2', '20240315', '20240515', 'kh01');

  --full t1
backup database qlhv
to disk = 'E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\fullqlhv.bak'
with init
go

insert into lophoc values
 ('lh3', N'tieng anh 1', '20240211', '20240411', 'kh02')

 --log t2
 backup log qlhv
to disk = 'E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\logqlhv_lh_t2.trn'
with init
go

insert into lophoc values
 ('lh4', N'tieng anh 1', '20240211', '20240411', 'kh03')

 --log t3
  backup log qlhv
to disk = 'E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\logqlhv_lh_t3.trn'
with init
go

insert into lophoc values
 ('lh5', N'tieng anh 1', '20240211', '20240411', 'kh03')

 --diff t4
 backup database qlhv
to disk = 'E:\LuuDuLieuSinhVien\sangthu4_thhqtcsdl\28_sangthu4_thhqtcsdl\diffqlhv.bak'
with differential
go

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
 --b4 phuc hoi database
 restore database qlhv
 with recovery
 go
