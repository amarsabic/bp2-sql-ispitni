CREATE DATABASE Baza57
USE Baza57

/*
a) Klijenti
i. KlijentID, automatski generator vrijednosti i primarni ključ
ii. Ime, polje za unos 30 UNICODE karaktera (obavezan unos)
iii. Prezime, polje za unos 30 UNICODE karaktera (obavezan unos)
iv. Telefon, polje za unos 20 UNICODE karaktera (obavezan unos)
v. Mail, polje za unos 50 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
vi. BrojRacuna, polje za unos 15 UNICODE karaktera (obavezan unos)
vii. KorisnickoIme, polje za unos 20 UNICODE karaktera (obavezan unos)
viii. Lozinka, polje za unos 20 UNICODE karaktera (obavezan unos)
*/

CREATE TABLE Klijenti
(
	KlijentID INT CONSTRAINT PK_Klijenti PRIMARY KEY IDENTITY(1,1),
	Ime NVARCHAR(30) NOT NULL,
	Prezime NVARCHAR(30) NOT NULL,
	Telefon NVARCHAR(25) NOT NULL,
	Mail NVARCHAR(50) NOT NULL CONSTRAINT UQ_Mail UNIQUE,
	BrojRacuna NVARCHAR(15) NOT NULL,
	KorisnickoIme NVARCHAR(20) NOT NULL,
	Lozinka NVARCHAR(20) NOT NULL
);


/*b)
 Transakcije
i. TransakcijaID, automatski generator vrijednosti i primarni ključ
ii. Datum, polje za unos datuma i vremena (obavezan unos)
iii. TipTransakcije, polje za unos 30 UNICODE karaktera (obavezan unos)
iv. PosiljalacID, referenca na tabelu Klijenti (obavezan unos)
v. PrimalacID, referenca na tabelu Klijenti (obavezan unos)
vi. Svrha, polje za unos 50 UNICODE karaktera (obavezan unos)
vii. Iznos, polje za unos decimalnog broja (obavezan unos)*/

CREATE TABLE Transakcija
(
	TransakcijaID INT CONSTRAINT PK_Transakcija PRIMARY KEY IDENTITY(1,1),
	Datum DATETIME NOT NULL,
	TipTransakcije NVARCHAR(30) NOT NULL,

	PosiljalacID INT NOT NULL CONSTRAINT FK_Posiljalac_Transakcija 
			FOREIGN KEY REFERENCES Klijenti(KlijentID),
	PrimalacID INT NOT NULL CONSTRAINT FK_Primalac_Transakcija 
			FOREIGN KEY REFERENCES Klijenti(KlijentID),

	Svrha NVARCHAR(50) NOT NULL,
	Iznos DECIMAL(5,2) NOT NULL
);


/*a) Koristeći bazu podataka AdventureWorks2014, preko INSERT i SELECT komande importovati
 10 kupaca u tabelu Klijenti. Ime, prezime, telefon, mail i broj računa (AccountNumber) preuzeti 
 od kupca, korisničko ime generisati na osnovu imena i prezimena u formatu ime.prezime, a lozinku
 generisati na osnovu polja PasswordHash, i to uzeti samo zadnjih 8 karaktera.*/

select*
from Klijenti
select*
from AdventureWorks2014.Person.Person
 
 INSERT INTO Klijenti
 (Ime, Prezime, Telefon, Mail, BrojRacuna, KorisnickoIme, Lozinka)
 SELECT TOP 10 PP.FirstName, PP.LastName, PH.PhoneNumber, EA.EmailAddress, C.AccountNumber,
		(PP.FirstName+'.'+PP.LastName) AS UserName, RIGHT(P.PasswordHash,8)
FROM AdventureWorks2014.Person.Person AS PP
	INNER JOIN AdventureWorks2014.Person.PersonPhone AS PH
ON PP.BusinessEntityID=PH.BusinessEntityID
	INNER JOIN AdventureWorks2014.Person.EmailAddress AS EA
ON PP.BusinessEntityID=EA.BusinessEntityID
	INNER JOIN AdventureWorks2014.Sales.Customer AS C
