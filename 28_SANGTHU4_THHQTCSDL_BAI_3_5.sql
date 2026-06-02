-- bai 3.5
use master

create database qlbh
go
use qlbh

create table khachhg(
makh varchar(10),
tenkh nvarchar(30),
dc nvarchar(30),
dt varchar(10),
constraint pk_khachhg primary key (makh))

create table nhasx(
mansx varchar(10),
tennxs nvarchar(30),
dc nvarchar(30),
dt varchar(10),
constraint pk_nxs primary key (mansx))

create table ncc(
mancc varchar(10),
tenncc nvarchar(30),
dc nvarchar(30),
dt varchar(10),
constraint pk_ncc primary key (mancc))

create table hang(
mahg varchar(10),
tenhg nvarchar(30),
dvt int,
soluongton int,
mansx varchar(10),
tinhtrang nvarchar(10),
constraint pk_hg primary key (mahg),
constraint fk_hg_nxs foreign key (mansx) references nhasx (mansx))

set dateformat dmy
create table phieunhap(
mapn varchar(10),
ngaynhap date,
mancc varchar(10),
tiennhap int,
constraint pk_pn primary key (mapn),
constraint fk_pn_ncc foreign key (mancc) references ncc (mancc))

create table chitietpn(
mapn varchar(10),
mahg varchar(10),
soluong int,
gianhap float,
thanhtien float,
constraint pk_ctpn primary key (mapn,mahg),
constraint fk_ctpn_pn foreign key (mapn) references phieunhap(mapn),
constraint fk_ctpn_hg foreign key (mahg) references hang(mahg))

create table hoadon(
mahd varchar(10),
ngayban date,
makh varchar(10),
tienban int,
giamgia float,
thanhtoan float,
constraint pk_hd primary key (mahd),
constraint fk_hd_kh foreign key (makh) references khachhg(makh))

create table chitiethd(
mahd varchar(10),
mahg varchar(10),
soluong int,
giaban float,
thanhtien float,
constraint pk_cthd primary key (mahd,mahg),
constraint fk_cthd_hd foreign key (mahd) references hoadon(mahd),
constraint fk_cthd_hg foreign key (mahg) references hang(mahg))

create table donggia(
mahg varchar(10),
ngaycn date,
gia float,
constraint pk_dg primary key (mahg,ngaycn),
constraint fk_dg_hg foreign key (mahg) references hang (mahg))

insert into khachhg (makh, tenkh, dc, dt) values
('KH01', n'Nguyễn Văn A', n'Quận 1, TP.HCM', '0901234567'),
('KH02', n'Trần Thị B', n'Quận 3, TP.HCM', '0902345678'),
('KH03', n'Lê Văn C', n'Hà Đông, Hà Nội', '0903456789')

insert into nhasx (mansx, tennxs, dc, dt) values
('NSX01', n'Samsung', n'Hàn Quốc', '028111222'),
('NSX02', n'Apple', n'Mỹ', '028333444'),
('NSX03', n'Sony', n'Nhật Bản', '028555666')

insert into ncc (mancc, tenncc, dc, dt) values
('NCC01', n'Thế Giới Di Động', n'TP.HCM', '18001060'),
('NCC02', n'FPT Shop', n'Hà Nội', '18006601')

insert into hang (mahg, tenhg, dvt, soluongton, mansx, tinhtrang) values
('HG01', n'Galaxy S24', 1, 50, 'NSX01', n'Mới'),
('HG02', n'iPhone 15', 1, 30, 'NSX02', n'Mới'),
('HG03', n'Tai nghe Sony', 1, 100, 'NSX03', n'Mới'),
('HG04', n'iPad Pro', 1, 10, 'NSX02', n'Cũ')

insert into phieunhap (mapn, ngaynhap, mancc, tiennhap) values
('PN01', '10/01/2026', 'NCC01', 500000000),
('PN02', '15/02/2026', 'NCC02', 300000000)

insert into hoadon (mahd, ngayban, makh, tienban, giamgia, thanhtoan) values
('HD01', '01/03/2026', 'KH01', 25000000, 0.05, 23750000),
('HD02', '02/03/2026', 'KH02', 45000000, 0, 45000000),
('HD03', '05/03/2026', 'KH01', 15000000, 0.1, 13500000)

