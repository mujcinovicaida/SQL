----------------------------
--1.
----------------------------
/*
Kreirati bazu pod vlastitim brojem indeksa
*/
create database ispit
use ispit
-----------------------------------------------------------------------
--Prilikom kreiranja tabela voditi računa o njihovom međusobnom odnosu.
-----------------------------------------------------------------------
/*
a) 
Kreirati tabelu dobavljac sljedeće strukture:
	- dobavljac_id - cjelobrojna vrijednost, primarni ključ
	- dobavljac_br_rac - 50 unicode karaktera
	- naziv_dobavljaca - 50 unicode karaktera
	- kred_rejting - cjelobrojna vrijednost
*/
create table dobavljac
(
dobavljac_id int constraint PK_dobavljac primary key (dobavljac_id),
dobavljac_br_rac nvarchar(50),
naziv_dobavljaca nvarchar(50),
kred_rejting int
)

/*
b)
Kreirati tabelu narudzba sljedeće strukture:
	- narudzba_detalj_id - cjelobrojna vrijednost, primarni ključ
	- narudzba_id - cjelobrojna vrijednost
	- dobavljac_id - cjelobrojna vrijednost
	- dtm_narudzbe - datumska vrijednost
	- naruc_kolicina - cjelobrojna vrijednost
	- cijena_proizvoda - novčana vrijednost
*/
create table narudzba
(
narudzba_detalj_id int constraint PK_narudzba primary key (narudzba_detalj_id),
narudzba_id int,
dobavljac_id int,
dtm_narudzbe date,
naruc_kolicina int,
cijena_proizvoda money,
constraint FK_narudzba_d foreign key (dobavljac_id) references dobavljac(dobavljac_id)
)
/*
c)
Kreirati tabelu dobavljac_proizvod sljedeće strukture:
	- proizvod_id cjelobrojna vrijednost, primarni ključ
	- dobavljac_id cjelobrojna vrijednost, primarni ključ
	- proiz_naziv 50 unicode karaktera
	- serij_oznaka_proiz 50 unicode karaktera
	- razlika_min_max cjelobrojna vrijednost
	- razlika_max_narudzba cjelobrojna vrijednost
*/

--10 bodova
create table dobavljac_proizvod
(
proizvod_id int,
dobavljac_id int,
proiz_naziv nvarchar (50),
serij_oznaka_proiz nvarchar(50),
razlika_min_max int,
razlika_max_narudzba int,
constraint PK_dp primary key (proizvod_id,dobavljac_id),
constraint FK_dpd foreign key (dobavljac_id) references dobavljac(dobavljac_id)
)

----------------------------
--2. Insert podataka
----------------------------
/*
a) 
U tabelu dobavljac izvršiti insert podataka iz tabele Purchasing.Vendor prema sljedećoj strukturi:
	BusinessEntityID -> dobavljac_id 
	AccountNumber -> dobavljac_br_rac 
	Name -> naziv_dobavljaca
	CreditRating -> kred_rejting
*/
insert into dobavljac
select BusinessEntityID, AccountNumber, Name, CreditRating
from AdventureWorks2014.Purchasing.Vendor
/*
b) 
U tabelu narudzba izvršiti insert podataka iz tabela Purchasing.PurchaseOrderHeader i Purchasing.PurchaseOrderDetail prema sljedećoj strukturi:
	PurchaseOrderID -> narudzba_id
	PurchaseOrderDetailID -> narudzba_detalj_id
	VendorID -> dobavljac_id 
	OrderDate -> dtm_narudzbe 
	OrderQty -> naruc_kolicina 
	UnitPrice -> cijena_proizvoda
*/
select * from AdventureWorks2014.Purchasing.PurchaseOrderHeader
select * from AdventureWorks2014.Purchasing.PurchaseOrderDetail 

