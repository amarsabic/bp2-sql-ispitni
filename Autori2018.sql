CREATE DATABASE Baza47
USE Baza47

/*Autori
• AutorID, 11 UNICODE karaktera i primarni ključ
• Prezime, 25 UNICODE karaktera (obavezan unos)
• Ime, 25 UNICODE karaktera (obavezan unos) • Telefon, 20 UNICODE karaktera, DEFAULT je NULL
• DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa • DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL*/

CREATE TABLE Autori
(
	AutorID NVARCHAR(11) CONSTRAINT PK_Autor PRIMARY KEY,
	Prezime NVARCHAR(25) NOT NULL,
	Ime NVARCHAR(25) NOT NULL,
	Telefon NVARCHAR(20) DEFAULT NULL,
	DatumKreiranjaZapisa DATE NOT NULL DEFAULT GETDATE(),
	DatumModifikovanjaZapisa DATE DEFAULT NULL
);

/*Izdavaci
• IzdavacID, 4 UNICODE karaktera i primarni ključ
• Naziv, 100 UNICODE karaktera (obavezan unos), jedinstvena vrijednost • Biljeske, 1000 UNICODE karaktera, DEFAULT tekst je Lorem ipsum
• DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa • DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL*/

CREATE TABLE Izdavac
(
	IzdavacID NVARCHAR(4) CONSTRAINT PK_Izdavac PRIMARY KEY,
	Naziv NVARCHAR(100) NOT NULL CONSTRAINT UQ_Naziv UNIQUE,
	Biljeske NVARCHAR(1000) NOT NULL CONSTRAINT UQ_Biljeske UNIQUE DEFAULT 'Lorem ipsum',
	DatumKreiranjaZapisa DATE NOT NULL DEFAULT GETDATE(),
	DatumModifikovanjaZapisa DATE DEFAULT NULL
);

/*Naslovi
• NaslovID, 6 UNICODE karaktera i primarni ključ
• IzdavacID, spoljni ključ prema tabeli „Izdavaci“
• Naslov, 100 UNICODE karaktera (obavezan unos)
• Cijena, monetarni tip podatka
• DatumIzdavanja, datum izdanja naslova (obavezan unos) DEFAULT je datum unosa zapisa
• DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa • DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL*/

CREATE TABLE Naslovi
(
	NaslovID NVARCHAR(6) CONSTRAINT PK_Naslov PRIMARY KEY,
	IzdavacID NVARCHAR(4) NOT NULL CONSTRAINT FK_Izdavac_Naslovi
				 FOREIGN KEY REFERENCES Izdavac(IzdavacID),
	Naslov NVARCHAR(100) NOT NULL,
	Cijena MONEY,
	DatumIzdavanja DATE NOT NULL DEFAULT GETDATE(),
	DatumKreiranjaZapisa DATE NOT NULL DEFAULT GETDATE(),
	DatumModifikovanjaZapisa DATE DEFAULT NULL
);

/*NasloviAutori (Više autora može raditi na istoj knjizi)
• AutorID, spoljni ključ prema tabeli „Autori“
• NaslovID, spoljni ključ prema tabeli „Naslovi“
• DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je 
datum unosa zapisa
 • DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa
, DEFAULT je NULL*/

CREATE TABLE NasloviAutori
(
	NaslovID NVARCHAR(6) NOT NULL CONSTRAINT FK_Naslov_NasloviAutori 
				FOREIGN KEY REFERENCES Naslovi(NaslovID),
	AutorID NVARCHAR(11) NOT NULL CONSTRAINT FK_Autor_NasloviAutori 
				FOREIGN KEY REFERENCES Autori(AutorID),
	CONSTRAINT PK_Naslov_Autori PRIMARY KEY(NaslovID, AutorID),

	DatumKreiranjaZapisa DATE NOT NULL DEFAULT GETDATE(),
	DatumModifikovanjaZapisa DATE DEFAULT NULL
);


/*• Iz baze podataka pubs tabela „authors“, a putem podupita u tabelu „Autori“ 
importovati sve slučajno sortirane zapise. Vodite računa da mapirate odgovarajuće kolone.*/

select* from Autori
select* from pubs.dbo.authors

INSERT INTO Autori(AutorID, Prezime, Ime, Telefon)
SELECT au_id, au_lname, au_fname, phone
FROM pubs.dbo.authors
WHERE au_id IN (select au_id
			from pubs.dbo.authors)
ORDER BY newid()

/*• Iz baze podataka pubs i tabela („publishers“ i pub_info“), 
a putem podupita u tabelu „Izdavaci“ importovati sve slučajno sortirane zapise.
Kolonu pr_info mapirati kao bilješke i iste skratiti na 100 karaktera.
Vodite računa da mapirate odgovarajuće kolone i tipove podataka.*/

select* from Izdavac
select* from pubs.dbo.publishers
select* from pubs.dbo.pub_info

