CREATE DATABASE Integralni0702
USE Integralni0702

--1. Koristeci iskljucivo SQL kod, kreirati bazu pod vlastitim brojem indeksa sa defaultnim postavkama.
--Unutar svoje baze podataka kreirati tabele sa sljedecom strukturom:
/*a) Narudzba
- NarudzbaID, primarni kljuc
- Kupac, 40 UNICODE karakter
- PunaAdresa, 80 UNICODE karakter
- DatumNarudzbe, datumska varijabla, definirati kao datum
- Prevoz, novcana varijabla
- Uposlenik, 40 UNICODE karakter
- GradUposlenika, 30 UNICODE karakter
- DatumZaposlenja, datumska varijabla, definirati kao datum
- BtGodStaza, cjelobrojna varijabla*/
CREATE TABLE Narudzba
(
	NarudzbaID INT CONSTRAINT PK_NarudzbaID PRIMARY KEY (NarudzbaID),
	Kupac NVARCHAR(40),
	PunaAdresa NVARCHAR(80),
	DatumNarudzbe DATE,
	Prevoz MONEY,
	Uposlenik NVARCHAR(40),
	GradUposlenika NVARCHAR(30),
	DatumZaposlenja DATE,
	BrGodStaza INT
);

/*b) Proizvod
- ProizvodID, cjelobrojna varijabla, primarni kljuc
- NazivProizoda, 40 UNICODE karakter
- NazivDobavljaca, 40 UNICODE karakter
- StanjeNaSklad, cjelobrojna varijabla
- NarucenaKol, cjelobrojna varijabla*/
CREATE TABLE Proizvod
(
	ProizvodID INT CONSTRAINT PK_ProizvodID PRIMARY KEY(ProizvodID),
	NazivProizvoda NVARCHAR(40),
	NazivDobavljaca NVARCHAR(40),
	StanjeNaSklad INT,
	NarucenaKol INT
);

/*
c) DetaljiNarudzbe
- NarudzbaID, cjelobrojna varijabla, obavezan unos
- ProizvodID, cjelobrojna varijabla, obavezan unos
- CijenaProizvoda, novcana varijabla
- Kolicina, cjelobrojna varijabla, obavezan unos
- Popoust, varijabla za realne vrijednosti
Napomena: Na jednoj narudzbi se nalazi jedan ili vise proizvoda.*/
CREATE TABLE DetaljiNarudzbe
(
	ProizvodID INT NOT NULL CONSTRAINT FK_Proizvod_Detalji 
				FOREIGN KEY REFERENCES Proizvod(ProizvodID),
	NarudzbaID INT NOT NULL CONSTRAINT FK_Narudzba_Detalji 
				FOREIGN KEY REFERENCES Narudzba(NarudzbaID),
	CONSTRAINT PK_Proizvod_Narudzba PRIMARY KEY(ProizvodID, NarudzbaID),

	CijenaProizvoda MONEY,
	Kolicina INT NOT NULL,
	Popust REAL
);

/*2. Import podataka u kreirane tabele.*/
/*a) Narudzbe
Koristeci bazu Northwind iz tabela Orders, Customers i Employees importovati podatke po sljedecem pravilu:
- OrderID -> ProizvodID
- CompanyName -> Kupac
- PunaAdresa – spojeno adresa, postanski broj I grad, pri cemu ce se izmedju rijeci staviti srednja crta sa razmakom prije I poslije nje
- OrderDate -> DatumNarudzbe
- Freight -> Prevoz
- Uposlenik – spojeno prezime I ime sa razmakom izmedju njih
- City -> Grad iz kojeg je uposlenik
- HireDate -> DatumZaposlenja
- BrGodStaza – broj godina od datuma zaposlenja*/
SELECT* FROM Narudzba

INSERT INTO Narudzba
SELECT O.OrderID, C.CompanyName, O.ShipAddress+' - '+O.ShipPostalCode+' - '+O.ShipCity,
			O.OrderDate, O.Freight, E.FirstName+' '+E.LastName, E.City, E.HireDate, 
				DATEDIFF(YEAR, E.HireDate, GETDATE())
FROM NORTHWND.dbo.Orders AS O 
	INNER JOIN NORTHWND.dbo.Customers AS C
ON O.CustomerID=C.CustomerID
	INNER JOIN NORTHWND.dbo.Employees AS E
ON O.EmployeeID=E.EmployeeID

/*b) Proizvod
Koristeci bazu Northwind iz tabela Products I Suppliers putem podupita importovati podake po sljedecem pravilu:
- ProductID -> ProizvodID
- ProductName -> NazivProizvoda
- CompanyName -> NazivDobavljaca
- UnitsInStock -> StanjeNaSklad
- UnitsOnOrder -> NarucenaKol*/
INSERT INTO Proizvod
SELECT P.ProductID, P.ProductName, S.CompanyName, P.UnitsInStock, P.UnitsOnOrder
FROM NORTHWND.dbo.Products AS P
	INNER JOIN NORTHWND.dbo.Suppliers AS S