insert into narudzba
select pod.PurchaseOrderDetailID,pod.PurchaseOrderID, poh.VendorID, poh.OrderDate, pod.OrderQty, pod.UnitPrice
from AdventureWorks2014.Purchasing.PurchaseOrderHeader poh join AdventureWorks2014.Purchasing.PurchaseOrderDetail  pod
on poh.PurchaseOrderID = pod.PurchaseOrderID
/*
c) 
U tabelu dobavljac_proizvod izvršiti insert podataka iz tabela Purchasing.ProductVendor i Production.Product prema sljedećoj strukturi:
	ProductID -> proizvod_id 
	BusinessEntityID -> dobavljac_id 
	Name -> proiz_naziv 
	ProductNumber -> serij_oznaka_proiz
	MaxOrderQty - MinOrderQty -> razlika_min_max 
	MaxOrderQty - OnOrderQty -> razlika_max_narudzba
uz uslov da se dohvate samo oni zapisi u kojima se podatak u koloni rowguid tabele Production.Product završava cifrom.
*/
select * from AdventureWorks2014.Purchasing.ProductVendor
select * from AdventureWorks2014.Production.Product
insert into dobavljac_proizvod
select pv.ProductID, pv.BusinessEntityID, p.Name, p.ProductNumber, pv.MaxOrderQty- pv.MinOrderQty, pv.MaxOrderQty- pv.OnOrderQty
from AdventureWorks2014.Purchasing.ProductVendor pv join AdventureWorks2014.Production.Product p
on pv.ProductID=p.ProductID
where p.rowguid like '%[0-9]'
--10 bodova

----------------------------
--3.
----------------------------
/*
Koristeći sve tri tabele iz vlastite baze kreirati pogled view_dob_proiz sljedeće strukture:
	- dobavljac_id
	- proizvod_id
	- naruc_kolicina
	- cijena_proizvoda
	- razlika, kao razlika kolona razlika_min_max i razlika_max_narudzba 
Uslov je da se dohvate samo oni zapisi u kojima je razlika pozitivan broj ili da kreditni rejting 1.
*/
--10 bodova
go
create view view_dob_proiz as
select d.dobavljac_id,dp.proizvod_id, n.naruc_kolicina, n.cijena_proizvoda, dp.razlika_min_max-dp.razlika_max_narudzba as razlika
from dobavljac_proizvod dp join dobavljac d
on dp.dobavljac_id= d.dobavljac_id
join narudzba n
on n.dobavljac_id=d.dobavljac_id
where dp.razlika_min_max-dp.razlika_max_narudzba >0 or d.kred_rejting= 1

select * from view_dob_proiz
----------------------------
--4.
----------------------------
/*
Koristeći pogled view_dob_proiz kreirati proceduru proc_dob_proiz koja će sadržavati parametar razlika i imati sljedeću strukturu:
	- dobavljac_id
	- suma_razlika, sumirana vrijednost kolone razlika po dobavljac_id i proizvod_id
Uslov je da se dohvataju samo oni zapisi u kojima je razlika jednocifren ili dvocifren broj.
Nakon kreiranja pokrenuti proceduru za vrijednost razlike 2.
*/
--10 bodova
go
create procedure proc_dob_proiz
(
 @razlika int= null
) as
begin
select dobavljac_id, sum(razlika) as suma_razlika
from  view_dob_proiz
where razlika between 1 and 99 and razlika=@razlika
group by dobavljac_id, proizvod_id
end
go

exec proc_dob_proiz @razlika=2
----------------------------
--5.
----------------------------
/*
a)
Pogled view_dob_proiz kopirati u tabelu tabela_dob_proiz uz uslov da se ne dohvataju zapisi u kojima je razlika NULL vrijednost
--11051
b) 
U tabeli tabela_dob_proiz kreirati izračunatu kolonu ukupno kao proizvod naručene količine i cijene proizvoda.
c)
U tabeli tabela_dob_god kreirati novu kolonu razlika_ukupno. Kolonu popuniti razlikom vrijednosti kolone ukupno i srednje vrijednosti ove kolone.
 Negativne vrijednosti u koloni razlika_ukupno zamijeniti 0.
*/
--15 bodova
--a
select *
into tabela_dob_proiz
from view_dob_proiz
where razlika is not null
--b
alter table tabela_dob_proiz
add ukupno int 

