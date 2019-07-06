CREATE DATABASE Baza67
USE Baza67

/*
1. Kroz SQL kod, napraviti bazu podataka koja nosi ime vašeg broja dosijea. U postupku kreiranja u obzir uzeti samo DEFAULT postavke.
*/

/*
a) Studenti
i. StudentID, automatski generator vrijednosti i primarni ključ
ii. BrojDosijea, polje za unos 10 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
iii. Ime, polje za unos 35 UNICODE karaktera (obavezan unos)
iv. Prezime, polje za unos 35 UNICODE karaktera (obavezan unos)
v. Godina studija, polje za unos cijelog broja (obavezan unos)
vi. NacinStudiranja, polje za unos 10 UNICODE karaktera (obavezan unos) DEFAULT je Redovan
vii. Email, polje za unos 50 karaktera (nije obavezan)
*/

CREATE TABLE Studenti
(
	StudentID INT IDENTITY(1,1) CONSTRAINT PK_Student PRIMARY KEY,
	BrojDosijea NVARCHAR(10) NOT NULL CONSTRAINT UQ_BrojDosijea UNIQUE,
	Ime NVARCHAR(35) NOT NULL,
	Prezime NVARCHAR(35) NOT NULL,
	GodinaStudija INT NOT NULL,
	NacinStudiranja NVARCHAR(10) NOT NULL DEFAULT 'Redovan',
	Email NVARCHAR(50)
);

/*
b) Predmeti
i. PredmetID, automatski generator vrijednosti i primarni ključ
ii. Naziv, polje za unos 100 UNICODE karaktera (obavezan unos)
iii. Oznaka, polje za unos 10 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
*/

CREATE TABLE Predmeti
(
	PredmetID INT IDENTITY(1,1) CONSTRAINT PK_Predmet PRIMARY KEY,
	Naziv NVARCHAR(100) NOT NULL,
	Oznaka NVARCHAR(10) NOT NULL CONSTRAINT UQ_Oznaka UNIQUE
);

/*
c) Ocjene
i. Ocjena, polje za unos cijelih brojeva (obavezan unos)
ii. Bodovi, polje za unos decimalnih brojeva (obavezan unos)
iii. DatumPolaganja, polje za unos datuma (obavezan unos)
*/

/*
Napomena: Student može dobiti ocjenu iz više predmeta, dok iz istog predmeta ocjenu može 
dobiti više studenata. Student ne može dobiti više ocjena iz istog predmeta.
*/

CREATE TABLE Ocjene
(
	StudentID INT NOT NULL CONSTRAINT FK_Student_Ocjene FOREIGN KEY REFERENCES
					Studenti(StudentID),
	PredmetID INT NOT NULL CONSTRAINT FK_Predmet_Ocjene FOREIGN KEY REFERENCES
					Predmeti(PredmetID),
	CONSTRAINT PK_Ocjene_Predmet_Student PRIMARY KEY(StudentID, PredmetID),

	Ocjena INT NOT NULL,
	Bodovi DECIMAL NOT NULL,
	DatumPolaganja DATE NOT NULL
);

/*
a) Putem jedne komande INSERT u tabelu Predmeti dodati minimalno 3 predmeta
*/

INSERT INTO Predmeti(Naziv, Oznaka)
VALUES('Programiranje III', 'PRIII'),
	  ('Baze podataka II', 'BPII'),
	  ('Analiza i dizajn softvera', 'ADS')

SELECT* FROM Predmeti

/*
b) Koristeći bazu podataka AdventureWorks2014, preko INSERT i SELECT komande importovati
10 kupaca u tabelu Studenti i to sljedeće kolone:
i. AccountNumber -> BrojDosijea
ii. FirstName -> Ime
iii. LastName -> Prezime
iv. 2 -> GodinaStudija
v. DEFAULT -> NacinStudiranja
vi. EmailAddress -> Email
*/

INSERT INTO Studenti (BrojDosijea, Ime, Prezime, GodinaStudija,Email)
SELECT C.AccountNumber, P.FirstName, P.LastName, 2, EA.EmailAddress
FROM AdventureWorks2014.Person.Person AS P
	INNER JOIN AdventureWorks2014.Sales.Customer AS C
ON P.BusinessEntityID=C.CustomerID
	INNER JOIN AdventureWorks2014.Person.EmailAddress AS EA
ON P.BusinessEntityID=EA.BusinessEntityID
GO

/*
3. Kreirati uskladištenu proceduru koja će vršiti upis podataka u tabelu Ocjene (sva polja).
 Provjerom ispravnosti procedure unijeti minimalno 5 zapisa u tabelu Ocjene.
*/

CREATE PROCEDURE proc_upisOcjena
(
	@StudentID INT,
	@PredmetID INT,
	@Ocjena INT,
	@Bodovi DECIMAL,
	@DatumPolaganja DATE
)
AS
BEGIN
	INSERT INTO Ocjene
	VALUES(@StudentID, @PredmetID, @Ocjena, @Bodovi, @DatumPolaganja)
END;
GO

EXEC proc_upisOcjena 1,1,9,90,'6/7/2019'
EXEC proc_upisOcjena 2,2,8,76,'6/7/2019'
EXEC proc_upisOcjena 3,3,6,60,'6/7/2019'
EXEC proc_upisOcjena 4,1,7,68,'6/7/2019'
EXEC proc_upisOcjena 5,3,9,93,'6/7/2019'


