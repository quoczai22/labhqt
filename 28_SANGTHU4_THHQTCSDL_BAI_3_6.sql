-- bai 3.6
use master
create database qldh 
go
use qldh

create table nhacungcap(
mancc varchar(10),
tenncc nvarchar(30),
dchi nvarchar(30),
dthoai int,
constraint pk_ncc primary key (mancc))

create table mathang(
mamh varchar(10),
tenmh nvarchar(30),
dvt nvarchar(10),
quycach nvarchar(50),
slton int,
dg float,
constraint pk_mh primary key(mamh))

create table cungung(
mancc varchar(10),
mamh varchar(10),
constraint pk_cu primary key (mancc,mamh),
constraint fk_cu_ncc foreign key (mancc) references nhacungcap(mancc),
constraint fk_cu_mh foreign key (mamh) references mathang(mamh))

set dateformat dmy
create table dathang(
sodh varchar(10),
ngaydh date,
mancc varchar(10),
sl_mathang int,
ghichu nvarchar(30),
thanhtien float,
constraint pk_dh primary key (sodh),
constraint fk_dh_ncc foreign key(mancc) references nhacungcap(mancc))

create table ctdh(
sodh varchar(10),
mamh varchar(10),
sldat int,
dg int,
constraint pk_ctdh primary key (sodh,mamh),
constraint fk_ctdh_dh foreign key (sodh) references dathang(sodh),
constraint fk_ctdh_mh foreign key (mamh) references mathang(mamh))

create table giaohang(
sogh varchar(10),
ngaygh date,
sodh varchar(10),
constraint pk_gh primary key(sogh),
constraint fk_gh_dh foreign key (sodh) references dathang(sodh))

create table ctgh(
sogh varchar(10),
mamh varchar(10),
slgiao int,
constraint pk_ctgh primary key(sogh,mamh),
constraint fk_ctgh_gh foreign key(sogh) references giaohang(sogh),
constraint fk_ctgh_mh foreign key(mamh) references mathang(mamh))

insert into nhacungcap (mancc, tenncc, dchi, dthoai) values
('NCC01', n'Công ty Minh Anh', n'Quận 1, TP.HCM', 0901234567),
('NCC02', n'Tổng kho Hòa Phát', n'Dĩ An, Bình Dương', 0283344556),
('NCC03', n'Điện máy Xanh', n'Quận Tân Phú, TP.HCM', 0988776655);

insert into mathang (mamh, tenmh, dvt, quycach, slton, dg) values
('MH01', n'Thép cuộn', n'Tấn', n'Phi 6', 100, 15000000),
('MH02', n'Xi măng', n'Bao', n'50kg/bao', 500, 90000),
('MH03', n'Gạch men', n'Thùng', n'60x60cm', 200, 250000),
('MH04', n'Ống nhựa', n'Cây', n'Phi 21, 4m', 150, 45000);

insert into cungung (mancc, mamh) values
('NCC01', 'MH01'),
('NCC01', 'MH02'),
('NCC02', 'MH01'),
('NCC02', 'MH03'),
('NCC03', 'MH04');

insert into dathang (sodh, ngaydh, mancc, sl_mathang, ghichu, thanhtien) values
('DH01', '10/04/2026', 'NCC01', 2, n'Giao gấp trong tuần', 0),
('DH02', '12/04/2026', 'NCC02', 1, n'Hàng đặt theo dự án', 0),
('DH03', '15/04/2026', 'NCC03', 1, null, 0);

insert into ctdh (sodh, mamh, sldat, dg) values
('DH01', 'MH01', 5, 15000000),
('DH01', 'MH02', 50, 90000),
('DH02', 'MH03', 100, 250000),
('DH03', 'MH04', 30, 45000);

insert into giaohang (sogh, ngaygh, sodh) values
('GH01', '13/04/2026', 'DH01'),
('GH02', '16/04/2026', 'DH02'),
('GH03', '18/04/2026', 'DH03');

insert into ctgh (sogh, mamh, slgiao) values
('GH01', 'MH01', 5),
('GH01', 'MH02', 30), 
('GH02', 'MH03', 100),
('GH03', 'MH04', 30);
-- cau 1a
go

create trigger kt_slton on mathang
for insert, update 
as begin
    if exists ( select 1 from inserted where slton <=0)
    begin 
        print 'loi slton phai lon hon 0'
        rollback tran
    end
end
-- cau b
go

create trigger kt_dvt on mathang
for insert, update 
as begin 
    if exists( select 1 from inserted where dvt not in (n'Tấn', n'Bao', n'Thùng', n'Cây', n'lốc', n'chai', n'túi', n'bình', n'hộp', n'hũ', n'gói', n'kg'))
    begin
        print 'loi'
        rollback tran
    end
end
-- cau c
go

create trigger kt_quycach on mathang
for insert, update
as begin
    if exists(select 1 from inserted where quycach is null or ltrim(rtrim(quycach)) = n'')
    begin
        print 'loi'
        rollback tran
    end
end
-- cau d
go

create trigger kt_dathang on dathang
for insert, update 
as begin
    if exists (select 1 from inserted where sl_mathang > 3)
    begin 
        print 'loi'
        rollback tran
    end
end
-- cau e
go

