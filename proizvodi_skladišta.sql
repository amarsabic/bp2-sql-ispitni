/*1. Kroz SQL kod, napraviti bazu podataka koja nosi ime vašeg broja dosijea. U postupku kreiranja u obzir uzeti samo DEFAULT postavke.*/

CREATE DATABASE ProSkla
ON
(
	NAME=ProSkla_data,  FILENAME='C:\Users\Amar Sabic\Desktop\ProSkla\ProSkla.mdf',
	SIZE=5MB, MAXSIZE=UNLIMITED ,FILEGROWTH=100%
)

LOG ON
(
	NAME=ProSkla_log, FILENAME='C:\Users\Amar Sabic\Desktop\ProSkla\ProSkla.ldf',
	SIZE=2MB, MAXSIZE=UNLIMITED, FILEGROWTH=2%
)

USE ProSkla

/*Unutar svoje baze podataka kreirati tabelu sa sljedećom strukturom:*/

/*a) Proizvodi:
I. ProizvodID, automatski generatpr vrijednosti i primarni ključ
II. Sifra, polje za unos 10 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
III. Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
IV. Cijena, polje za unos decimalnog broja (obavezan unos)*/

CREATE TABLE Proizvodi
(
	ProizvodID INT CONSTRAINT PK_Proizvod PRIMARY KEY IDENTITY(1,1),
	Sifra NVARCHAR(10) NOT NULL CONSTRAINT UQ_Sifra UNIQUE,
	Naziv NVARCHAR(50) NOT NULL,
	Cijena DECIMAL 
);

/*b) Skladista
I. SkladisteID, automatski generator vrijednosti i primarni ključ
II. Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
III. Oznaka, polje za unos 10 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
IV. Lokacija, polje za unos 50 UNICODE karaktera (obavezan unos)*/

CREATE TABLE Skladista
(
	SkladisteID INT CONSTRAINT PK_Skladiste PRIMARY KEY IDENTITY(1,1),
	Naziv NVARCHAR(50) NOT NULL,
	Oznaka NVARCHAR(10) NOT NULL CONSTRAINT UQ_Oznaka UNIQUE,
	Lokacija NVARCHAR(50) NOT NULL
);

/*c) SkladisteProizvodi
I) Stanje, polje za unos decimalnih brojeva (obavezan unos)
Napomena: Na jednom skladištu može biti uskladišteno više proizvoda, dok isti proizvod može biti uskladišten na više različitih skladišta. Onemogućiti da se isti proizvod na skladištu može pojaviti više puta.
*/

CREATE TABLE SkladisteProizvodi
(
	ProizvodID INT NOT NULL CONSTRAINT FK_Proizvod_Skladiste
				FOREIGN KEY REFERENCES Proizvodi(ProizvodID),
	SkladisteID INT NOT NULL CONSTRAINT FK_Skladiste_SkladisteProizvodi
				FOREIGN KEY REFERENCES Skladista(SkladisteID),
	CONSTRAINT PK_Skladiste_Proizvod PRIMARY KEY(ProizvodID, SkladisteID),

	Stanje DECIMAL NOT NULL
);

/*2. Popunjavanje tabela podacima

a) Putem INSERT komande u tabelu Skladista dodati minimalno 3 skladišta.*/

INSERT INTO Skladista (Naziv, Oznaka, Lokacija)
VALUES('Skladiste1', 'SK1', 'Sarajevo'),
	  ('Skladiste2', 'SK2', 'Mostar'),
	  ('Skladiste3', 'SK3', 'Cazin')

SELECT* FROM Skladista

/*b) Koristeći bazu podataka AdventureWorks2014, preko INSERT i SELECT komande importovati 10 
najprodavanijih bicikala (kategorija proizvoda 'Bikes' i to sljedeće kolone:
I. Broj proizvoda (ProductNumber) - > Sifra,
II. Naziv bicikla (Name) -> Naziv,
III. Cijena po komadu (ListPrice) -> Cijena,*/

select* from Proizvodi
select* from AdventureWorks2014.Production.Product
select* from AdventureWorks2014.Production.ProductSubcategory

INSERT INTO Proizvodi
SELECT TOP 10 PP.ProductNumber, PP.Name, PP.ListPrice
FROM AdventureWorks2014.Production.Product AS PP
	INNER JOIN AdventureWorks2014.Production.ProductSubcategory AS PS
