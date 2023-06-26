
-- Esquema Estrella para Datamart 

--1. Propuesta
-- Tablas Dimensiones
-- DimEvento
-- DimCliente
-- DimEmpleado
-- DimFecha

-- Tabla de Hechos
-- HechosPago

use ConvencionesNexus

Select *from Pago
Select *from Evento

Create view DimEvento
as
Select 
e.IdEvento,
c.Nombre+' '+c.Apellido as [Nombre Cliente],
e.Descripcion,
e.Estado
from Evento e inner join Cliente c
on e.IdCliente=c.IdCliente
------------------------------------------------------------
Create view DimCliente 
as
Select *from Cliente
------------------------------------------------------------
Create view DimEmpleado
as
Select *from Empleado
-------------------------------------------------------------
Create view DimFecha 
as
Select 
e.FechaEvento as FechaID,
year(e.FechaEvento) as Año,
month(e.FechaEvento) as NoMes,
day(e.FechaEvento) as NoDia,
datename(weekday,e.FechaEvento) as [Nombre Dia],
datename(month,e.FechaEvento) as [Nombre Mes],
datepart(qq,e.FechaEvento) as Trimestre
from Evento e
-----------------------------------------------------------------

Create view HechosPago
as
Select 
-- Llaves Foraneas 
e.IdEvento,
e.IdCliente,
em.IdEmpleado,
e.FechaEvento as FechaID,

-- Valores de Medida 
count(*) as [Cantidad Pagos],
(select count(*) from ConvencionesNexus.dbo.Evento_Salon es
where es.IdEvento = e.IdEvento) as [Cantidad Salones],
sum(e.CantidadHorasReserva) as [Cantidad de Horas],
sum(e.NoPersonas) as [Numero de personas],
(select count(*) from ConvencionesNexus.dbo.Evento_Servicio esr
where esr.IdEvento = e.IdEvento) as [Cantidad Servicios],
(select sum(es.CostoSalon*e1.CantidadHorasReserva) from ConvencionesNexus.dbo.Evento_Salon es
INNER JOIN ConvencionesNexus.dbo.Evento e1 ON es.IdEvento = e1.IdEvento
where e1.IdEvento = e.IdEvento) as [Costo Salones],
(select sum(s.Costo) from ConvencionesNexus.dbo.Evento_Servicio esr
inner join ConvencionesNexus.dbo.Servicio s on s.IdServicio = esr.IdServicio
where esr.IdEvento = e.IdEvento) as [Costo Servicios],
sum(p.Descuento) as [Porcentaje Descuento],
SUM(p.Descuento*p.Monto) AS Descuento,
sum(p.Monto) as MontoTotal

from Pago p inner join 
Evento e on p.IdEvento=e.IdEvento
inner join Empleado em on em.IdEmpleado=e.IdEmpleado
group by 
e.IdEvento,
e.IdCliente,
em.IdEmpleado,
e.FechaEvento