create trigger kt_gh on giaohang
for insert, update 
as begin 
if exists (
        select 1 
        from inserted i 
        join dathang dh on i.sodh = dh.sodh 
        where datediff(day, dh.ngaydh, i.ngaygh) > 7
    )
    begin 
        print 'loi: ngay giao hang khong duoc qua 7 ngay ke tu ngay dat hang!'
        rollback transaction
        return
    end
end
-- cau f
go

create trigger kt_dh on dathang
for insert, update 
as begin 
    if  exists (select 1 from inserted i left join nhacungcap ncc on i.mancc = ncc.mancc where ncc.mancc is null)
    begin
        print 'loi: ma nha cung cap khong ton tai!'
        rollback tran
    end 
end
-- cau g
go

create trigger kt_ghcodh on giaohang
for insert , update
as begin
    if exists (select 1 from inserted i left join dathang dh on dh.sodh=i.sodh where dh.sodh is null)
    begin
        print 'loi:so dat hang khong ton tai!'
        rollback tran
    end
end
-- cau h
go

create trigger kt_tongslgh on ctgh
for insert , update 
as begin 
    if exists (
        select 1
        from inserted i
        join giaohang gh on gh.sogh = i.sogh
        join ctdh dh on dh.sodh = gh.sodh and dh.mamh = i.mamh
        join (
            select gh2.sodh, ct.mamh, sum(ct.slgiao) as tongslgh
            from ctgh ct
            join giaohang gh2 on gh2.sogh = ct.sogh
            group by gh2.sodh, ct.mamh
        ) t on t.sodh = dh.sodh and t.mamh = dh.mamh
        where t.tongslgh > dh.sldat
    )
    begin
        print 'loi: tong so luong giao vuot qua so luong dat'
        rollback transaction
    end
end
-- cau i
go

create trigger kt_soluong_mathang_no_var on ctdh
for insert, update, delete
as begin
    if exists (
        select 1 
        from dathang dh
        where dh.sodh in (select sodh from inserted union select sodh from deleted)
          and dh.sl_mathang <> (select count(*) from ctdh where ctdh.sodh = dh.sodh)
    )
    begin
        print 'loi: so luong mat hang khai bao trong don hang khong khop voi so dong chi tiet thuc te!'
        rollback transaction
    end
end
-- cau j
go

create trigger up_slton on ctgh
for insert 
as begin
    update mathang
    set slton=slton+i.slgiao
    from inserted i
    where mathang.mamh=i.mamh
    end
-- cau k
go

create trigger cap_nhat_thanh_tien on ctdh
for insert, update, delete
as
begin
    update dathang
    set thanhtien = isnull((select sum(sldat * dg) from ctdh where sodh = dathang.sodh), 0)
    where sodh in (select sodh from inserted union select sodh from deleted)
end
-- cau 2a
go

create proc pro_tenvadc 
@sodh varchar(10)
as begin 
    select tenncc,dchi from nhacungcap ncc join dathang dh on dh.mancc=ncc.mancc where dh.sodh=@sodh
    end
-- cau b
go

create proc pro_dsdh
@mancc varchar(10)
as begin 
    select * from dathang dh where dh.mancc=@mancc
    end
-- cau c
go

create proc pro_thanhtien
@sogh varchar(10)
as begin
    select thanhtien from dathang dh join giaohang gh on gh.sodh=dh.sodh where gh.sogh=@sogh
    end
-- cau d
go

create proc pro_dsmh
@mancc varchar(10)
as begin
    select *from mathang mh join cungung cu on cu.mamh=mh.mamh where cu.mancc=@mancc
    end
-- cau 3a
go

create function fun_mh ()
returns table
as return (
    select mh.mamh,sl_mathang,thanhtien
    from mathang mh
    join cungung cu on cu.mamh=mh.mamh 
    join dathang dh on dh.mancc=cu.mancc)
-- cau b
go

create function fun_dsdh(@thang int ,@nam int)
returns table 
as return
    (select *
    from dathang 
    where month(ngaydh)=@thang and year(ngaydh) =@nam)
-- cau c
go

create function fun_ds(@mamh varchar(10))
returns @ds table (mamh varchar(10),tenmh nvarchar(30), sl_dagiao int, sl_chuagiao int)
as begin
    insert into @ds
    select 
        ctdh.mamh, 
        mh.tenmh, 
        isnull((select sum(ctg.slgiao) 
                from ctgh ctg, giaohang gh 
                where ctg.sogh = gh.sogh and gh.sodh = ctdh.sodh and ctg.mamh = ctdh.mamh), 0),
        ctdh.sldat - isnull((select sum(ctg.slgiao) 
                from ctgh ctg, giaohang gh 
                where ctg.sogh = gh.sogh and gh.sodh = ctdh.sodh and ctg.mamh = ctdh.mamh), 0)
    from ctdh ctdh, mathang mh
    where ctdh.mamh = mh.mamh and mh.mamh=@mamh
    return
end
-- cau d
go

create function fun_bangthongke (@ngaybatdau date, @ngayketthuc date)
returns table
as return
    (select mh.mamh,mh.tenmh,
    sum(ct.sldat) as tong_sl_dat
    from mathang mh
    join ctdh ct on mh.mamh = ct.mamh
    join dathang dh on ct.sodh = dh.sodh
    where dh.ngaydh between @ngaybatdau and @ngayketthuc
    group by mh.mamh,mh.tenmh
    )
go