update tabela_dob_proiz
set ukupno = naruc_kolicina*cijena_proizvoda

select * from tabela_dob_proiz
--c

----------------------------
--6.
----------------------------
/*
Prebrojati koliko u tabeli dobavljac_proizvod ima različitih serijskih oznaka proizvoda 
kojima se poslije prve srednje crte nalazi bilo koje slovo engleskog alfabeta, a koliko ima onih
kojima se poslije prve srednje crte nalazi cifra. Upit treba da vrati dvije poruke (tekst i podaci se ne prikazuju u zasebnim kolonama):
	'Različitih serijskih oznaka proizvoda koje završavaju slovom engleskog alfabeta ima: ' iza čega slijedi podatak o ukupno prebrojanom  broju zapisa 
	i
	'Različitih serijskih oznaka proizvoda kojima se poslije prve srednje crte nalazi cifra ima:' iza čega slijedi podatak o ukupno prebrojanom  broju zapisa 
*/
--10

----------------------------
--7.
----------------------------
/*
a)
Koristeći tabelu dobavljac kreirati pogled view_duzina koji će sadržavati slovni dio podataka u koloni dobavljac_br_rac, te broj znakova slovnog dijela podatka.
b)
Koristeći pogled view_duzina odrediti u koliko zapisa broj prebrojanih znakova je veći ili jednak, a koliko manji od srednje vrijednosti prebrojanih brojeva 
znakova. Rezultat upita trebaju biti dva reda sa odgovarajućim porukama.
*/
--10 bodova

---
-------------------------
--8.
----------------------------
/*
Prebrojati kod kolikog broja dobavljača je broj računa kreiran korištenjem
više od jedne riječi iz naziva dobavljača. Jednom riječi se podrazumijeva
 skup slova koji nije prekinut blank (space) znakom. 
*/
--10 bodova

----------------------------
--9.
----------------------------
/*
a) U tabeli dobavljac_proizvod id proizvoda promijeniti tako što će se sve trocifrene vrijednosti svesti na vrijednost stotina (npr. 524 => 500).
 Nakon toga izvršiti izmjenu vrijednosti u koloni proizvod_id po sljedećem pravilu:
- Prije postojeće vrijednosti dodati "pr-", 
- Nakon postojeće vrijednosti dodati srednju crtu i četverocifreni brojčani dio iz kolone serij_oznaka_proiz koji slijedi nakon prve srednje crte,
 pri čemu se u slučaju da četverocifreni dio počinje 0 ta 0 odbacuje. 
U slučaju da nakon prve srednje crte ne slijedi četverocifreni broj ne vrši se nikakvo dodavanje (ni prije, ni poslije postojeće vrijednosti)
*/
/*
Primjer nekoliko konačnih podatka:

proizvod_id		serij_oznaka_proit

pr-300-1200		FW-1200
pr-300-820 		GT-0820 (odstranjena 0)
700				HL-U509-R (nije izvršeno nikakvo dodavanje)
*/
--13 bodova