insert into chitiethd (mahd, mahg, soluong, giaban, thanhtien) values
('HD01', 'HG01', 1, 25000000, 25000000),
('HD02', 'HG02', 1, 30000000, 30000000),
('HD02', 'HG03', 2, 7500000, 15000000),
('HD03', 'HG03', 2, 7500000, 15000000)

insert into donggia (mahg, ngaycn, gia) values
('HG01', '01/03/2026', 25000000),
('HG02', '01/03/2026', 30000000),
('HG03', '01/03/2026', 7500000),
('HG04', '01/03/2026', 28000000)
-- cau a
go

create trigger kt_pn_ngaynhap on phieunhap 
for insert
as begin 
    if exists (select 1 from inserted where cast(ngaynhap as date) <> cast(getdate() as date))
    begin 
        print 'loi'
        rollback tran
    end
end
-- cau b
go

create trigger kt_ngayban on hoadon
for insert
as begin
    if exists (select 1 from inserted where cast(ngayban as date)<>cast(getdate() as date))
    begin 
        print 'loi'
        rollback tran
    end
end
-- cau c
go

create trigger kt_nhaphang on chitietpn
for insert
as begin 
    update c
    set c.thanhtien=i.soluong*i.gianhap
    from chitietpn c
    join inserted i on i.mapn = c.mapn and i.mahg = c.mahg

    update pn
    set pn.tiennhap=(select sum(thanhtien) from chitietpn c where c.mapn = pn.mapn)
    from phieunhap pn
    join inserted i on i.mapn = pn.mapn

    update hg
    set hg.soluongton=hg.soluongton+i.soluong 
    from hang hg, inserted i
    where i.mahg=hg.mahg
end
go

create trigger kt_banhang on chitiethd
for insert 
as begin 
    if exists (select 1 from hang hg, inserted i where i.mahg=hg.mahg and i.soluong>hg.soluongton)
    begin 
        print 'khong du hang de ban'
        rollback tran
    end

     update cthd
        set cthd.giaban = dg.gia
        from chitiethd cthd
        join inserted i on cthd.mahd = i.mahd and cthd.mahg = i.mahg
        join donggia dg on i.mahg = dg.mahg
        where dg.ngaycn = (
            select max(ngaycn) 
            from donggia 
            where mahg = i.mahg
        )
    

    update cthd
    set cthd.thanhtien=cthd.soluong*cthd.giaban
    from chitiethd cthd
    join inserted i on i.mahd=cthd.mahd and i.mahg=cthd.mahg

    update hd
    set hd.tienban=(select sum(thanhtien) from chitiethd cthd where cthd.mahd=hd.mahd)
    from hoadon hd
    join inserted i on hd.mahd=i.mahd

    update hg
    set hg.soluongton=hg.soluongton-i.soluong
    from hang hg, inserted i
    where hg.mahg=i.mahg

    if exists (select 1 from hang hg, inserted i where hg.mahg=i.mahg and hg.soluongton=0)  
    begin
        update hg
        set hg.tinhtrang=n'hết hàng'
        from hang hg,inserted i
        where i.mahg=hg.mahg and hg.soluongton=0
    end

    if exists(select 1 from hoadon hd, inserted i where i.mahd=hd.mahd and hd.tienban >=200000 and hd.tienban<500000)
    begin 
        update hd 
        set hd.giamgia=0.05
        from hoadon hd, inserted i
        where hd.mahd=i.mahd and hd.tienban >=200000 and hd.tienban<500000
    end
    else if exists( select 1 from hoadon hd, inserted i  where i.mahd=hd.mahd and hd.tienban>=500000)
    begin 
        update hd
        set hd.giamgia=0.1
        from hoadon hd, inserted i
        where i.mahd=hd.mahd and hd.tienban>=500000
    end
    else 
    begin
        update hd
        set hd.giamgia=0
        from hoadon hd, inserted i
        where i.mahd=hd.mahd 
    end 
    update hd
    set hd.thanhtoan=hd.tienban-hd.tienban*hd.giamgia
    from hoadon hd, inserted i
    where i.mahd=hd.mahd