INSERT INTO Izdavac(IzdavacID, Naziv, Biljeske)
SELECT P.pub_id, P.pub_name, 
	(SELECT LEFT(CONVERT(NVARCHAR(1000),PI.pr_info), 100)
	 FROM pubs.dbo.pub_info AS PI
	 WHERE P.pub_id = PI.pub_id)
FROM pubs.dbo.publishers AS P
ORDER BY newid()

/*• Iz baze podataka pubs tabela „titles“, a putem podupita u tabelu „Naslovi“
 importovati sve zapise. Vodite računa da mapirate odgovarajuće kolone.*/

 select*from Naslovi

 INSERT INTO Naslovi(NaslovID, IzdavacID, Naslov, Cijena)
 SELECT title_id, pub_id, title, price
 FROM pubs.dbo.titles

 /*• Iz baze podataka pubs tabela „titleauthor“, a putem podupita u tabelu „NasloviAutori“ zapise.
  Vodite računa da mapirate odgovarajuće kolone.*/

 select*from NasloviAutori

 INSERT INTO NasloviAutori(NaslovID, AutorID)
 SELECT title_id, au_id
 FROM pubs.dbo.titleauthor

 /*Kreiranje nove tabele, importovanje podataka i modifikovanje postojeće tabele:*/

 /*Gradovi
• GradID, automatski generator vrijednost čija početna vrijednost je 5 i uvećava se za 5, 
  primarni ključ
• Naziv, 100 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
• DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa 
• DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL
✓ Iz baze podataka pubs tabela „authors“, a putem podupita u tabelu „Gradovi“ importovati
   nazive gradove bez duplikata.
✓ Modifikovati tabelu Autori i dodati spoljni ključ prema tabeli Gradovi:*/

CREATE TABLE Gradovi
(
	GradID INT IDENTITY(5,5) CONSTRAINT PK_Grad PRIMARY KEY,
	Naziv NVARCHAR(100) NOT NULL CONSTRAINT UQ_Grad UNIQUE,
	DatumKreiranjaZapisa DATE NOT NULL DEFAULT GETDATE(),
	DatumModifikovanjaZapisa DATE DEFAULT NULL
);

select* from Gradovi
select* from pubs.dbo.authors

INSERT INTO Gradovi(Naziv)
SELECT DISTINCT city
FROM pubs.dbo.authors
WHERE city IN (SELECT DISTINCT city
			   FROM pubs.dbo.authors)

ALTER TABLE Autori
ADD GradID INT CONSTRAINT FK_Grad_Autori FOREIGN KEY REFERENCES Gradovi(GradID)
GO

/*Kreirati dvije uskladištene proceduru koja će modifikovati podataka u tabeli Autori:
• Prvih deset autora iz tabele postaviti da su iz grada:
 San Francisco
 • Ostalim autorima podesiti grad na: Berkeley
Vodite računa da se u tabeli modifikuju sve potrebne kolone.*/

CREATE PROCEDURE proc_grad
AS
BEGIN
	UPDATE TOP (10) Autori
	SET GradID=(SELECT GradID
				FROM Gradovi
				WHERE Naziv='San Francisco')
	
	UPDATE  Autori
	SET GradID=(SELECT GradID
				FROM Gradovi
				WHERE Naziv='Berkeley')
	WHERE GradID IS NULL
END;

EXECUTE proc_grad
GO

/*Kreirati pogled sa sljedećom definicijom: Prezime i ime autora (spojeno), grad, naslov, 
cijena, izdavač i bilješke, ali samo za one autore čije knjige imaju određenu cijenu i gdje
je cijena veća od 10. Također, naziv izdavača u sredini imena treba imati slovo „&“ i da su
iz grada San Francisco . Obavezno testirati funkcionalnost view objekta.*/

CREATE VIEW view_autori1
AS
SELECT (A.Prezime+' '+A.Ime) AS [Ime i prezime], GradID, N.Naslov, N.Cijena, REPLACE(I.Naziv, ' ','&') AS [Izdavac], I.Biljeske
FROM Autori A
	INNER JOIN NasloviAutori NA
ON A.AutorID=NA.AutorID
	INNER JOIN Naslovi AS N
ON NA.NaslovID=N.NaslovID
	INNER JOIN Izdavac I
ON N.IzdavacID=I.IzdavacID
WHERE N.Cijena > 0 AND N.Cijena>10

SELECT* FROM view_autori1
GO

/*Modifikovati tabelu Autori i dodati jednu kolonu:
• Email, polje za unos 100 UNICODE karaktera, DEFAULT je NULL*/

ALTER TABLE Autori
ADD Email NVARCHAR(100) DEFAULT NULL

select* from Autori
GO
/*Kreirati dvije uskladištene proceduru koje će modifikovati podatke u tabelu Autori 
i svim autorima generisati novu email adresu: 
• Prva procedura: u formatu: Ime.Prezime@fit.ba svim autorima iz grada San Francisco 
• Druga procedura: u formatu: Prezime.Ime@fit.ba svim autorima iz grada Berkeley*/