----------------------------
--10.
----------------------------
/*
a) Kreirati backup baze na default lokaciju.
b) Napisati kod kojim će biti moguće obrisati bazu.
c) Izvršiti restore baze.
Uslov prihvatanja kodova je da se mogu pokrenuti.
*/
--2 boda
--1
/*
a) Kreirati bazu podataka pod vlastitim brojem indeksa.*/
create database ispit_fit
use ispit_fit
/*
--Prilikom kreiranja tabela voditi racuna o medjusobnom odnosu izmedju tabela.
b) Kreirati tabelu radnik koja ce imati sljedecu strukturu:
	-radnikID, cjelobrojna varijabla, primarni kljuc
	-drzavaID, 15 unicode karaktera
	-loginID, 256 unicode karaktera
	-god_rod, cjelobrojna varijabla
	-spol, 1 unicode karakter

	*/
	create table radnik
	(
		radnikID int,
		drzavaID nvarchar (15),
		loginID nvarchar (256),
		god_rod int,
		spol nvarchar(1),
		constraint PK_radnik primary key (radnikID)
	)
	/*
c) Kreirati tabelu nabavka koja ce imati sljedecu strukturu:
	-nabavkaID, cjelobrojna varijabla, primarni kljuc
	-status, cjelobrojna varijabla
	-radnikID, cjelobrojna varijabla
	-br_racuna, 15 unicode karaktera
	-naziv_dobavljaca, 50 unicode karaktera
	-kred_rejting, cjelobrojna varijabla
	*/
	create table nabavka
	(
		nabavkaID int,
		status int,
		radnikID int,
		br_racuna nvarchar(15),
		naziv_dobavljaca nvarchar(50),
		kred_rejting int,
		constraint PK_narudzba primary key (nabavkaID),
		constraint FK_n_radnik foreign key (radnikID) references radnik(radnikID)
	)
	/*
c) Kreirati tabelu prodaja koja ce imati sljedecu strukturu:
	-prodajaID, cjelobrojna varijabla, primarni kljuc, inkrementalno punjenje sa pocetnom vrijednoscu 1, samo neparni brojevi
	-prodavacID, cjelobrojna varijabla
	-dtm_isporuke, datumsko-vremenska varijabla
	-vrij_poreza, novcana varijabla
	-ukup_vrij, novcana varijabla
	-online_narudzba, bit varijabla sa ogranicenjem kojim se mogu unijeti samo cifre 0 i 1
	*/
	create table prodaja
	(
		prodajaID int constraint PK_prodaja primary key identity (1,2),
		prodavacID int,
		dtm_isporuke datetime,
		vrij_poreza money,
		ukup_vrij money,
		online_narudzba bit ,
		constraint FK_p_radnik foreign key (prodavacID) references radnik (radnikID)
	)

	select * from prodaja
	create table prodaja_1
	(
		prodajaID int constraint PK__prodaja primary key identity (1,2),
		prodavacID int,
		dtm_isporuke datetime,
		vrij_poreza money,
		ukup_vrij money,
		online_narudzba bit constraint CK_online_narudzba check (online_narudzba=0 or online_narudzba=1)
		constraint FK_p__radnik foreign key (prodavacID) references radnik (radnikID)
	)

	/*
--2
Import podataka
a) Iz tabele Employee iz šeme HumanResources baze AdventureWorks2017 u tabelu radnik importovati podatke po sljedecem pravilu:
	-BusinessEntityID -> radnikID
	-NationalIDNumber -> drzavaID
	-LoginID -> loginID
	-godina iz kolone BirthDate -> god_rod
	-Gender -> spol
	*/
	insert into radnik (radnikID, drzavaID, loginID, god_rod, spol)
	select BusinessEntityID, NationalIDNumber, LoginID, year (BirthDate) , Gender
	from AdventureWorks2014.HumanResources.Employee

	select * from radnik
	/*
b) Iz tabela PurchaseOrderHeader i Vendor šeme Purchasing baze AdventureWorks2017 u tabelu nabavka importovati podatke po sljedecem pravilu:
	-PurchaseOrderID -> dobavljanjeID
	-Status -> status
	-EmployeeID -> radnikID
	-AccountNumber -> br_racuna
	-Name -> naziv_dobavljaca
	-CreditRating -> kred_rejting
	*/
	insert into nabavka (nabavkaID,status, radnikID,br_racuna, naziv_dobavljaca,kred_rejting)
	select h.PurchaseOrderID,h.Status,h.EmployeeID,v.AccountNumber, v.Name, v.CreditRating
	from AdventureWorks2014.Purchasing.PurchaseOrderHeader h join AdventureWorks2014.Purchasing.Vendor v
	on h.VendorID=v.BusinessEntityID
	/*
c) Iz tabele SalesOrderHeader šeme Sales baze AdventureWorks2017 u tabelu prodaja importovati podatke po sljedecem pravilu:
	-SalesPersonID -> prodavacID
	-ShipDate -> dtm_isporuke
	-TaxAmt -> vrij_poreza
	-TotalDue -> ukup_vrij
	-OnlineOrderFlag -> online_narudzba
	*/
	insert into prodaja (prodavacID,dtm_isporuke,vrij_poreza,ukup_vrij,online_narudzba)
	select SalesPersonID,ShipDate,TaxAmt,TotalDue,OnlineOrderFlag
	from AdventureWorks2014.Sales.SalesOrderHeader

	select * from prodaja

	
	/*
--3
a) U tabelu radnik dodati kolonu st_kat (starosna kategorija), tipa 3 karaktera.
*/
alter table radnik
add st_kat nvarchar(3)