ON PP.ProductSubcategoryID=PS.ProductSubcategoryID
	WHERE PS.ProductCategoryID=1

/*c) Putem INSERT i SELECT komandi u tabelu SkladisteProizvodi za sva dodana skladista
 importovati sve proizvode tako da stanje bude 100*/	

SELECT* FROM SkladisteProizvodi

INSERT INTO SkladisteProizvodi(ProizvodID, SkladisteID, Stanje)
SELECT Proizvodi.ProizvodID, 1, 100
FROM Proizvodi

INSERT INTO SkladisteProizvodi(ProizvodID, SkladisteID, Stanje)
SELECT Proizvodi.ProizvodID, 2, 100
FROM Proizvodi

INSERT INTO SkladisteProizvodi(ProizvodID, SkladisteID, Stanje)
SELECT Proizvodi.ProizvodID, 3, 100
FROM Proizvodi
GO

/*3. Kreirati uskladištenu proceduru koja će vršiti povećanje stanja skladišta za 
određeni proizvod na odabranom skladištu. Provjeriti ispravnost procedure.*/	

CREATE PROCEDURE proc_stanje
(
	@Stanje DECIMAL,
	@Sifra NVARCHAR(10),
	@Oznaka NVARCHAR(10)
)
AS
BEGIN
	UPDATE SkladisteProizvodi
	SET Stanje+= @Stanje
	WHERE SkladisteProizvodi.ProizvodID =(SELECT P.ProizvodID
										  FROM Proizvodi AS P
										  WHERE P.Sifra=@Sifra)
					AND
	SkladisteProizvodi.SkladisteID=(SELECT SkladisteID
									FROM Skladista AS S
									WHERE S.Oznaka=@Oznaka)
END;
GO	

EXEC proc_stanje @Stanje = 20, @Sifra='BK-R93R-62', @Oznaka='SK1'
SELECT* FROM SkladisteProizvodi

/*4. Kreiranje indeksa u bazi podataka nad tabelama
a) Non-clustered indeks nad tabelom Proizvodi. Potrebno je indeksirati Sifru i Naziv.
 Također, potrebno je uključiti kolonu Cijena*/

 CREATE NONCLUSTERED INDEX IX_SifraNaziv 
 ON Proizvodi(Sifra, Naziv)
 INCLUDE (Cijena)

 /*b) Napisati proizvoljni upit nad tabelom Proizvodi koji u potpunosti iskorištava indeks iz prethodnog koraka*/

 SELECT Sifra, Naziv, Cijena
 FROM Proizvodi
 WHERE Cijena>1450 AND Sifra LIKE '%8'

 /*c) Uradite disable indeksa iz koraka a)*/

 ALTER INDEX IX_SifraNaziv ON Proizvodi
 DISABLE;
 GO

 /*5. Kreirati view sa sljedećom definicijom. Objekat treba da prikazuje sifru, 
 naziv i cijenu proizvoda, oznaku, naziv i lokaciju skladišta, te stanje na skladištu.*/

CREATE VIEW view_sifranaziv
AS
SELECT P.Sifra, P.Naziv, P.Cijena, S.Oznaka, S.Naziv AS [Naziv skladišta], S.Lokacija, SP.Stanje
FROM Proizvodi AS P
	INNER JOIN SkladisteProizvodi AS SP
ON P.ProizvodID = SP.ProizvodID
	INNER JOIN Skladista AS S
ON SP.SkladisteID=S.SkladisteID
GO

SELECT * FROM view_sifranaziv
GO
/*6. Kreirati uskladištenu proceduru koja će na osnovu unesene šifre proizvoda prikazati
ukupno stanje zaliha na svim skladištima. U rezultatu prikazati sifru, naziv i cijenu proizvoda te
ukupno stanje zaliha. U proceduri koristiti prethodno kreirani view. Provjeriti ispravnost kreirane 
procedure.*/

CREATE PROCEDURE proc_stanjeZaliha
(
	@Sifra NVARCHAR(10)
)
AS
BEGIN
	SELECT Sifra, Naziv, Cijena, Stanje
	FROM view_sifranaziv
	WHERE Sifra=@Sifra
END;

EXEC proc_stanjeZaliha @Sifra='BK-R93R-62'
GO

/*7. Kreirati uskladištenu proceduru koja će vršiti upis novih proizvoda, te kao
 stanje zaliha za uneseni proizvod postaviti na 0 za sva skladišta. Provjeriti ispravnost
  kreirane procedure.*/

