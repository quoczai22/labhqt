-- bai 3.4
use master

create database ql_tv
go
use ql_tv

set dateformat dmy
create table sach(
mash varchar(10),
tensh nvarchar(30),
tacgia nvarchar(30),
loai nvarchar(10),
tinhtrang int,
constraint pk_sach primary key (mash))

create table docgia(
madg varchar(10),
tendg nvarchar(30),
ngsinh date ,
phai nvarchar(5),
diachi nvarchar(30),
constraint pk_dg primary key (madg))

create table muonsach(
madg varchar(10),
mash varchar(10),
ngaymuon date,
ngaytra date,
constraint pk_ms primary key (madg,mash,ngaymuon),
constraint fk_ms_dg foreign key (madg) references docgia(madg),
constraint fk_ms_sh foreign key (mash) references sach(mash))

insert into sach (mash, tensh, tacgia, loai, tinhtrang) values
('S01', n'Đắc Nhân Tâm', 'Dale Carnegie', n'Kỹ năng', 1),
('S02', n'Lược sử thời gian', 'Stephen Hawking', n'Khoa học', 1),
('S03', n'Tôi thấy hoa vàng', n'Nguyễn Nhật Ánh', n'Văn học', 0),
('S04', n'Nhà giả kim', 'Paulo Coelho', n'Văn học', 1),
('S05', n'Lập trình SQL', 'Microsoft', n'Tin học', 0);

insert into docgia (madg, tendg, ngsinh, phai, diachi) values
('DG01', n'Nguyễn Văn An', '15/05/2005', n'Nam', n'TP. Hồ Chí Minh'),
('DG02', n'Trần Thị Bình', '20/10/2004', n'Nữ', n'Hà Nội'),
('DG03', n'Lê Minh Cường', '05/12/1998', n'Nam', n'Đà Nẵng'),
('DG04', n'Phạm Mỹ Hạnh', '12/02/2006', n'Nữ', n'Cần Thơ');

insert into muonsach (madg, mash, ngaymuon, ngaytra) values
('DG01', 'S01', '01/04/2026', '10/04/2026'), 
('DG01', 'S02', '15/04/2026', null),        
('DG02', 'S01', '20/04/2026', null),        
('DG03', 'S04', '10/03/2026', '20/03/2026'), 
('DG04', 'S02', '25/04/2026', null);        
-- cau 1a
go

create trigger kt_tuoi on docgia
for insert, update
as 
begin
    if exists (select 1 from inserted where datediff(year, ngsinh, getdate()) < 15)
    begin 
        print 'loi: phat hien doc gia duoi 15 tuoi. giao dich bi huy!';
        rollback transaction; 
    end
end
-- cau b
go

create trigger kt_phai on docgia 
for insert, update 
as begin 
    if exists (select 1 from inserted where phai not in (n'Nam', n'Nữ'))
    begin
        print 'loi: gioi tinh phai la nam hoac nu';
        rollback transaction;
    end
end
-- cau c
go

create trigger kt_loai on sach
for insert, update
as begin 
    if exists (select 1 from inserted where loai not in (n'Kỹ năng', n'Khoa học', n'Văn học', n'Tin học'))
    begin 
        print 'loi'
        rollback tran
    end
end
-- cau d
go

create trigger kt_muon on muonsach
for insert,update 
as begin 
if exists (
        select 1 
        from inserted i
        join muonsach m on i.madg = m.madg
        where m.ngaytra is null
        group by i.madg
        having count(m.mash) > 3
    )
    begin
        print 'loi: doc gia khong duoc muon qua 3 cuon sach chua tra!';
        rollback transaction;
    end
    update s
    set s.tinhtrang=0
    from sach s
    join inserted i on s.mash=i.mash
    print 'da cap nhat sach sang trang thai dang muon (0)'
end
-- cau e
go

create trigger kt_dg_tra on muonsach
for update 
as begin
    if update(ngaytra)
    begin
        update s
        set s.tinhtrang = 1 
        from sach s
        join inserted i on s.mash = i.mash
        where i.ngaytra is not null; 
        print 'he thong: da cap nhat tinh trang sach thanh chua muon (1).';
        end
end
-- cau 2a
go

create proc tenvadc 
@madg varchar(10)
as begin 
    if exists ( select 1 from docgia where madg=@madg)
    begin
        select tendg,diachi from docgia where madg=@madg
    end
    else 
    begin
        print 'loi'
    end
end
-- cau b
go

create proc nxb_tg 
@mash varchar(10)
as begin 
    if exists(select 1 from sach where mash=@mash)
    begin 
        select tensh,tacgia from sach where mash=@mash
        end
        else 
        begin 
        print 'loi'
        end
    end
-- cau c
go

create proc slsh_dgmuonchuatra
@madg varchar(10)
as begin 
    if exists (select 1 from muonsach where madg=@madg and ngaytra is null)
    begin 
        select count(mash) from muonsach where madg=@madg and ngaytra is null
    end
    else
    begin
    print 'doc gia khong no sach hoac ma khong ton tai'
    end
end
-- cau d
go

create proc dgdangmuonsh
@mash varchar(10)
as begin 
    if exists (select 1 from docgia d join muonsach m on m.madg=d.madg where mash=@mash)
        select tendg from docgia d join muonsach m on m.madg=d.madg where mash=@mash 
    else
        print ' chua muon'
    end 
-- cau e
go

create proc soshmadgmuon
@madg varchar(10),
@ngaymuon date
as begin 
    if exists (select 1 from muonsach where madg = @madg and ngaymuon = @ngaymuon)
        select count(mash)from muonsach where madg = @madg and ngaymuon = @ngaymuon
    else
        print 'khong co du lieu'
    end
-- cau f
go

create proc ngaymuongannhat 
@mash varchar(10)
as begin
    if exists (select 1 from muonsach where mash=@mash)
    begin
        declare @ngay int, @thang int, @nam int
        select @ngay=day(max(ngaymuon)),
               @thang=month(max(ngaymuon)),
               @nam=year(max(ngaymuon))
        from muonsach
        where mash=@mash
        select @ngay,@thang,@nam
    end
    else
    begin
        print 'loi'
    end
end
-- cau 3a
go

create function fn_tendg_dc (@madg varchar(10))
returns nvarchar(70)
as begin 
    declare @tendg nvarchar(30), @dc nvarchar(30)
    select @tendg=tendg,@dc=diachi from docgia where madg=@madg
    return isnull(@tendg, n'Không rõ tên') + ' - ' + isnull(@dc, n'Không rõ địa chỉ')
end 
-- cau b
go

create function fn_dsdgchuatra (@mash varchar(10))
returns table 
as return 
(select distinct d.madg,tendg from docgia d join muonsach m on m.madg=d.madg where ngaytra is null and mash=@mash)
-- cau c
go

create function fn_datungmuon(@mash varchar(10))
returns table 
as return 
(select distinct d.madg, tendg from docgia d join muonsach m on m.madg=d.madg where mash=@mash )
-- cau d
go

create function fn_tongsh (@madg varchar(10),@thang int)
returns table
as return 
(select count(mash)as tongsoluong from muonsach where madg=@madg and month(ngaymuon)=@thang) 
go

