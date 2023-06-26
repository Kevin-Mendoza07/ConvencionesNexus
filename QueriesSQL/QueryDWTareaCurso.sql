Create database DWConvencionesNexus 

use DWConvencionesNexus
go

create table DimEvento(
DimEventoID int primary key identity(1,1),
IdEvento int,
NombreCliente varchar(200) null,
Descripcion varchar(50) null,
Estado varchar(50) null,
FechaInicial date,
FechaFinal date
)

create table DimCliente(
DimClienteID int primary key identity(1,1), 
IdCliente int,
[Nombre] varchar(50) NULL,
[Apellido] varchar(50) NULL,
[Telefono] varchar(10) NULL,
[Direccion] varchar(100) NULL,
FechaInicial date,
FechaFinal date
)

create table DimEmpleado(
DimEmpleadoID int primary key identity(1,1),
IdEmpleado int,
[Nombre] [varchar](50) NULL,
[Apellido] [varchar](50) NULL,
[Telefono] [varchar](50) NULL,
[Direccion] [varchar](50) NULL,
FechaInicial date,
FechaFinal date
)

create table DimFecha(
DimFechaID int primary key identity(1,1),
[FechaID] date NULL,
[Año] int NULL,
[NoMes] int NULL,
[NombreMes] nvarchar(50) NULL,
[Dia] [int] NULL,
[NombreDia] nvarchar(50) NULL,
[Trimestre] int NULL
)

create table HechosPago(
DimEventoID int not null,
DimClienteID int not null,
DimEmpleadoID int not null,
DimFechaID int not null,
[Cantidad Pagos] int,
[Cantidad Salones] int,
[Cantidad de Horas] int,
[Numero de personas] int,
[Cantidad Servicios] int,
[Costo Salon x HorasReservada] float,
[Costo Servicios] float,
[Porcentaje Descuento] float,
[Descuento] float,
[MontoTotal] float
)

use DWConvencionesNexus

select *from DimEvento
select *from DimFecha
select *from HechosPago
select *from DimCliente
select *from DimEmpleado


-- Carga de Tabla de Hechos 
DBCC CHECKIDENT (DimFecha, RESEED,0)
DBCC CHECKIDENT (DimCliente, RESEED,0)
DBCC CHECKIDENT (DimEmpleado, RESEED,0)
DBCC CHECKIDENT (DimEvento, RESEED,0)
----------------------------------------------------------
Merge dbo.HechosPago Destino 
Using 
(Select 
df.DimFechaID,
dc.DimClienteID,
dem.DimEmpleadoID,
de.DimEventoID,
count(*) as [Cantidad Pagos],
(select count(*) from ConvencionesNexus.dbo.Evento_Salon es
where es.IdEvento = e.IdEvento) as [Cantidad Salones],
sum(e.CantidadHorasReserva) as [Cantidad de Horas],
sum(e.NoPersonas) as [Numero de personas],
(select count(*) from ConvencionesNexus.dbo.Evento_Servicio esr
where esr.IdEvento = e.IdEvento) as [Cantidad Servicios],
(select sum(es.CostoSalon*e1.CantidadHorasReserva) from ConvencionesNexus.dbo.Evento_Salon es
INNER JOIN ConvencionesNexus.dbo.Evento e1 ON es.IdEvento = e1.IdEvento
where e1.IdEvento = e.IdEvento) as [Costo Salon x HorasReservada],
(select sum(s.Costo) from ConvencionesNexus.dbo.Evento_Servicio esr
inner join ConvencionesNexus.dbo.Servicio s on s.IdServicio = esr.IdServicio
where esr.IdEvento = e.IdEvento) as [Costo Servicios],
sum(p.Descuento) as [Porcentaje Descuento],
sum(p.Descuento*p.Monto) as [Descuento],
sum(p.Monto) as MontoTotal
from ConvencionesNexus.dbo.Pago p
inner join ConvencionesNexus.dbo.Evento e
on e.IdEvento=p.IdEvento
inner join DimFecha df on df.FechaID=e.FechaEvento
inner join DimCliente dc on dc.DimClienteID=e.IdCliente
inner join DimEvento de on de.DimEventoID= p.IdEvento
inner join DimEmpleado dem on dem.DimEmpleadoID=e.IdEmpleado
WHERE dc.FechaFinal='9999/12/31' AND 
	  de.FechaFinal='9999/12/31' AND
	  dem.FechaFinal='9999/12/31'
group by 
df.DimFechaID,
dc.DimClienteID,
de.DimEventoID,
dem.DimEmpleadoID,
e.IdEvento) Origen 
on 
Destino.DimFechaID = Origen.DimFechaID and 
Destino.DimClienteID = Origen.DimClienteID and 
Destino.DimEmpleadoID = Origen.DimEmpleadoID and
Destino.DimEventoID = Origen.DimEventoID
WHEN MATCHED AND( Destino.[Cantidad Pagos] <> Origen.[Cantidad Pagos] or
				  Destino.[Cantidad de Horas] <> Origen.[Cantidad de Horas] or 
				  Destino.[Cantidad Salones] <> Origen.[Cantidad Salones] or
				  Destino.[Numero de Personas] <> Origen.[Numero de Personas] or
				  Destino.[Cantidad Servicios] <> Origen.[Cantidad Servicios] or
				  Destino.[Costo Salon x HorasReservada] <> Origen.[Costo Salon x HorasReservada] or 
				  Destino.[Costo Servicios] <> Origen.[Costo Servicios] or 
				  Destino.[Porcentaje Descuento] <> Origen.[Porcentaje Descuento]or
				  Destino.Descuento <> Origen.Descuento or 
				  Destino.MontoTotal <> Origen.MontoTotal)
				  Then
				  Update set 
				  Destino.[Cantidad Pagos] = Origen.[Cantidad Pagos],
				  Destino.[Cantidad de Horas] = Origen.[Cantidad de Horas],
				  Destino.[Cantidad Salones] = Origen.[Cantidad Salones],
				  Destino.[Numero de Personas] = Origen.[Numero de Personas],
				  Destino.[Cantidad Servicios] = Origen.[Cantidad Servicios],
				  Destino.[Costo Salon x HorasReservada] = Origen.[Costo Salon x HorasReservada],
				  Destino.[Costo Servicios] = Origen.[Costo Servicios], 
				  Destino.Descuento = Origen.Descuento, 
				  Destino.MontoTotal = Origen.MontoTotal
WHEN NOT MATCHED THEN
				INSERT(DimFechaID,DimClienteID,DimEmpleadoID,DimEventoID,[Cantidad Pagos],[Cantidad de Horas],
				[Cantidad Salones],[Numero de Personas],[Cantidad Servicios],[Costo Salon x HorasReservada],
				[Costo Servicios],[Porcentaje Descuento],Descuento,MontoTotal)
				Values(Origen.DimFechaID, Origen.DimClienteID, Origen.DimEmpleadoID,Origen.DimEventoID,
				Origen.[Cantidad Pagos],Origen.[Cantidad de Horas],Origen.[Cantidad Salones],
				Origen.[Numero de Personas],Origen.[Cantidad Servicios],
				Origen.[Costo Salon x HorasReservada],Origen.[Costo Servicios],
				Origen.[Porcentaje Descuento],Origen.Descuento,Origen.MontoTotal);