ON P.SupplierID=S.SupplierID
WHERE P.ProductID IN 
(SELECT P.ProductID
FROM NORTHWND.dbo.Products)

select* from Proizvod

/*c) DetaljiNarudzbe
Koristeci bazu Northwind iz tabele OrderDetails importovati podake po sljedecem pravilu:
- OrderID -> NarudzbaID
- ProductID -> ProizvodID
- CijenaProizvoda – manja zaokruzena vrijednost kolone UnitPrice, npr UnitPrice = 3,60 / CijenaProizvoda = 3,00*/
select* from DetaljiNarudzbe
delete from DetaljiNarudzbe

INSERT INTO DetaljiNarudzbe
SELECT OD.ProductID, OD.OrderID,FLOOR(OD.UnitPrice), OD.Quantity, OD.Discount
FROM NORTHWND.dbo.[Order Details]  AS OD 
INNER JOIN NORTHWND.dbo.Products AS P
ON P.ProductID = OD.ProductID

/*3. a) U tabelu Narudzba dodati kolonu SifraUposlenika kao 20 UNICODE karaktera. Postaviti uslov da podatak mora biti duzine tacno 15 karaktera*/ 
ALTER TABLE Narudzba
ADD SifraUposlenika NVARCHAR(20) CONSTRAINT CK_Sifra CHECK (LEN(SifraUposlenika)=15)

/*b) Kolonu SifraUpooslenika popuniti na nacin da se obrne string koji se dobije spajanjem grada uposlenika I prvih 10 karaktera
datuma zaposlenja pri cemu se izmedju grada I 10 karaktera nalazi jedno prazno mjesto. Provjeriti da li je izvrsena izmjena.*/
UPDATE Narudzba
SET SifraUposlenika = LEFT((REVERSE(GradUposlenika+' '+ LEFT(DatumZaposlenja,10))), 15)



/*c) U tabeli Narudzba u koloni SifraUposlenika izvrsiti zamjenu svih zapisa kojima grad uposlenika zavrsava slovom “d” tako da
se umjesto toga ubaci slucajno generisani string duzine 20 karaktera. Provjeriti da li je izvrsena zamjena.*/
ALTER TABLE Narudzba
DROP CONSTRAINT CK_Sifra

UPDATE Narudzba
SET SifraUposlenika = LEFT(newid(), 20)
WHERE GradUposlenika LIKE '%d'
GO

/*4. Koristeci svoju bazu iz tabela Narudzba I DetaljiNarudzbe kreirati pogled koji ce imati sljedecu strukturu: Uposlenik,
SifraUposlenika, ukupan broj proizvoda izveden iz NazivProizvoda, uz uslove da je sifra uposlenika 20 karaktera, te da je
ukupan broj proizvoda veci od 2. Provjeriti sadrzaj pogleda, pri cemu se treba izvrsiti sortiranje po ukupnom broju proizvoda u
opadajucem redosljedu*/

CREATE VIEW view_SifraUposlenika
AS
SELECT N.Uposlenik, N.SifraUposlenika, COUNT(P.NazivProizvoda) AS [Ukupan broj proizvoda]
FROM Narudzba AS N
	INNER JOIN DetaljiNarudzbe AS DN
ON N.NarudzbaID=DN.NarudzbaID
	INNER JOIN Proizvod AS P
ON DN.ProizvodID=P.ProizvodID
WHERE LEN(N.SifraUposlenika)=20
GROUP BY N.Uposlenik, N.SifraUposlenika
HAVING COUNT(P.NazivProizvoda)>2
GO

SELECT* FROM view_SifraUposlenika
GO
/*5.Koristeci vlastitu bazu kreirati proceduru nad tabelom Narudzbe kojom ce se duzina podataka u 
koloni SifraUposlenika
smanjiti sa 20 na 4 slucajno generisana karaktera. Pokrenuti proceduru.*/

CREATE PROCEDURE proc_SifraUposlenika
AS
BEGIN
	UPDATE Narudzba
	SET SifraUposlenika = LEFT(newid(),4)
	WHERE LEN(SifraUposlenika)=20
END;
GO

EXECUTE proc_SifraUposlenika
GO
/*6. Koristeci vlastitu bazu kreirati pogled koji ce imati sljedecu strukturu: NazivProizvoda, 
Ukupno – ukupnu sumu prodaje
proizvoda uz uzimanje u obzir I popusta. Suma mora biti zaokruzena na dvije decimale. U pogled 
uvrstiti one proizvode koji su
naruceni, uz uslov da je suma veca od 1000. Provjeriti sadrzaj pogleda pri cemu ispis treba sortirati
 u opadajucem redoslijedu
po vrijednosti sume.*/

CREATE VIEW view_Ukupno
AS
SELECT P.NazivProizvoda, ROUND(SUM(DN.Kolicina*(DN.CijenaProizvoda-DN.CijenaProizvoda*DN.Popust)),2) AS Ukupno
FROM DetaljiNarudzbe AS DN
	INNER JOIN Proizvod AS P