end
-- cau 2a
go

create proc hd_khach 
@makh varchar(10)
as begin
    select * from hoadon hd where hd.makh=@makh
    end
-- cau b
go

create proc ngaylaphd
@mahd varchar(10)
as begin 
    select ngayban, tienban from hoadon hd where hd.mahd=@mahd
    end
-- cau c
go

create proc pro_hang
@mahg varchar(10)
as begin
    select tenhg,soluongton,tennxs from hang hg, nhasx nsx where hg.mahg= @mahg and hg.mansx=nsx.mansx
    end
-- cau d
go

create proc pro_dshg 
@mansx varchar(10)
as begin
    select mahg,tenhg,dvt from nhasx nsx, hang hg where hg.mansx=nsx.mansx and nsx.mansx=@mansx
    end
-- cau e
go

create proc pro_kh_hd
@mahd varchar(10)
as begin 
    select * from khachhg k, hoadon hd where hd.makh=k.makh and hd.mahd=@mahd
    end
-- cau f
go

create proc pro_ghichukh
@makh varchar(10)
as begin 
    declare @doanhso float
    select @doanhso=sum(hd.thanhtoan)
    from hoadon hd
    where hd.makh=@makh
    if @doanhso>=10000000
        select 'VIP'
    else if @doanhso>=6000000 and @doanhso<10000000
        select n'KH thành viên'
    else 
        select n'KH thân thiết'
end
-- cau g
go

create proc sp_tra_ve_dongia_moinhat @mahg varchar(10)
as
begin
    select gia
    from donggia
    where mahg = @mahg and ngaycn = (
        select max(ngaycn)
        from donggia
        where mahg = @mahg
    )
end
-- cau 3a
go

create function fun_slhd (@makh varchar(10))
returns int 
as begin
    declare @soluong int 
    set @soluong=(select count(*) from hoadon where makh=@makh)
    return isnull(@soluong, 0)
    end
-- cau b
go

create function fun_gthd(@mahd varchar(10))
returns int
as begin 
    declare @giatrihd int
    set @giatrihd=(select tienban from hoadon where mahd=@mahd)
    return isnull(@giatrihd, 0)
    end
-- cau c
go

create function fun_tongsoban(@mahg varchar(10),@ngayban date)
returns int
as begin 
    declare @tongslban int
    set @tongslban=(select sum(c.soluong) from hoadon hd, chitiethd c where c.mahd=hd.mahd and c.mahg=@mahg and hd.ngayban=@ngayban)
    return isnull(@tongslban, 0)
    end
-- cau d
go

create function fun_dskh(@makh varchar(10))
returns int
as begin 
    declare @dskh float 
    select @dskh =sum(cast(thanhtoan as float))
    from hoadon
    where makh=@makh
    return isnull(@dskh, 0)
end
-- cau e
go

create function fun_dsmathang(@mancc varchar(10))
returns table 
as return
    (select hg.mahg,tenhg,sum(ctpn.soluong) as tongsoluong from hang hg join chitietpn ctpn on ctpn.mahg=hg.mahg join phieunhap pn on pn.mapn=ctpn.mapn where pn.mancc=@mancc group by hg.mahg,tenhg )
-- cau f
go

create function fun_dscacmathang(@mahd varchar(10))
returns table
as return 
    (select hg.mahg,hg.tenhg,cthd.soluong,cthd.giaban,cthd.thanhtien from hang hg join chitiethd cthd on cthd.mahg=hg.mahg join hoadon hd on hd.mahd=cthd.mahd where hd.mahd=@mahd) 
-- cau g
go

create function fun_thongtin_chitiet (@mahg varchar(10))
returns table 
as return
(
    select 
        hg.mahg, 
        hg.tenhg,
        (select sum(soluong) from chitietpn where mahg = hg.mahg) as soluongnhap,
        (select sum(soluong) from chitiethd where mahg = hg.mahg) as soluongxuat,
        hg.soluongton as soluongconlai
    from hang hg
    where hg.mahg = @mahg
)
go