/*
4. Također, u svoju bazu podataka putem Import/Export alata prebaciti sljedeće tabele
sa podacima: CreditCard, PersonCreditCard i Person koje se nalaze u AdventureWorks2014
bazi podataka.
*/

/* https://www.youtube.com/watch?v=H8IGjzMO72g&list=PLy-wPT_Y-K8ymqYlSPqbf8fhjfwIw2oVG&index=25 */

/*
5. Kreiranje indeksa u bazi podataka nada tabelama koje ste importovali u zadatku broj 2:
*/

/*
a) Non-clustered indeks nad tabelom Person. Potrebno je indeksirati Lastname i FirstName.
Također, potrebno je uključiti kolonu Title.
*/

CREATE NONCLUSTERED INDEX IX_FirstLastName 
ON Person.Person(LastName,FirstName)
INCLUDE(Title)

/*
b) Napisati proizvoljni upit nad tabelom Person koji u potpunosti iskorištava indeks iz prethodnog koraka
*/

SELECT LastName, FirstName, Title
FROM Person.Person
WHERE Title='Ms.' AND FirstName LIKE '%e'

/*c) Uraditi disable indeksa iz koraka a)*/

ALTER INDEX IX_FirstLastName 
ON Person.Person
DISABLE

/*d) Clustered indeks nad tabelom CreditCard i kolonom CreditCardID*/

CREATE CLUSTERED INDEX IX_Credit
ON Sales.CreditCard(CreditCardID)

/*
e) Non-clustered indeks nad tabelom CreditCard i kolonom CardNumber.
 Također, potrebno je uključiti kolone ExpMonth i ExpYear.
*/

CREATE NONCLUSTERED INDEX IX_CardNumber
ON Sales.CreditCard(CardNumber)
INCLUDE(ExpMonth, ExpYear)

GO
/*
6. Kreirati view sa sljedećom definicijom. Objekat treba da prikazuje:
Prezime, ime, broj kartice i tip kartice, ali samo onim osobama koje 
imaju karticu tipa Vista i nemaju titulu.
*/

CREATE VIEW view_kartica
AS
SELECT P.LastName, P.FirstName, CC.CardNumber, CC.CardType
FROM Person.Person AS P
	INNER JOIN Sales.PersonCreditCard PCC
ON P.BusinessEntityID=PCC.BusinessEntityID
	INNER JOIN Sales.CreditCard CC
ON PCC.CreditCardID=CC.CreditCardID
WHERE CC.CardType = 'Vista' AND P.Title IS NULL
GO

SELECT* FROM view_kartica

/*
7. Napraviti full i diferencijalni backup baze podataka na default lokaciju servera:
*/

BACKUP DATABASE Baza67
TO DISK ='DEFAULT'
GO

BACKUP DATABASE Baza67
TO DISK ='DEFAULT'
WITH DIFFERENTIAL
GO

/*
9. Kreirati uskladištenu proceduru koja će za uneseno prezime, ime ili broj kartice vršiti
pretragu nad prethodno kreiranim view-om (zadatak 4). Procedura obavezno treba da vraća
rezultate bez obzira da li su vrijednosti parametara postavljene. Testirati ispravnost 
procedure u sljedećim situacijama:
a) Nije postavljena vrijednost niti jednom parametru (vraća sve zapise)
b) Postavljena je vrijednost parametra prezime, a ostala dva parametra nisu
   (pretraga po prezimenu)
c) Postavljene su vrijednosti parametara prezime i ime, a broj kartice nije 
   (pretraga po prezimenu i imenu)
d) Postavljene su vrijednosti sva tri parametra (pretraga po svim parametrima)
Također, procedura treba da pretragu prezimena i imena vrši parcijalno (počinje sa).
*/

CREATE PROCEDURE proc_pretraga
(
	@LastName NVARCHAR(50)=NULL,
	@FirstName NVARCHAR(50)=NULL,
	@CardNumber NVARCHAR(25)=NULL
)
AS
BEGIN
	SELECT LastName, FirstName, CardNumber, CardType
	FROM view_kartica
	WHERE (LastName LIKE @LastName+'%' OR @LastName IS NULL) AND
		   (FirstName LIKE @FirstName+'%' OR @FirstName IS NULL) AND
			(CardNumber = @CardNumber OR @CardNumber IS NULL)
END;
GO

DROP PROCEDURE proc_pretraga

EXEC proc_pretraga
EXEC proc_pretraga @LastName = 'Barzdukas' 
EXEC proc_pretraga @LastName = 'Barzdukas', @FirstName='Gytis'
EXEC proc_pretraga @LastName = 'Barzdukas', @FirstName='Gytis', @CardNumber='11112120890200'
GO
/*
10. Kreirati uskladištenu proceduru koje će za uneseni broj kartice vršiti brisanje kreditne
kartice (CreditCard). Također, u istoj proceduri (u okviru jedne transakcije) prethodno 
obrisati sve zapise o vlasništvu kartice (PersonCreditCard). Obavezno testirati ispravnost 
kreirane procedure.
*/

CREATE PROCEDURE proc_brisanje
(
	@CardNumber NVARCHAR(25)
)
AS
BEGIN
	DELETE FROM Sales.PersonCreditCard
	WHERE CreditCardID = (SELECT CreditCardID
						  FROM Sales.CreditCard
						  WHERE CardNumber=@CardNumber)

	DELETE FROM Sales.CreditCard
	WHERE CardNumber = @CardNumber
END;
GO

EXECUTE proc_brisanje @CardNumber='11112120890200';