select * from radnik
/*
b) Prethodno kreiranu kolonu popuniti po principu:
	starosna kategorija			uslov
	I							osobe do 30 godina starosti (ukljucuje se i 30)
	II							osobe od 31 do 49 godina starosti
	III							osobe preko 50 godina starosti
	*/
	update radnik
	set st_kat = 'I'
	where year(GETDATE())-god_rod<=30
	update radnik
	set st_kat = 'II'
	where year(GETDATE())-god_rod>30 and  year(GETDATE())-god_rod<49
	update radnik
	set st_kat = 'III'
	where year(GETDATE())-god_rod>50
	/*
c) Neka osoba sa navrsenih 65 godina odlazi u penziju.
Prebrojati koliko radnika ima 10 ili manje godina do penzije.
Rezultat upita iskljucivo treba biti poruka:
'Broj radnika koji imaju 10 ili manje godina do penzije je' nakon cega slijedi prebrojani broj.
Nece se priznati rjesenje koje kao rezultat upita vraca vise kolona.

*/
select 'Broj radnika koji imaju 10 ili manje godina do penzije je'+convert (nvarchar,count(*)) as prebrojano
from radnik
where year(GETDATE())-god_rod>=55 and year(GETDATE())-god_rod<65
/*
--4
a) U tabeli prodaja kreirati kolonu stopa_poreza (10 unicode karaktera)
b) Prethodno kreiranu kolonu popuniti kao kolicnik vrij_poreza i ukup_vrij.
Stopu poreza izraziti kao cijeli broj s oznakom %, pri cemu je potrebno da izmedju brojcane vrijednosti i znaka % bude prazno mjesto.
(Npr: 14.00 %)
*/
alter table prodaja
add stopa_poreza nvarchar(10)
select * from prodaja


update prodaja
set stopa_poreza = convert(nvarchar,(vrij_poreza / ukup_vrij)*100)+'%'
/*
--5
a) Koristeci tabelu nabavka kreirati pogled view_slova sljedece strukture:
	-slova
	-prebrojano, prebrojani broj pojavljivanja slovnih dijelova podatka u koloni br_racuna.
b) Koristeci pogled view_slova odrediti razliku vrijednosti izmedju prebrojanih i srednje vrijednosti kolone.
Rezultat treba da sadrzi kolone slova, prebrojano i razliku.
Sortirati u rastucem redoslijedu prema razlici.
*/
	create view view_slova as
	select  left(br_racuna,len(br_racuna)-4) as slova, count (*) prebrojano
	from nabavka
	group by left(br_racuna,len(br_racuna)-4)

	select * from view_slova

	select slova,prebrojano, prebrojano-(select avg(prebrojano) from view_slova) as razlika
	from view_slova
	order by 3
