--1
/*
a) Kreirati bazu Indeks.
*/
CREATE DATABASE Indeks
USE Indeks

/*
b) U bazi indeks kreirati sljedeće tabele:
1. Narudzba koja će se sastojati od polja:
2. Dobavljac
3. Proizvod
*/
create table Narudzba
(
NarudzbaID int not null,
DatumNarudzbe date,
DatumPrijema date,
DatumIsporuke date,
TrosakPrevoza money,
PunaAdresa nvarchar(70),
constraint PK_narudzba primary key (NarudzbaID)
)
create table Dobavljac
(
DobavljacID int not null,
NazivDobavljaca nvarchar(40) not null,
PunaAdresa nvarchar(60),
Drzava nvarchar(15),
constraint PK_dobavljac primary key (DobavljacID)
)

create table Proizvod 
(
NarudzbaID int not null,
DobavljacID int not null,
ProizvodID int not null,
NazivProizvoda nvarchar(40) not null,
Cijena int not null,
Kolicina int not null,
Popust decimal not null,
Raspolozivost bit not null,
constraint PK_proizvod primary key (NarudzbaID,DobavljacID,ProizvodID),
constraint FK_p_narudzba foreign key (NarudzbaID) references Narudzba(NarudzbaID),
constraint FK_p_dobavljac foreign key (DobavljacID) references Dobavljac(DobavljacID)
)
create table Proizvod_1
(
NarudzbaID int not null,
DobavljacID int not null,
ProizvodID int not null,
NazivProizvoda nvarchar(40) not null,
Cijena int not null,
Kolicina int not null,
Popust decimal not null,
Raspolozivost bit not null,
constraint PK_proizvodd primary key (NarudzbaID,DobavljacID,ProizvodID),
constraint FK_p_narudzbaa foreign key (NarudzbaID) references Narudzba(NarudzbaID),
constraint FK_p_dobavljacc foreign key (DobavljacID) references Dobavljac(DobavljacID)
)

--2
/*a) U tabelu Narudzba insertovati podatke iz tabele Orders baze Northwind pri čemu će puna adresa biti sačinjena od adrese, poštanskog broja i grada isporuke.
Između dijelova adrese umetnuti prazno mjesto. Ukoliko nije unijeta vrijednost poštanskog broja zamijeniti je sa 00000. 
Uslov je da se insertuju zapisi iz 1997. i većih godina (1998, 1999...), te da postoji datum isporuke. Zapise sortirati po vrijednosti troška prevoza.
*/
select * from NORTHWND.dbo.Orders
insert into Narudzba
select o.OrderID,o.OrderDate,o.RequiredDate,o.ShippedDate,o.Freight,
		o.ShipAddress+' '+ISNULL(o.ShipPostalCode,'00000')+' '+o.ShipCity as PunaAdresa
from NORTHWND.dbo.Orders as o
where YEAR(o.OrderDate)>=1997 and ShippedDate is not null

--RJ: 657

/*
b) U tabelu Dobavljac insertovati zapise iz tabele Suppliers. Puna adresa će se sastojati od adrese, poštanskog broja i grada dobavljača.
*/
insert into Dobavljac
select s.SupplierID,s.CompanyName,s.Address+s.PostalCode+s.City as PunaAdresa, s.Country
from NORTHWND.dbo.Suppliers as s
--RJ: 29

/*
c) U tabelu Proizvod insertovati zapise iz odgovarajućih kolona tabela Order Details i Product uz uslov da vrijednost cijene bude veća od
10, te da je na proizvod odobren popust. S obzirom na zadatak 2a voditi računa o postavljanju odgovarajućeg uslova da ne bi došlo do
konflikta u odnosu na NarudzbaID - potrebno je postaviti uslov da se insertuju zapisi iz 1997. i većih godina (1998, 1999...), te da postoji datum isporuke.
*/
select * from NORTHWND.dbo.[Order Details]
select * from NORTHWND.dbo.Products
select * from NORTHWND.dbo.Orders
insert into Proizvod
select OD.OrderID,P.SupplierID,  P.ProductID,P.ProductName, OD.UnitPrice, OD.Quantity, OD.Discount, P.Discontinued
from NORTHWND.dbo.Products as P join  NORTHWND.dbo.[Order Details] as OD 
on P.ProductID=OD.ProductID
join NORTHWND.dbo.Orders o
on o.OrderID=OD.OrderID
where OD.UnitPrice>10 and OD.Discount>0 and YEAR(o.OrderDate)>=1997 and o.ShippedDate is not null
order by OD.UnitPrice


insert into Proizvod_1
SELECT	OD.OrderID,  P.SupplierID, P.ProductID, P.ProductName, OD.UnitPrice, OD.Quantity, OD.Discount, P.Discontinued
FROM	NORTHWND.dbo.[Order Details] AS OD INNER JOIN NORTHWND.dbo.Products AS P
ON		OD.ProductID = P.ProductID
			INNER JOIN NORTHWND.dbo.Orders AS O
			ON OD.OrderID = O.OrderID
