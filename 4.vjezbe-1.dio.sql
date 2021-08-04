/*
1. Kreirati bazu podataka pozoriste.
*/
create database pozoriste
go
use pozoriste
/*
2. Uvažavajuæi DIJAGRAM uz definiranje primarnih i vanjskih kljuèeva, te veza (relationship) izmeðu tabela, kreirati sljedeæe tabele:

a) glumac
	-	zaposlenikID	10 unicode karaktera		primarni kljuè
	-	predstava_ID	cjelobrojna vrijednost		primarni kljuè
	-	vrsta_uloge_ID	cjelobrojna vrijednost
*/
create table glumac
(
	zaposlenikID nvarchar(10),
	predstava_ID int,
	vrsta_uloge_ID int,
	constraint PK_glumac primary key (zaposlenikID,predstava_ID),
	constraint FK_glumac_zaposlenik foreign key (zaposlenikID) references zaposlenik (zaposlenikID),
	constraint FK_glumac_vrsta_uloge foreign key (vrsta_uloge_ID) references vrsta_uloge (vrsta_uloge_ID),
	constraint FK_glumac_predstava foreign key (predstava_ID) references predstava (predstava_ID)

)
/*
b) izvodjenje
	-	izvodjenjeID		cjelobrojna vrijednost	primarni kljuè
	-	predstava_ID		cjelobrojna vrijednost
	-	datum_izvodjenja	datumska vrijednost
	-	termin_izvodjenja	vremenska vrijednost
	-	br_gledatelja		cjelobrojna vrijednost
*/
create table izvodjenje
(
	izvodjenjeID	int,
	predstava_ID	int,
	datum_izvodjenja date,
	termin_izvodjenja	date,
	br_gledatelja	int,
	constraint PK_izvodjenjeID primary key (izvodjenjeID),
	constraint FK_predstava foreign key (predstava_ID) references predstava (predstava_ID)
)
/*

c) predstava
	-	predstava_ID		cjelobrojna vrijednost	primarni kljuè
	-	naziv_predstave		20 unicode karaktera
	-	duz_trajanja_pred	cjelobrojna vrijednost
	-	vrsta_predstave_ID	cjelobrojna vrijednost
*/
create table predstava
(
	predstava_ID int,
	naziv_predstave	nvarchar(20),
	duz_trajanja_pred	int,
	vrsta_predstave_ID int,
	constraint PK_predstava_ID primary key (predstava_ID),
	constraint FK_vrsta_predstave foreign key (vrsta_predstave_ID) references vrsta_predstave (vrsta_predstave_ID)
)
/*
d) reditelj
	-	zaposlenikID	10 unicode karaktera		primarni kljuè
	-	predstava_ID	cjelobrojna vrijednost		primarni kljuè

*/
create table reditelj
(
	zaposlenikID nvarchar(10),
	predstava_ID int,
	constraint PK_reditelj primary key (zaposlenikID,predstava_ID),
	constraint FK_reditelj_predstava foreign key (predstava_ID) references predstava (predstava_ID),
	constraint FK_reditelj_zaposlenik foreign key (zaposlenikID) references zaposlenik (zaposlenikID)
)
/*

e) rekvizit
	-	rekvizit_ID	10 unicode karaktera		primarni kljuè
	-	predstava_ID	cjelobrojna vrijednost		primarni kljuè
*/
create table rekvizit
(
	rekvizit_ID nvarchar(10),
	predstava_ID int,
	constraint PK_rekvizit primary key (rekvizit_ID,predstava_ID),
	constraint FK_rekvizit_predstava foreign key (predstava_ID) references predstava (predstava_ID),
)
/*

f) vrsta_predstave
	-	vrsta_predstave_ID	cjelobrojna vrijednost	primarni kljuè
	-	naziv_vrste_pred	15 unicode karaktera
*/
create table vrsta_predstave
(
	vrsta_predstave_ID	int,
	naziv_vrste_pred nvarchar(15),
	constraint PK_vrsta_predstave primary key (vrsta_predstave_ID)
)
/*
g) vrsta_uloge
	-	vrsta_uloge_ID		cjelobrojna vrijednost	primarni kljuè
	-	naziv_vrste_uloge	15 unicode karaktera

*/
create table vrsta_uloge
(
	vrsta_uloge_ID int,
	naziv_vrste_uloge nvarchar(15),
	constraint PK_uloga_ID primary key (vrsta_uloge_ID)
)
/*
h) zaposlenik
	-	zaposlenikID		10 unicode karaktera	primarni kljuè
	-	datum_zaposlenja	datumska vrijednost
	-	dtm_raskida_ugovora	datumska vrijednost

*/
create table zaposlenik
(
 zaposlenikID nvarchar(10),
 datum_zaposlenja date,
 dtm_raskida_ugovora date, 
 constraint PK_zaposlenik primary key (zaposlenikID)
)