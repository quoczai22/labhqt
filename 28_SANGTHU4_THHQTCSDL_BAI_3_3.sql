create database ql_sinhvien
go
 use ql_sinhvien

 create table lop (
 malop varchar(10),
 tenlop nvarchar(30),
 siso int,
 constraint pk_lop primary key (malop)
 )

 set dateformat dmy
 create table sinhvien(
 masv varchar(10),
 hoten nvarchar(30),
 ngsinh date ,
 gioitinh nvarchar(4),
 quequan nvarchar(30),
 malop varchar(10),
 diemtb float,
 xeploai nvarchar(10),
 constraint pk_sinhvien primary key (masv),
 constraint fk_sv_lop foreign key (malop) references lop (malop))

 create table monhoc(
 mamh varchar(10),
 tenmh nvarchar(30),
 sotc int,
 batbuoc nvarchar(5),
 constraint pk_mh primary key (mamh))

 create table ketqua(
 masv varchar(10),
 mamh varchar(10),
 hocky nvarchar(10),
 diemthi float,
 constraint pk_kq primary key (masv,mamh,hocky),
 constraint fk_kq_sinhvien foreign key (masv) references sinhvien(masv),
 constraint fk_kq_mh foreign key(mamh) references monhoc(mamh),
 )
-- du lieu bang lop
insert into lop (malop, tenlop, siso) values
('CNTT01', n'Công nghệ thông tin 1', 45),
('KTPM02', n'Kỹ thuật phần mềm 2', 40),
('KHMT01', n'Khoa học máy tính 1', 35)
-- du lieu bang sinhvien

set dateformat dmy
insert into sinhvien (masv, hoten, ngsinh, gioitinh, quequan, malop, diemtb, xeploai) values
('SV01', n'Nguyễn Văn A', '15/05/2004', n'Nam', n'Hà Nội', 'CNTT01', 8.5, n'Giỏi'),
('SV02', n'Trần Thị B', '20/10/2004', n'Nữ', n'Đà Nẵng', 'CNTT01', 7.2, n'Khá'),
('SV03', n'Lê Hoàng C', '02/02/2003', n'Nam', n'TP.HCM', 'KTPM02', 6.0, n'Trung bình'),
('SV04', n'Phạm Minh D', '12/12/2004', n'Nam', n'Cần Thơ', 'KHMT01', 9.1, n'Xuất sắc')
-- du lieu bang monhoc
insert into monhoc (mamh, tenmh, sotc, batbuoc) values
('CSDL', n'Cơ sở dữ liệu', 3, n'Có'),
('CTDL', n'Cấu trúc dữ liệu', 4, n'Có'),
('TRR', n'Toán rời rạc', 3, n'Không')
-- du lieu bang ketqua
insert into ketqua (masv, mamh, hocky, diemthi) values
('SV01', 'CSDL', 'HK1-2025', 9.0),
('SV01', 'CTDL', 'HK1-2025', 8.0),
('SV02', 'CSDL', 'HK1-2025', 7.5),
('SV03', 'CSDL', 'HK1-2025', 5.5),
('SV04', 'TRR', 'HK2-2025', 9.5)
-- cau 1a
go

create trigger trg_lop on sinhvien
for insert, update, delete
as
begin
    update l
    set siso = (
        select count(*)
        from sinhvien s
        where s.malop = l.malop
    )
    from lop l
    where l.malop in (
        select malop from inserted where malop is not null
        union
        select malop from deleted where malop is not null
    )
end;
-- cau b
go

create trigger tri_dangkymon on ketqua
for insert, update
as 
begin   
    if exists (
        select 1
        from inserted i
        join ketqua kq on i.masv = kq.masv and i.hocky = kq.hocky
        group by kq.masv, kq.hocky
        having count(kq.mamh) > 5
    )
    begin
        print 'moi sinh vien chi duoc dang ky toi da 5 mon trong moi hoc ky'
        rollback tran
    end
end
-- cau c
go