WHERE	OD.Quantity > 10 AND OD.Discount > 0 AND YEAR (O.OrderDate) > 1996 AND O.ShippedDate IS NOT NULL
--RJ: 521

--3
/*
Iz tabele Proizvod dati pregled ukupnog broja ostvarenih narudzbi po dobavljaču i proizvodu.
*/
select DobavljacID,ProizvodID,COUNT(*) prebrojano
from Proizvod_1
group by DobavljacID,ProizvodID
--RJ: 76

--4
/*
Iz tabele Proizvod dati pregled ukupnog prometa ostvarenog po dobavljaču i narudžbi uz uslov da se prikažu samo oni zapisi kod kojih je vrijednost
prometa manja od 1000 i odobreni popust veći od 10%. Ukupni promet izračunati uz uzimanje u obzir i odobrenog popusta.
*/
select * from Proizvod_1

select DobavljacID,NarudzbaID,Popust,sum(Cijena*Kolicina*(1-Popust)) as ukupni_promet
from Proizvod_1
where Popust>0.10
group by DobavljacID,NarudzbaID,Popust
having SUM(Cijena*Kolicina*(1-Popust))<1000
--RJ: 242

--5
/*
Iz tabele Narudzba dati pregled svih narudzbi kod kojih je broj dana od datuma narudžbe do datuma isporuke manji od 10.
Pregled će se sastojati od ID narudžbe, broja dana razlike i kalendarske godine, pri čemu je razdvojiti pregled po godinama 
(1997 i 1998 - prvo sve 1997, zatim sve 1998). Sortirati po broju dana isporuke u opadajućem redoslijedu.
*/

--RJ: 495



select NarudzbaID,DATEDIFF (DAY, DatumNarudzbe, DatumIsporuke) as broj_dana_razlike, '1997' as godina
from Narudzba
where YEAR(DatumIsporuke)=1997 and DATEDIFF (DAY, DatumNarudzbe, DatumIsporuke) <10
union
select NarudzbaID,DATEDIFF (DAY, DatumNarudzbe, DatumIsporuke) as broj_dana_razlike, '1998' as godina
from Narudzba
where YEAR(DatumIsporuke)=1998 and DATEDIFF (DAY, DatumNarudzbe, DatumIsporuke) <10
order by 2 desc


 

--6
/*
Iz tabele Narudzba dati pregled svih narudzbi kod kojih je isporuka izvršena u istom mjesecu.
Pregled će se sastojati od ID narudžbe, broja dana razlike, mjeseca narudžbe, mjeseca isporuke i kalendarske godine, pri čemu je potrebno razdvojiti pregled po godinama 
(1997 i 1998 - prvo sve 1997, zatim sve 1998). Sortirati po broju dana isporuke u opadajućem redoslijedu.
*/

--RJ: 464
select NarudzbaID,DATEDIFF (DAY, DatumNarudzbe, DatumIsporuke) as broj_dana_razlike, MONTH(DatumNarudzbe) as mjesec_narudzbe,
		MONTH(DatumIsporuke) as mjesec_isporuke, '1997' as kalendarska_godina
from Narudzba
where YEAR(DatumIsporuke)=1997 and DATEDIFF (DAY, DatumNarudzbe, DatumIsporuke) <10 and MONTH(DatumIsporuke)=MONTH(DatumNarudzbe)
union
select NarudzbaID,DATEDIFF (DAY, DatumNarudzbe, DatumIsporuke) as broj_dana_razlike, MONTH(DatumNarudzbe) as mjesec_narudzbe,
		MONTH(DatumIsporuke) as mjesec_isporuke, '1998' as kalendarska_godina
from Narudzba
where YEAR(DatumIsporuke)=1998 and DATEDIFF (DAY, DatumNarudzbe, DatumIsporuke) <10 and MONTH(DatumIsporuke) = MONTH(DatumNarudzbe)
order by 2 desc

SELECT NarudzbaID, DATEDIFF (DAY, DatumNarudzbe, DatumIsporuke) AS BrDanaIsporuke, MONTH (DatumIsporuke) AS MjesecNarudzbe, MONTH (DatumNarudzbe) AS MjesecIsporuke, YEAR (DatumIsporuke) AS Godina
FROM Narudzba
WHERE MONTH (DatumIsporuke) = MONTH (DatumNarudzbe)
ORDER BY 5, 2
--7
/*Iz tabele Narudzba dati pregled svih narudžbi koje su isporučene u Graz ili Köln.
Pregled će se sastojati od ID narudžbe i naziva grada. Sortirati po nazivu grada. 
*/

--RJ: 31
select * from Narudzba