CREATE PROCEDURE proc_dodavanje
(
	@Sifra NVARCHAR(10),
	@Naziv NVARCHAR(50),
	@Cijena DECIMAL
)
AS
BEGIN

	INSERT INTO Proizvodi(Sifra, Naziv,Cijena)
	VALUES(@Sifra, @Naziv, @Cijena)

	INSERT INTO SkladisteProizvodi
  (ProizvodID, SkladisteID, Stanje)

		VALUES((SELECT ProizvodID
		        FROM Proizvodi
			    WHERE @Sifra=Sifra), 1, 0),

			  ((SELECT ProizvodID
			    FROM Proizvodi
			    WHERE @Sifra=Sifra), 2, 0),

				((SELECT ProizvodID
			    FROM Proizvodi
			    WHERE @Sifra=Sifra), 3, 0)	
END;

EXEC proc_dodavanje @Sifra='AM-AR1881', @Naziv='Coca-Cola', @Cijena=1.00

SELECT* FROM Proizvodi

SELECT* FROM SkladisteProizvodi
WHERE ProizvodID = (SELECT ProizvodID
					FROM Proizvodi
					WHERE Naziv='Coca-Cola')
GO
/*8. Kreirati uskladištenu proceduru koja će za unesenu šifru proizvoda vršiti 
brisanje proizvoda uključujući stanje na svim skladištima. Provjeriti ispravnost procedure.*/

CREATE PROCEDURE proc_brisanje
(
	@Sifra NVARCHAR(10)
)
AS
BEGIN
	DELETE FROM SkladisteProizvodi
	WHERE ProizvodID=(SELECT ProizvodID
					  FROM Proizvodi
					  WHERE Sifra=@Sifra)
	
	DELETE FROM Proizvodi
	WHERE Sifra=@Sifra
END;

EXEC proc_brisanje @Sifra='AM-AR1881'
EXEC proc_brisanje @Sifra='BK-R93R-62'

select* from Proizvodi
select* from SkladisteProizvodi
GO

/*9. Kreirati uskladištenu proceduru koja će za unesenu šifru proizvoda, oznaku skladišta 
ili lokaciju skladišta vršiti pretragu prethodno kreiranim view-om (zadatak 5). Procedura
 obavezno treba da vraća rezultate bez obrzira da li su vrijednosti parametara postavljene. 
 Testirati ispravnost procedure u sljedećim situacijama:
a) Nije postavljena vrijednost niti jednom parametru (vraća sve zapise)
b) Postavljena je vrijednost parametra šifra proizvoda, a ostala dva parametra nisu
c) Postavljene su vrijednosti parametra šifra proizvoda i oznaka skladišta, a lokacija nije
d) Postavljene su vrijednosti parametara šifre proizvoda i lokacije, a oznaka skladišta nije
e) Postavljene su vrijednosti sva tri parametra*/


SELECT* FROM view_sifranaziv
GO

CREATE PROCEDURE proc_pretraga
(
	@Sifra NVARCHAR(10)='',
	@Oznaka NVARCHAR(10)='',
	@Lokacija NVARCHAR(50)=''
)
AS
BEGIN
	SELECT*
	FROM view_sifranaziv
	WHERE(view_sifranaziv.Sifra LIKE @Sifra+'%'  AND view_sifranaziv.Oznaka LIKE @Oznaka+'%')
	 OR view_sifranaziv.Lokacija LIKE @Lokacija
END;
drop procedure proc_pretraga
GO

EXECUTE proc_pretraga
EXECUTE proc_pretraga 'BK-R93R-44'
EXECUTE proc_pretraga 'BK-R93R-44' , 'SK2'
EXECUTE proc_pretraga 'BK-R93R-44' ,'SK2' ,'Mostar'
EXECUTE proc_pretraga  @Lokacija = 'Mostar' , @Sifra = 'BK-R93R-44'

/*10. Napraviti full i diferencijalni backup baze podataka na default lokaciju servera*/

BACKUP DATABASE ProSkla
TO DISK = 'C:\Users\Amar Sabic\Desktop\ProSkla\ProSkla.bak'


BACKUP DATABASE ProSkla
TO DISK = 'C:\Users\Amar Sabic\Desktop\ProSkla\ProSkla.bak'
WITH DIFFERENTIAL