ON DN.ProizvodID=P.ProizvodID
WHERE P.NarucenaKol>0 
GROUP BY P.NazivProizvoda
HAVING ROUND(SUM(DN.Kolicina*(DN.CijenaProizvoda-DN.CijenaProizvoda*DN.Popust)),2) > 10000
GO

SELECT* FROM view_Ukupno
ORDER BY Ukupno DESC
GO
/*7. a) Koristeci vlastitu bazu podataka kreirati pogled koji ce imati sljedecu strukturu:
- Kupac,
- NazivProizvoda
- Suma po cijeni proizvoda
Pri cemu ce se u pogled smjestiti samo oni zapisi kod kojih je cijena proizvoda veca od srednje
 vrijednosti cijene proizvoda.
Provjeriti sadrzaj pogleda pri cemu izlaz treba sortirati u rastucem redoslijedu izracunatoj sumi.*/

CREATE VIEW view_SrednjaCijena
AS
SELECT N.Kupac, P.NazivProizvoda, 
		SUM(DN.CijenaProizvoda) AS [Suma po cijeni proizvoda]
FROM Narudzba AS N
	INNER JOIN DetaljiNarudzbe AS DN
ON N.NarudzbaID=DN.NarudzbaID
	INNER JOIN Proizvod AS P
ON DN.ProizvodID=P.ProizvodID
WHERE DN.CijenaProizvoda > (SELECT AVG(CijenaProizvoda)
							 FROM DetaljiNarudzbe)
GROUP BY N.Kupac, P.NazivProizvoda

SELECT* FROM view_SrednjaCijena
GO
/*b) Koristeci vlastitu bazu podataka kreirati proceduru kojom ce se, koristeci prethodno kreirani 
pogled, definirati parametri:
Kupac, NazivProizvoda I SumaPoCijeni. Proceduru kreirati tako da je prilikom izvrsavanja moguce
 unijeti bilo koji broj
parametara (mozemo ostaviti bilo koji parametar bez unijete vrijednosti), uz uslov da vrijednost sume 
bude veca od srednje
vrijednosti suma koje su smjestene u pogled. Sortirati po sumi cijene. Procedura se treba izvrsiti ako
 se unese vrijednost za bilo
koji parametar. Nakon kreiranja pokrenuti proceduru za sljedece vrijednosti parametara:
1. SumaPoCijeni = 123
2. Kupac = Hanari Carnes
3. NazivProizvoda = Cote de Blaye*/

CREATE PROCEDURE proc_unos
(
	@Kupac NVARCHAR(40)=NULL,
	@NazivProizvoda NVARCHAR(40)=NULL,
	@SumaPoCijeni MONEY = NULL
)
AS
BEGIN
	SELECT Kupac, NazivProizvoda, [Suma po cijeni proizvoda]
	FROM view_SrednjaCijena
	WHERE [Suma po cijeni proizvoda] > 
		(SELECT AVG([Suma po cijeni proizvoda])
		 FROM view_SrednjaCijena) AND
		 Kupac = @Kupac OR 
		 [Suma po cijeni proizvoda] = @SumaPoCijeni OR
		 NazivProizvoda = @NazivProizvoda
	ORDER BY 3
END;
GO

EXEC proc_unos @Kupac='Hanari Carnes'
EXEC proc_unos @NazivProizvoda='Côte de Blaye'
EXEC proc_unos @SumaPoCijeni=123


/*8. a) Kreirati indeks nad tabelom Proizvod. Potrebno je indeksirati NazivDobavljaca. 
Ukljuciti I kolone StanjeNaSklad I
NarucenaKol. Napisati proizvoljni upit nad tabelom Proizvod koji u potpunosti koristi prednost 
kreiranog indeksa.
*/

CREATE NONCLUSTERED INDEX IX_StanjeNaSklad ON Proizvod
(
	NazivDobavljaca ASC
)
INCLUDE(StanjeNaSklad, NarucenaKol)

SELECT*
FROM Proizvod
WHERE NazivDobavljaca='Exotic Liquids' AND StanjeNaSklad >10 AND NarucenaKol<10

/*b) Uraditi disable indeksa iz prethodnog koraka.*/

ALTER INDEX IX_StanjeNaSklad ON Proizvod
DISABLE


/*9. Napraviti backup baze podataka na default lokaciju servera.*/
BACKUP DATABASE Integralni0702
TO DISK='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\Integralni0702.bak'
GO

/*10. Kreirati proceduru kojom ce se u jednom pokretanju izvrsiti brisanje svih pogleda I procedura koji su kreirani u vasoj bazi.*/
CREATE PROCEDURE proc_brisanje
AS
BEGIN
	DROP VIEW [dbo].[view_SifraUposlenika]
	DROP VIEW [dbo].[view_SrednjaCijena]
	DROP VIEW [dbo].[view_Ukupno]
	DROP PROCEDURE [dbo].[proc_SifraUposlenika]
	DROP PROCEDURE [dbo].[proc_unos]
END;
	
EXEC proc_brisanje