create trigger tri_dangkytc on ketqua
for insert, update
as
begin
    if exists (
        select 1
        from inserted i
        join ketqua kq on i.masv = kq.masv and i.hocky = kq.hocky
        join monhoc mh on mh.mamh = kq.mamh
        where mh.batbuoc = n'Có'
        group by kq.masv, kq.hocky
        having sum(mh.sotc) > 10
    )
    begin
        print 'moi sinh vien chi duoc dang ky toi da 10 tin chi cua mon hoc bat buoc trong moi hoc ky'
        rollback tran
    end
end
-- cau d
go

create trigger trg_ktra_dtb 
on ketqua
for insert, update, delete
as
begin
    set nocount on;

    update s
    set 
        s.diemtb = t.dtb_moi,
        s.xeploai = case
            when t.dtb_moi < 5 then n'Yếu'
            when t.dtb_moi < 7 then n'Trung bình'
            when t.dtb_moi < 8 then n'Khá'
            else n'Giỏi'
        end
    from sinhvien s
    join (
        select k.masv, 
               sum(k.diemthi * m.sotc) * 1.0 / sum(m.sotc) as dtb_moi
        from ketqua k
        join monhoc m on k.mamh = m.mamh
        where k.masv in (
            select masv from inserted
            union
            select masv from deleted
        )
        group by k.masv
    ) t on s.masv = t.masv;
end;
-- cau 2a
go

create proc themmotlop 
@tenlop nvarchar(30),
@malop varchar(10)
as begin
        if exists ( select 1 from lop where malop=@malop)
        begin 
        print 'ma lop da ton tai'
        return 
        end 
        insert into lop (malop, tenlop,siso) values(@malop,@tenlop,0)
        print 'them mot lop moi thanh cong'
        end
-- cau b
go

create proc them_mot_sv 
@masv varchar(10),
@tensv nvarchar(10)
as begin 
    if exists (select 1 from  sinhvien where masv=@masv)
    begin 
    print 'loi'
    end 
    insert into sinhvien (masv,hoten,diemtb,xeploai) values(@masv,@tensv,null,null)
    end
go

create proc sp_themsinhvien
    @masv varchar(10),
    @hoten nvarchar(30),
    @malop varchar(10)
as
begin
    set nocount on;
    if not exists (select 1 from lop where malop = @malop)
    begin
        print 'loi'
        return
    end

                insert into sinhvien (masv, hoten, malop)
            values (@masv, @hoten, @malop)
            update lop 
            set siso = (select count(masv) from sinhvien where malop=@malop)
            where malop = @malop
    end
-- cau d
go

create proc sp_congdiemsv
@masv varchar(10),
@mamh varchar(10),
@hocky nvarchar(10)
as begin 
update ketqua
    set diemthi = diemthi + 1
    where masv = @masv 
      and mamh = @mamh 
      and hocky = @hocky
    update ketqua
    set diemthi = 10
    where masv = @masv 
      and mamh = @mamh 
      and hocky = @hocky 
      and diemthi > 10
    print 'thanh cong'
    end
-- cau e
go

create proc truyenmasv 
@masv varchar(10)
 as begin
    select 
        s.hoten,
        s.ngsinh,
        s.gioitinh,
        l.tenlop 
    from sinhvien s 
    join lop l on l.malop = s.malop 
    where s.masv = @masv
end
-- cau f
go

create proc travedtbxl
@masv varchar(10)
as begin 
select diemtb,xeploai from sinhvien
where masv=@masv
end
-- cau g
go

create proc dssvlop
@malop varchar(10)
as begin 
select s.masv,s.hoten from sinhvien s join lop l on l.malop=s.malop where l.malop=@malop
end
-- cau h
go

create proc tongsv
@mamh varchar(10),
@hocky nvarchar(10)
as begin
select count(s.masv) from sinhvien s join ketqua k on k.masv =s.masv 
where k.mamh=@mamh and k.hocky=@hocky 
end
-- cau i
go