/*
--6
a) Koristeci tabelu prodaja kreirati pogled view_stopa sljedece strukture:
	-prodajaID
	-stopa_poreza
	-stopa_num, u kojoj ce biti numericka vrijednost stope poreza
	*/
	create view view_stopa
	as
	select prodajaID,stopa_poreza, convert (float, left(stopa_poreza,len(stopa_poreza)-1)) as stopa_num
	from prodaja

	
	/*
b) Koristeci pogled view_stopa, a na osnovu razlike izmedju vrijednosti u koloni stopa_num i srednje vrijednosti stopa poreza
za svaki proizvodID navesti poruku 'manji', odnosno, 'veci'.
*/
	select prodajaID, 'manji' poruka
	from view_stopa
	where stopa_num<(select avg(stopa_num) from view_stopa)
	union
	select prodajaID, 'veci' poruka
	from view_stopa
	where stopa_num>(select avg(stopa_num) from view_stopa)
/*
--7 
Koristeci pogled view_stopa_poreza kreirati proceduru proc_stopa_poreza tako da je prilikom izvrsavanja moguce unijeti bilo koji broj
parametara (mozemo ostaviti bilo koji parametar bez unijete vrijednosti), pri cemu ce se prebrojati broj zapisa po stopi poreza uz 
uslov da se dohvate samo oni zapisi u kojima je stopa poreza veca od 10%.
Proceduru pokrenuti za sljedece vrijednosti:
	-stopa poreza = 12, 15 i 21
	*/
	go
	create procedure proc_stopa_poreza
	(
		@prodajaID INT = NULL,
		@stopa_poreza NVARCHAR(10) = NULL,
		@stopa_num FLOAT = NULL
	)
	as
	begin
	select count(*)
	from view_stopa
	where stopa_num=@stopa_num or prodajaID=@prodajaID or stopa_poreza=@stopa_poreza  and stopa_num>10
	end

	exec proc_stopa_poreza 12

	CREATE PROCEDURE proc_stopa_poreza__
(
	@prodajaID INT = NULL,
	@stopa_poreza NVARCHAR(10) = NULL,
	@stopa_num FLOAT = NULL
)
AS
BEGIN
	SELECT COUNT(*)
	FROM view_stopa
	WHERE 
		prodajaID = @prodajaID OR
		stopa_poreza = @stopa_poreza OR
		stopa_num = @stopa_num AND stopa_num > 10
END

EXEC proc_stopa_poreza 12
EXEC proc_stopa_poreza 15
EXEC proc_stopa_poreza 21
GO;
	
	/*
--8
Kreirati proceduru proc_prodaja kojom ce se izvrsiti promjena vrijednosti u koloni online_narudzba tabele prodaja.
Promjena ce se vrsiti tako sto ce se 0 zamijeniti sa NO, a 1 sa YES.
Pokrenuti proceduru kako bi se izvrsile promjene, a nakon toga onemoguciti da se u koloni unosi bilo kakva druga vrijednost osim NO ili
YES.
--9
a) Nad kolonom god_rod tabele radnik kreirati ogranicenje kojim ce se onemoguciti unos bilo koje godine iz buducnosti kao godina rodjenja.
Testirati funkcionalnost kreiranog ogranicenja navodjenjem koda za insert podataka kojim ce se kao godina rodjenja pokusati unijeti
bilo koja godina iz buducnosti.
b) Nad kolonom drzavaID tabele radnik kreirati ogranicenje kojim ce se ograniciti duzina podatka na 7 znakova.
Ako je prethodno potrebno, izvrsiti prilagodbu kolone, pri cemu nije dozvoljeno prilagodjavati podatke cija duzina iznosi 7 ili manje znakova.
Testirati funkcionalnost kreiranog ogranicenja navodjenjem koda za insert podataka kojim ce se u drzavaID pokusati unijeti podatak duzi 
od 7 znakova bilo koja godina iz buducnosti.
--10
Kreirati backup baze na default lokaciju, obrisati bazu a zatim izvrsiti restore baze. 
Uslov prihvatanja koda je da se moze izvrsiti.