select NarudzbaID,'Graz' as Grad
from Narudzba
where PunaAdresa like '%Graz%'
union
select NarudzbaID,'Köln' as Grad
from Narudzba
where PunaAdresa like '%Köln%'
order by 2
--8
/*
Iz tabela Narudzba, Dobavljac i Proizvod kreirati pregled koji će se sastojati od polja NarudzbaID, GodNarudzbe kao godinu iz polja DatumNarudzbe, 
NazivProizvoda, NazivDobavljaca, Drzava, TrosakPrevoza, Ukupno kao ukupna vrijednost narudžbe koja će se računati uz uzimanje u obzir i popusta i postotak
koji će davati informaciju o vrijednosti postotka troška prevoza u odnosu na ukupnu vrijenost narudžbe.
Uslov je da postotak bude veći od 30% i da je ukupna vrijednost veća od troška prevoza. Sortirati po vrijednosti postotka u opadajućem redoslijedu.
*/
select n.NarudzbaID, YEAR(n.DatumNarudzbe) as GodNarudzbe,p.NazivProizvoda,
		d.NazivDobavljaca,d.Drzava,n.TrosakPrevoza,
		p.Cijena*p.Kolicina*(1-p.Popust) as Ukupno,
		left(ROUND((n.TrosakPrevoza/(p.Cijena*p.Kolicina*(1-p.Popust)))*100,2),5) as Postotak
from Narudzba n join Proizvod_1 p
on n.NarudzbaID=p.NarudzbaID
join Dobavljac d
on d.DobavljacID=p.DobavljacID
where ROUND((n.TrosakPrevoza/(p.Cijena*p.Kolicina*(1-p.Popust)))*100,2)>30 and p.Cijena*p.Kolicina*(1-p.Popust)>n.TrosakPrevoza
order by 8desc
--RJ: 104
SELECT	N.NarudzbaID, YEAR (N.DatumNarudzbe) AS GodNarudzbe, P.NazivProizvoda, D.NazivDobavljaca, D.Drzava, 
		N.TrosakPrevoza, P.Cijena * P.Kolicina * (1 - P.Popust) AS Ukupno, LEFT (ROUND (N.TrosakPrevoza / (P.Cijena * P.Kolicina * (1 - P.Popust)) * 100, 2),5) AS Postotak
FROM	Narudzba AS N INNER JOIN Proizvod AS P
ON		N.NarudzbaID = P.NarudzbaID
		INNER JOIN Dobavljac AS D
		ON P.DobavljacID = D.DobavljacID
WHERE	N.TrosakPrevoza > 0.3 * (P.Cijena * P.Kolicina * (1 - P.Popust)) AND N.TrosakPrevoza < (P.Cijena * P.Kolicina * (1 - P.Popust))
ORDER BY 8 DESC
--9
/*
Iz tabela Narudzba, Dobavljac i Proizvod kreirati pogled koji će sadržavati ID narudžbe, dan iz datuma prijema, raspoloživost, naziv grada iz pune adrese naručitelja,
i državu dobavljača. Uslov je da je datum prijema u 2. ili 3. dekadi mjeseca i da grad naručitelja Bergamo.
*/
go
create view pogled as
select N.NarudzbaID,day(N.DatumPrijema) as dan_prijema, P.Raspolozivost,
		D.Drzava, RIGHT(N.PunaAdresa,7) as grad
FROM	Narudzba AS N INNER JOIN Proizvod AS P
ON		N.NarudzbaID = P.NarudzbaID
		INNER JOIN Dobavljac AS D
		ON P.DobavljacID = D.DobavljacID
WHERE	DAY (N.DatumPrijema) BETWEEN 11 AND 31 AND RIGHT (N.PunaAdresa, 7) = 'Bergamo'
go
--RJ: 5

--10
/*
Iz tabela Proizvod i Dobavljac kreirati proceduru proc1 koja će sadržavati ID i naziv dobavljača i ukupan broj proizvoda
koji je realizirao dobavljač. Pokrenuti proceduru za vrijednost ukupno realiziranog broja proizvoda 22 i 14.
*/
USE Indeks
GO
CREATE PROCEDURE proc1
(
	@DobavljacID int = NULL,
	@NazivDobavljaca nvarchar(40) = NULL,
	@UkBroj int = NULL
)
AS
BEGIN
SELECT	P.DobavljacID, D.NazivDobavljaca, COUNT (P.ProizvodID) AS Broj
FROM	Proizvod AS P INNER JOIN Dobavljac AS D
ON		P.DobavljacID = D.DobavljacID
--WHERE	P.DobavljacID = @DobavljacID OR
--		NazivDobavljaca = @NazivDobavljaca OR
--		P.ProizvodID >= 0
GROUP BY P.DobavljacID, D.NazivDobavljaca
HAVING	COUNT (P.ProizvodID) = @UkBroj
END

exec proc1 @UkBroj = 14

exec proc1 @UkBroj = 22