ON PP.BusinessEntityID=C.CustomerID
	INNER JOIN AdventureWorks2014.Person.Password AS P
ON PP.BusinessEntityID=P.BusinessEntityID

/*b) Putem jedne INSERT komande u tabelu Transakcije dodati minimalno 10 transakcija.*/

select* from Transakcija
select*
from Klijenti

INSERT INTO Transakcija (Datum, TipTransakcije, PosiljalacID, PrimalacID, Svrha, Iznos)
VALUES (23-12-2019, 'CASH', 2104, 2105, 'Donacija', 312.01),
		(23-12-2019, 'WU', 2107, 2108, 'Uplata', 215.01),
		 (23-12-2019, 'Card',2109, 2108, 'Uplata', 215.01),
		  (23-12-2019, 'Card', 2105, 2107, 'Donacija', 225.01),
		   (23-12-2019, 'Card', 2112, 2107, 'Uplata', 225.01),
		    (23-12-2019, 'WU', 2108, 2109, 'Uplata', 225.01),
			 (23-12-2019, 'CASH', 2107, 2109, 'Uplata', 425.01),
			  (23-12-2019, 'WU', 2113,2105, 'Donacija', 245.01),
			   (23-12-2019, 'CASH', 2111, 2112, 'Donacija', 245.01),
			    (23-12-2019, 'WU', 2105, 2108, 'Uplata', 245.01)
				
/*3. Kreiranje indeksa u bazi podataka nada tabelama:*/

/*a) Non-clustered indeks nad tabelom Klijenti. Potrebno je indeksirati Ime i Prezime.
 Također, potrebno je uključiti kolonu BrojRacuna.*/

 CREATE NONCLUSTERED INDEX IX_ImePrezime
 ON Klijenti (Ime, Prezime)
 INCLUDE(BrojRacuna)

 /*b) Napisati proizvoljni upit nad tabelom Klijenti koji u potpunosti iskorištava indeks 
 iz prethodnog koraka. Upit obavezno mora imati filter.*/

 SELECT*
 FROM Klijenti
 WHERE BrojRacuna='AW00000285' AND Ime LIKE '%d' AND Prezime LIKE 'Abbas'

/*c) Uraditi disable indeksa iz koraka a) 5*/

 ALTER INDEX IX_ImePrezime ON Klijenti
 DISABLE

/*4. Kreirati uskladištenu proceduru koja će vršiti upis novih klijenata.
Kao parametre proslijediti sva polja. Provjeriti ispravnost kreirane procedure.*/

 SELECT*
 FROM Klijenti
 GO

  CREATE PROCEDURE proc_upis
  (
	@Ime NVARCHAR(30),
	@Prezime NVARCHAR(30),
	@Telefon NVARCHAR(25),
	@Mail NVARCHAR(50),
	@BrojRacuna NVARCHAR(15),
	@KorisnickoIme NVARCHAR(20),
	@Lozinka NVARCHAR(20) 
  )
  AS
  BEGIN
	INSERT INTO Klijenti(Ime, Prezime, Telefon, Mail, BrojRacuna, KorisnickoIme, Lozinka)
	VALUES (@Ime, @Prezime, @Telefon, @Mail, @BrojRacuna, @KorisnickoIme, @Lozinka)
  END;
 
EXECUTE proc_upis 'Ime', 'Prezime', '000-000-000', 'mail@fit.ba', 'AABB1122', 'username', 'adminadmin'
GO

/*
5.Kreirati view sa sljedećom definicijom. Objekat treba da prikazuje datum transakcije, 
tip transakcije, ime i prezime pošiljaoca (spojeno), broj računa pošiljaoca, ime i prezime
primaoca (spojeno), broj računa primaoca, svrhu i iznos transakcije.
*/

