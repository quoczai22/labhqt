create database DB1 
on primary 
 (
 name=DB1_data,
 filename='E:\LuuDuLieuSinhVien\SANGTHU4_THHQTCSDL\DB1_data.mdf',
 size=30mb,
 maxsize=100mb,
 filegrowth=5mb
 ),
 filegroup nhom1 (
 name=DB1_second,
 filename='E:\LuuDuLieuSinhVien\SANGTHU4_THHQTCSDL\DB1_second.ndf',
 size=10mb,
 maxsize=20mb,
 filegrowth=15%
 )
 log on
 (
 name=DB1_log,
 filename='E:\LuuDuLieuSinhVien\SANGTHU4_THHQTCSDL\DB1_log.ldf',
 size=20mb,
 maxsize=500mb,
 filegrowth=15%
 )

 exec sp_spaceused 

 alter database DB1
 add filegroup nhom2

 alter database DB1
 add file (
 name=db1_second2,
 filename ='E:\LuuDuLieuSinhVien\SANGTHU4_THHQTCSDL\db1_second2.ndf',
 size=10mb,
 maxsize=20mb,
 filegrowth=10%
 ) to filegroup nhom2

 alter database DB1
 modify file (name=db1_second2,size=15mb) 


 dbcc shrinkfile 
 (
 DB1_data,20
 )
