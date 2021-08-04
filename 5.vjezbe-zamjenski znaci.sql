/*
ZAMJENSKI ZNAKOVI
% 		- mijenja bilo koji broj znakova
_ 		- mijenja taèno jedan znak


PRETRAŽIVANJE

[ListaZnakova]	-	pretražuje po bilo kojem znaku iz navedene liste pri èemu
					rezultat SADRŽI bilo koji od navedenih znakova
[^ListaZnakova]	-	pretražuje po bilo kojem znaku koji je naveden u listi pri èemu
					rezultat NE SADRŽI bilo koji od navedenih znakova
[A-C]			-	pretražuje po svim znakovima u intervalu izmeðu navedenih 
					ukljuèujuæi i navedene znakove, pri èemu rezultat SADRŽI navedene znakove
[^A-C]			-	pretražuje po svim znakovima u intervalu izmeðu navedenih 
					ukljuèujuæi i navedene znakove, pri èemu rezultat NE SADRŽI navedene znakove
*/

/*
U bazi Northwind iz tabele Customers prikazati ime kompanije kupca i kontakt telefon i to samo onih koji u svome imenu posjeduju rijeè „Restaurant“. Ukoliko naziv kompanije sadrži karakter (-), kupce izbaciti iz rezultata upita.*/
use NORTHWND
select CompanyName, Phone
from Customers
where CompanyName like '%Restaurant%' and CompanyName not like '%-%'
/*
U bazi Northwind iz tabele Products prikazati proizvode èiji naziv poèinje slovima „C“ ili „G“, drugo slovo može biti bilo koje, a treæe slovo u nazivu je „A“ ili „O“. */
select ProductName
from Products
where ProductName like '[CG]_[AO]%'

/*
U bazi Northwind iz tabele Products prikazati listu proizvoda èiji naziv poèinje slovima „L“ ili  „T“ ili je ID proizvoda = 46. Lista treba da sadrži samo one proizvode èija se cijena po komadu kreæe izmeðu 10 i 50. Upit napisati na dva naèina.*/
select  ProductName
from Products
where (ProductName like '[LT]%' or ProductID=46) and UnitPrice between 10 and 50
/*
U bazi Northwind iz tabele Suppliers prikazati ime isporuèitelja, državu i fax pri èemu isporuèitelji dolaze iz Španije ili Njemaèke, a nemaju unešen (nedostaje) broj faksa. Formatirati izlaz polja fax u obliku 'N/A'.*/

select CompanyName, Country, ISNULL (Fax,'N/A') as Fax
from Suppliers
where (Country like 'Germany' or Country like 'Spain') and Fax is null
/*
Iz tabele Poslodavac dati pregled kolona PoslodavacID i Naziv pri èemu naziv poslodavca poèinje slovom B. 
*/
use prihodi
select PoslodavacID, Naziv
from Poslodavac
where Naziv like 'B%'
/*
Iz tabele Poslodavac dati pregled kolona PoslodvacID i Naziv pri èemu naziv poslodavca poèinje slovom B, drugo može biti bilo koje slovo, treæe je b i ostatak naziva mogu èiniti sva slova.
*/
select PoslodavacID, Naziv
from Poslodavac
where Naziv like '[B]_[b]%'
/*
Iz tabele Država dati pregled kolone Drzava pri èemu naziv države završava slovom a. Rezultat sortirati u rastuæem redoslijedu.
*/
select Drzava
from Drzava
where Drzava like '%a'
order by 1asc
/*
Iz tabele Osoba dati pregled svih osoba kojima i ime i prezime poèinju slovom a. Dati prikaz OsobaID, Prezime i Ime. Rezultat sortirati po prezimenu i imenu u rastuæem redoslijedu.
*/
select OsobaID,PrezIme, Ime
from Osoba
where Ime like 'A%' and PrezIme like 'A%'
order by 2,3asc
/*
Iz tabele Poslodavac dati pregled svih poslodavaca u èijem nazivu se na kraju ne nalaze slova m i e. Dati prikaz PoslodavcID i Naziv.
*/
select Naziv,PoslodavacID
from Poslodavac
where Naziv not like '%[me]'
/*
Iz tabele Osoba dati pregled svih osoba kojima se prezime završava samoglasnikom. Dati prikaz OsobaID, Prezime i Ime. Rezultat sortirati po prezimenu u opadajuæem redoslijedu.
*/
select OsobaID, PrezIme, Ime
from Osoba
where PrezIme like '%[^aeiou]'
order by 2desc
/*
Iz tabele Osoba dati pregled svih osoba kojima ime poèinje bilo kojim od prvih 10 slova engleskog alfabeta. Dati prikaz OsobaID, Prezime i Ime. Rezultat sortirati po prezimenu u opadajuæem redoslijedu.
*/
select OsobaID, PrezIme, Ime
from Osoba
where Ime like '[A-J]%'
order by 2desc
/*
Iz tabele Osoba dati pregled kolona OsobaID, Prezime, Ime i Adresa uz uslov da se prikažu samo oni zapisi koji poèinju bilo kojom cifrom u intervalu 1-9.
*/
select OsobaID, PrezIme, Ime, Adresa
from Osoba 
where Adresa like '[1-9]%'
/*
Iz tabele Osoba dati pregled kolona OsobaID, Prezime, Ime i Adresa uz uslov da se prikažu samo oni zapisi koji ne poèinju bilo kojom cifrom u intervalu 1-9.
*/
select OsobaID, PrezIme, Ime, Adresa
from Osoba
where Adresa not like '[1-9]%'