CREATE VIEW view_pogled1
AS
SELECT T.Datum, T.TipTransakcije, 
		(SELECT Ime+' '+Prezime
		 FROM Klijenti 
		 WHERE T.PosiljalacID=Klijenti.KlijentID) AS Posiljaoc,

		 (SELECT BrojRacuna
		 FROM Klijenti 
		 WHERE T.PosiljalacID=Klijenti.KlijentID) AS BrojRacunaPosiljaoca,

		 (SELECT Ime+' '+Prezime
		 FROM Klijenti 
		 WHERE T.PrimalacID=Klijenti.KlijentID) AS Primalac,

		  (SELECT BrojRacuna
		 FROM Klijenti 
		 WHERE T.PrimalacID=Klijenti.KlijentID) AS BrojRacunaPrimaoca,

		 T.Svrha, T.Iznos
FROM Transakcija AS T

SELECT* FROM view_pogled1
GO

 /*
 6. Kreirati uskladištenu proceduru koja će na osnovu unesenog broja računa pošiljaoca
  prikazivati sve transakcije koje su provedene sa računa klijenta. U proceduri koristiti
   prethodno kreirani view. Provjeriti ispravnost kreirane procedure.
 */

CREATE PROCEDURE proc_pretraga
(
	@BrojRacuna NVARCHAR(15)
)
AS
BEGIN
	SELECT*
	FROM view_pogled1
	WHERE BrojRacunaPosiljaoca = @BrojRacuna OR BrojRacunaPrimaoca=@BrojRacuna
END;
GO

EXEC proc_pretraga 'AW00000211'

/*
7.Kreirati upit koji prikazuje sumaran iznos svih transakcija po godinama, 
sortirano po godinama. U rezultatu upita
prikazati samo dvije kolone: kalendarska godina i ukupan iznos transakcija u godini.
*/

SELECT YEAR(Datum) AS Datum, SUM(Iznos) AS [Ukupan iznos transakcija u godini]
FROM Transakcija
GROUP BY YEAR(Datum)
GO

/*
8.Kreirati uskladištenu proceduru koje će vršiti brisanje klijenta uključujući sve njegove
transakcije, bilo da je za
transakciju vezan kao pošiljalac ili kao primalac. Provjeriti ispravnost kreirane procedure.
*/

select* from Transakcija
select* from Klijenti

CREATE PROCEDURE proc_brisanje
(
	@KlijentID INT
)
AS
BEGIN
	DELETE FROM Transakcija
	WHERE PosiljalacID = @KlijentID OR PrimalacID=@KlijentID

	DELETE FROM Klijenti
	WHERE KlijentID = @KlijentID
END;
GO

EXEC proc_brisanje 2104

/*
9. Kreirati uskladištenu proceduru koja će na osnovu unesenog broja računa ili prezimena 
pošiljaoca vršiti pretragu
nad prethodno kreiranim view-om (zadatak 5). Testirati ispravnost procedure u sljedećim
 situacijama:
a) Nije postavljena vrijednost niti jednom parametru (vraća sve zapise)
b) Postavljena je vrijednost parametra broj računa,
c) Postavljena je vrijednost parametra prezime,
d) Postavljene su vrijednosti oba parametra.
*/

CREATE PROCEDURE proc_pretraga2
(
	@BrojRacuna NVARCHAR(15) = NULL,
	@Prezime NVARCHAR(30)=NULL
)
AS
BEGIN
	SELECT*
	FROM view_pogled1
	WHERE (BrojRacunaPosiljaoca = @BrojRacuna OR @BrojRacuna IS NULL) AND
			(SUBSTRING(Posiljaoc,CHARINDEX(' ',Posiljaoc)+1,LEN(Posiljaoc)) LIKE @Prezime OR @Prezime IS NULL)
END;
GO

drop procedure proc_pretraga2

EXEC proc_pretraga2
EXEC proc_pretraga2 @BrojRacuna='AW00000295'
EXEC proc_pretraga2 @Prezime='Abolrous'


/*
10. Napraviti full i diferencijalni backup baze podataka na default lokaciju servera:
*/

BACKUP DATABASE Baza57
TO DISK ='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\Baza57.bak'

BACKUP DATABASE Baza57
TO DISK ='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\Baza57.diff'
WITH DIFFERENTIAL