create proc bathamso 
@masv varchar(10),
@mamh varchar(10),
@hocky nvarchar(10)
as begin 
set nocount on;
declare @diem float;
select @diem = diemthi 
    from ketqua 
    where masv = @masv 
      and mamh = @mamh 
      and hocky = @hocky;
if not exists (select 1 from ketqua where masv = @masv and mamh = @mamh and hocky = @hocky)
            begin            
                print 'chua dang ky'
            end
else if @diem is null
                begin 
                    print 'chua co diem'
                end
else if @diem >= 5
                begin 
                    print 'dat'
                end
else
                begin 
                    print 'khong dat'
                end
            end
-- cau j
go

create proc thutucj
@masv varchar(10),
@hocky nvarchar(10)
as begin 
declare @dtb float
set @dtb =(select avg(k.diemthi) from sinhvien s join ketqua k on k.masv=s.masv where s.masv=@masv and k.hocky=@hocky)
if @dtb>=8
begin 
select n'Khen thưởng' as ketqua, @dtb as diemtrungbinh;end
else 
begin 
select n'Không khen thưởng' as ketqua, @dtb as diemtrungbinh;
end
end
exec thutucj 'SV01', 'HK1-2025'
-- cau 3a
go

create function fn_sotinchi (@mamh varchar(10))
returns int 
as begin 
    declare @sotinchi int;
    set @sotinchi=(select sotc from monhoc where mamh=@mamh)
    if @sotinchi is null
         set @sotinchi=0;
    return @sotinchi;
end
-- cau b
go

create function fn_tongdtb (@masv varchar(10))
returns float
as begin 
    declare @tongdtb float
    set @tongdtb=(select sum(diemtb) from sinhvien where masv=@masv)
    if (@tongdtb<0 or @tongdtb is null)
        set @tongdtb=0;
    return @tongdtb;
    end
-- cau c
go

create function fn_tongsv (@mamh varchar(10), @hocky nvarchar(10))
returns int 
as begin
    declare @tongsv int
    set @tongsv= (select count( distinct masv) from ketqua k join monhoc m on m.mamh =k.mamh where @mamh=m.mamh and @hocky=k.hocky  )
    return isnull(@tongsv,0)
    end
-- cau d
go

create function fn_diemthisv (@masv varchar(10) , @mamh varchar(10), @hocky nvarchar(10))
returns float
as begin 
    declare @diemthisv float 
    set @diemthisv=(select diemthi from ketqua where masv=@masv and mamh=@mamh and hocky=@hocky)
   if (@diemthisv<0 or @diemthisv is null)
   set @diemthisv=0
   return @diemthisv
   end
-- cau e
go

create function fn_tongsotcsv (@masv varchar(10), @hocky nvarchar(10))
returns int 
as begin 
    declare @tongsotcsv int 
    set @tongsotcsv =(select sum(sotc) from monhoc m join ketqua k on k.mamh=m.mamh where k.masv=@masv and k.hocky=@hocky and k.diemthi>=5 )
    return  isnull (@tongsotcsv,0)
    end
-- cau f
go

create function fn_danhsachsv (@malop varchar(10))
returns table
as return 
(select masv,hoten, ngsinh from sinhvien where malop=@malop)
-- cau g
go

create function fn_danhsachsvduoitb (@mamh varchar(10), @hocky nvarchar(10))
returns table 
as return
(select s.masv,hoten, ngsinh,tenlop from sinhvien s join lop l on l.malop=s.malop join ketqua k on k.masv=s.masv where mamh=@mamh and hocky=@hocky and diemthi<5)
-- cau h
go

create function fn_dssvchuadk (@mamh varchar(10))
returns table 
as return 
(select s.masv,hoten,ngsinh from sinhvien s where not exists (
        select 1 
        from ketqua k 
        where k.masv = s.masv 
          and k.mamh = @mamh
    ))
-- cau i
go

create function fn_danhsachmh (@masv varchar(10))
returns table 
as return 
(select m.mamh,tenmh,max(k.diemthi) as diemcaonhat  from monhoc m join ketqua k on k.mamh=m.mamh where masv=@masv group by m.mamh,tenmh)
go