CREATE PROCEDURE proc_email1
AS
BEGIN
	UPDATE Autori
	SET Email=Ime+'.'+Prezime+'@fit.ba'
	WHERE GradID = (SELECT GradID
					FROM Gradovi
					WHERE Naziv='San Francisco')
END;
GO

CREATE PROCEDURE proc_email2
AS
BEGIN
	UPDATE Autori
	SET Email=Prezime+'.'+Ime+'@fit.ba'
	WHERE GradID = (SELECT GradID
					FROM Gradovi
					WHERE Naziv='Berkeley')
END;

EXEC proc_email1
EXEC proc_email2
GO

/*Iz baze podataka AdventureWorks2014 u lokalnu, privremenu, tabelu u vašu bazi podataka importovati 
zapise o osobama, a putem podupita. Lista kolona je: Title, LastName, FirstName, EmailAddress,
PhoneNumber i CardNumber. Kreirate dvije dodatne kolone: UserName koja se sastoji od spojenog imena i
prezimena (tačka se nalazi između) i kolonu Password za lozinku sa malim slovima dugačku
16 karaktera. Lozinka se generiše putem SQL funkciju za slučajne i jedinstvene ID vrijednosti. 
Iz lozinke trebaju biti uklonjene sve crtice „-“ i zamijenjene brojem „7“. Uslovi su da podaci 
uključuju osobe koje imaju i nemaju kreditnu karticu, a NULL vrijednost u koloni Titula zamjeniti
sa podatkom 'N/A'. Sortirati prema prezimenu i imenu. Testirati da li je tabela sa podacima 
kreirana.*/


SELECT ISNULL(PP.Title,'N/A') AS Title, PP.LastName, PP.FirstName, EA.EmailAddress, PH.PhoneNumber,
		CC.CardNumber, (PP.FirstName+'.'+PP.LastName) AS UserName,
		 LOWER(REPLACE(LEFT(newid(),16),'-', '7')) AS Password
INTO #temp1
FROM AdventureWorks2014.Person.Person AS PP
	INNER JOIN AdventureWorks2014.Person.EmailAddress AS EA
ON PP.BusinessEntityID=EA.BusinessEntityID
	INNER JOIN AdventureWorks2014.Person.PersonPhone AS PH
ON PP.BusinessEntityID=PH.BusinessEntityID
	LEFT OUTER JOIN AdventureWorks2014.Sales.PersonCreditCard AS PC
ON PP.BusinessEntityID=PC.BusinessEntityID
	LEFT OUTER JOIN AdventureWorks2014.Sales.CreditCard AS CC
ON PC.CreditCardID=CC.CreditCardID



SELECT* FROM #temp1
ORDER BY 2,3


/*Kreirati indeks koji će nad privremenom tabelom iz prethodnog koraka, primarno, maksimalno
 ubrzati upite koje koriste kolonu UserName, a sekundarno nad kolonama LastName i FirstName. 
 Napisati testni upit.*/

 CREATE NONCLUSTERED INDEX IX_temp
 ON #temp1 (UserName)
 INCLUDE(FirstName, LastName)

 SELECT*
 FROM #temp1
 WHERE UserName LIKE '%s' AND FirstName LIKE'Syed'
 GO

 /*Kreirati uskladištenu proceduru koja briše sve zapise iz privremene tabele koji
  nemaju kreditnu karticu Obavezno testirati funkcionalnost procedure.*/

 CREATE PROCEDURE proc_brisanje
 AS
 BEGIN
	DELETE FROM #temp1
	WHERE CardNumber IS NULL
 END;
 GO

 EXEC proc_brisanje

 SELECT* FROM #temp1


 /*Kreirati backup vaše baze na default lokaciju servera i nakon toga obrisati privremenu tabelu.*/

 BACKUP DATABASE Baza47
 TO DISK='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\Baza47.bak'

 DROP TABLE #temp1
 GO
 /*Kreirati proceduru koja briše sve zapise iz svih tabela unutar jednog izvršenja.
  Testirati da li su podaci obrisani.*/

  CREATE PROCEDURE proc_obrisiSve
  AS
  BEGIN
  DELETE FROM [dbo].[NasloviAutori]
  DELETE FROM [dbo].[Naslovi]
  DELETE FROM [dbo].[Izdavac]
  DELETE FROM [dbo].[Autori] 
  END;
 
  EXEC proc_obrisiSve

  SELECT* FROM [dbo].[Autori]
    SELECT* FROM [dbo].[Izdavac]
	  SELECT* FROM [dbo].[Naslovi]
	    SELECT* FROM [dbo].[NasloviAutori]

/*Uraditi restore rezervene kopije baze podataka i provjeriti da li su svi
 podaci u izvornom obliku.*/


		