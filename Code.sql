-- Eduola
-- Date de remise: 2 décembre.



/* 1 Creation de la base de donnees */

USE master;
GO

-- Voir si la BD existe deja; si elle existe, la supprimer.
-- SINGLE_USER : si la BD est en cours d'utilisation, la suppression echouerait.
IF EXISTS(
    SELECT 1
    FROM sys.databases
    WHERE name = N'Starplayers'
)
BEGIN
    ALTER DATABASE Starplayers
        SET SINGLE_USER
        WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Starplayers;
END
GO


-- Dossier de l'instance plutot qu'un chemin ecrit en dur : le script fonctionne
-- sur n'importe quel serveur et les fichiers .mdf/.ldf sont supprimes avec la BD.
DECLARE @dossier NVARCHAR(260) =
    CAST(SERVERPROPERTY('InstanceDefaultDataPath') AS NVARCHAR(260));

DECLARE @sql NVARCHAR(MAX) = N'
CREATE DATABASE [Starplayers]
ON PRIMARY
(
    NAME = N''Starplayers'',
    FILENAME = N''' + @dossier + N'Starplayers.mdf'',
    SIZE = 8192KB,
    MAXSIZE = 512MB,
    FILEGROWTH = 8192KB
)
LOG ON
(
    NAME = N''Starplayers_log'',
    FILENAME = N''' + @dossier + N'Starplayers_log.ldf'',
    SIZE = 8192KB,
    MAXSIZE = 256MB,
    FILEGROWTH = 8192KB
);';

EXEC (@sql);
GO

USE Starplayers;
GO





/* 2 Creation des tables */

-- 1. Pays
CREATE TABLE Pays
(
    PaysID SMALLINT IDENTITY(1,1),
    PaysNom VARCHAR(100) NOT NULL,
    PaysCodeIso CHAR(2) NOT NULL
);
GO


-- 2. Entraineur
CREATE TABLE Entraineur
(
    EntraineurID INT IDENTITY(1,1),
    EntraineurNom VARCHAR(100) NOT NULL,
    EntraineurPrenom VARCHAR(100) NOT NULL
);
GO


-- 3. Organisateur
CREATE TABLE Organisateur
(
    OrganisateurID INT IDENTITY(1,1),
    OrganisateurNom VARCHAR(100) NOT NULL,
    OrganisateurPrenom VARCHAR(100) NOT NULL,
    OrganisateurCourriel VARCHAR(255) NOT NULL,
    OrganisateurTelephone VARCHAR(15) NULL
);
GO


-- 4. TypeEtablissement
CREATE TABLE TypeEtablissement
(
    TypeEtablissementID TINYINT IDENTITY(1,1),
    TypeEtablissementNom VARCHAR(100) NOT NULL
);
GO


-- 5. TypeJeu
CREATE TABLE TypeJeu
(
    TypeJeuID TINYINT IDENTITY(1,1),
    TypeJeuNom VARCHAR(100) NOT NULL
);
GO


-- 6. Compagnie (studio, editeur, fournisseur, commanditaire)
CREATE TABLE Compagnie
(
    CompagnieID INT IDENTITY(1,1),
    CompagnieNom VARCHAR(100) NOT NULL,
    PaysID SMALLINT NOT NULL
);
GO


-- 7. Joueur : le pays du joueur donne sa nationalite; EquipeID = son equipe
CREATE TABLE Joueur
(
    JoueurID INT IDENTITY(1,1),
    JoueurPseudo VARCHAR(100) NOT NULL,
    JoueurNom VARCHAR(100) NOT NULL,
    JoueurPrenom VARCHAR(100) NOT NULL,
    JoueurDateNaissance DATE NOT NULL,
    JoueurCourriel VARCHAR(255) NOT NULL,
    PaysID SMALLINT NOT NULL,
    EquipeID INT NULL
);
GO


-- 8. Equipe; La nationalite d'une equipe est celle de ses joueurs (pas de pays dans Equipe)
CREATE TABLE Equipe
(
    EquipeID INT IDENTITY(1,1),
    EquipeNom VARCHAR(100) NOT NULL,
    ChefID INT NOT NULL,
    EntraineurID INT NOT NULL,
    SponsorID INT NULL
);
GO


-- 9. Etablissement
CREATE TABLE Etablissement
(
    EtablissementID INT IDENTITY(1,1),
    EtablissementNom VARCHAR(100) NOT NULL,
    EtablissementAdresse VARCHAR(100) NOT NULL,
    EtablissementVille VARCHAR(100) NOT NULL,
    PaysID SMALLINT NOT NULL,
    TypeEtablissementID TINYINT NOT NULL
);
GO


-- 10. Tournoi
CREATE TABLE Tournoi
(
    TournoiID INT IDENTITY(1,1),
    TournoiNom VARCHAR(100) NOT NULL,
    TournoiDateDebut DATE NOT NULL,
    TournoiDateFin DATE NOT NULL,
    EtablissementID INT NOT NULL,
    OrganisateurID INT NOT NULL
);
GO


-- 11. Jeu : JeuEstEnEquipe = 1 (jeu d'equipe) ou 0 (jeu solo). Le type d'une competition (solo/equipe) se deduit de son jeu.
CREATE TABLE Jeu
(
    JeuID INT IDENTITY(1,1),
    JeuNom VARCHAR(100) NOT NULL,
    JeuAnneeParution SMALLINT NOT NULL,
    JeuEstEnEquipe BIT NOT NULL,
    TypeJeuID TINYINT NOT NULL,
    StudioID INT NOT NULL,
    EditeurID INT NOT NULL,
    FournisseurID INT NULL
);
GO


-- 12. Competition (une seule journee = une seule date)
CREATE TABLE Competition
(
    CompetitionID INT IDENTITY(1,1),
    CompetitionDate DATE NOT NULL,
    TournoiID INT NOT NULL,
    JeuID INT NOT NULL,
    LocalID INT NOT NULL
);
GO


-- 13. Local
CREATE TABLE [Local]
(
    LocalID INT IDENTITY(1,1),
    LocalNom VARCHAR(50) NOT NULL,
    LocalCapacite SMALLINT NULL,
    EtablissementID INT NOT NULL
);
GO


-- 14. Machine (numero de serie au format SP-0000-0000)
CREATE TABLE Machine
(
    MachineID INT IDENTITY(1,1),
    MachineNumeroSerie CHAR(12) NOT NULL,
    MachineProcesseur VARCHAR(35) NOT NULL,
    MachineGraphique VARCHAR(35) NOT NULL,
    MachineMemoire SMALLINT NOT NULL, -- en Go
    MachineSystemeExploitation VARCHAR(25) NOT NULL
);
GO


-- 15. EnregistrementMachine : machine enregistree par un joueur pour un tournoi
CREATE TABLE EnregistrementMachine
(
    TournoiID INT NOT NULL,
    JoueurID INT NOT NULL,
    MachineID INT NOT NULL
);
GO


-- 16. Infraction : avertissement, sanction (1 a 5 points) ou bannissement
CREATE TABLE Infraction
(
    InfractionID INT IDENTITY(1,1),
    InfractionDate DATE NOT NULL,
    InfractionDescription VARCHAR(200) NOT NULL,
    InfractionType VARCHAR(20) NOT NULL,
    InfractionPoints TINYINT NOT NULL,
    JoueurID INT NOT NULL,
    EquipeID INT NULL,
    CompetitionID INT NOT NULL
);
GO


-- 17. Inscription : solo (JoueurID) OU equipe (EquipeID).
CREATE TABLE Inscription
(
    InscriptionID INT IDENTITY(1,1),
    InscriptionDate DATE NOT NULL,
    InscriptionRangFinal SMALLINT NULL,
    CompetitionID INT NOT NULL,
    JoueurID INT NULL,
    EquipeID INT NULL
);
GO





/* 3 Ajout des contraintes et des relations */

-- Pays
ALTER TABLE Pays ADD
    CONSTRAINT PK_Pays PRIMARY KEY (PaysID),
    CONSTRAINT UQ_Pays_Nom UNIQUE (PaysNom),
    CONSTRAINT UQ_Pays_CodeIso UNIQUE (PaysCodeIso);

-- Entraineur
ALTER TABLE Entraineur ADD
    CONSTRAINT PK_Entraineur PRIMARY KEY (EntraineurID);

-- Organisateur
ALTER TABLE Organisateur ADD
    CONSTRAINT PK_Organisateur PRIMARY KEY (OrganisateurID),
    CONSTRAINT UQ_Organisateur_Courriel UNIQUE (OrganisateurCourriel);

-- TypeEtablissement
ALTER TABLE TypeEtablissement ADD
    CONSTRAINT PK_TypeEtablissement PRIMARY KEY (TypeEtablissementID);

-- TypeJeu
ALTER TABLE TypeJeu ADD
    CONSTRAINT PK_TypeJeu PRIMARY KEY (TypeJeuID);

-- Compagnie
ALTER TABLE Compagnie ADD
    CONSTRAINT PK_Compagnie PRIMARY KEY (CompagnieID),
    CONSTRAINT FK_Compagnie_Pays FOREIGN KEY (PaysID) REFERENCES Pays(PaysID);

-- Joueur
ALTER TABLE Joueur ADD
    CONSTRAINT PK_Joueur PRIMARY KEY (JoueurID),
    CONSTRAINT UQ_Joueur_Courriel UNIQUE (JoueurCourriel),
    CONSTRAINT CK_Joueur_DateNaissance CHECK (JoueurDateNaissance <= CAST(GETDATE() AS DATE)),
    CONSTRAINT FK_Joueur_Pays FOREIGN KEY (PaysID) REFERENCES Pays(PaysID);

-- Equipe
ALTER TABLE Equipe ADD
    CONSTRAINT PK_Equipe PRIMARY KEY (EquipeID),
    CONSTRAINT UQ_Equipe_Nom UNIQUE (EquipeNom),
    CONSTRAINT UQ_Equipe_Chef UNIQUE (ChefID),
    CONSTRAINT FK_Equipe_Chef FOREIGN KEY (ChefID) REFERENCES Joueur(JoueurID),
    CONSTRAINT FK_Equipe_Entraineur FOREIGN KEY (EntraineurID) REFERENCES Entraineur(EntraineurID),
    CONSTRAINT FK_Equipe_Sponsor FOREIGN KEY (SponsorID) REFERENCES Compagnie(CompagnieID);

-- Joueur -> Equipe
-- ajoutee ici car Joueur et Equipe se referencent l'une l'autre
ALTER TABLE Joueur ADD
    CONSTRAINT FK_Joueur_Equipe FOREIGN KEY (EquipeID) REFERENCES Equipe(EquipeID);

-- Etablissement
ALTER TABLE Etablissement ADD
    CONSTRAINT PK_Etablissement PRIMARY KEY (EtablissementID),
    CONSTRAINT FK_Etablissement_Pays FOREIGN KEY (PaysID) REFERENCES Pays(PaysID),
    CONSTRAINT FK_Etablissement_Type FOREIGN KEY (TypeEtablissementID) REFERENCES TypeEtablissement(TypeEtablissementID);

-- Tournoi
ALTER TABLE Tournoi ADD
    CONSTRAINT PK_Tournoi PRIMARY KEY (TournoiID),
    CONSTRAINT CK_Tournoi_Dates CHECK (TournoiDateFin >= TournoiDateDebut),
    CONSTRAINT FK_Tournoi_Etablissement FOREIGN KEY (EtablissementID) REFERENCES Etablissement(EtablissementID),
    CONSTRAINT FK_Tournoi_Organisateur FOREIGN KEY (OrganisateurID) REFERENCES Organisateur(OrganisateurID);

-- Jeu
ALTER TABLE Jeu ADD
    CONSTRAINT PK_Jeu PRIMARY KEY (JeuID),
    CONSTRAINT DF_Jeu_EstEnEquipe DEFAULT 0 FOR JeuEstEnEquipe,
    CONSTRAINT CK_Jeu_AnneeParution CHECK (JeuAnneeParution BETWEEN 1950 AND YEAR(GETDATE())),
    CONSTRAINT FK_Jeu_TypeJeu FOREIGN KEY (TypeJeuID) REFERENCES TypeJeu(TypeJeuID),
    CONSTRAINT FK_Jeu_Studio FOREIGN KEY (StudioID) REFERENCES Compagnie(CompagnieID),
    CONSTRAINT FK_Jeu_Editeur FOREIGN KEY (EditeurID) REFERENCES Compagnie(CompagnieID),
    CONSTRAINT FK_Jeu_Fournisseur FOREIGN KEY (FournisseurID) REFERENCES Compagnie(CompagnieID);

-- Local
ALTER TABLE [Local] ADD
    CONSTRAINT PK_Local PRIMARY KEY (LocalID),
    CONSTRAINT UQ_Local_Etablissement_Nom UNIQUE (EtablissementID, LocalNom),
    CONSTRAINT CK_Local_Capacite CHECK (LocalCapacite > 0),
    CONSTRAINT FK_Local_Etablissement FOREIGN KEY (EtablissementID) REFERENCES Etablissement(EtablissementID);

-- Competition
ALTER TABLE Competition ADD
    CONSTRAINT PK_Competition PRIMARY KEY (CompetitionID),
    CONSTRAINT FK_Competition_Tournoi FOREIGN KEY (TournoiID) REFERENCES Tournoi(TournoiID),
    CONSTRAINT FK_Competition_Jeu FOREIGN KEY (JeuID) REFERENCES Jeu(JeuID),
    CONSTRAINT FK_Competition_Local FOREIGN KEY (LocalID) REFERENCES [Local](LocalID);

-- Machine
ALTER TABLE Machine ADD
    CONSTRAINT PK_Machine PRIMARY KEY (MachineID),
    CONSTRAINT UQ_Machine_NumeroSerie UNIQUE (MachineNumeroSerie),
    CONSTRAINT CK_Machine_NumeroSerie CHECK (MachineNumeroSerie LIKE 'SP-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
    CONSTRAINT CK_Machine_Memoire CHECK (MachineMemoire > 0);

-- EnregistrementMachine; la cle composee (tournoi, joueur) = une seule machine par joueur et par tournoi
ALTER TABLE EnregistrementMachine ADD
    CONSTRAINT PK_EnregistrementMachine PRIMARY KEY (TournoiID, JoueurID),
    CONSTRAINT FK_EnregistrementMachine_Tournoi FOREIGN KEY (TournoiID) REFERENCES Tournoi(TournoiID),
    CONSTRAINT FK_EnregistrementMachine_Joueur FOREIGN KEY (JoueurID) REFERENCES Joueur(JoueurID),
    CONSTRAINT FK_EnregistrementMachine_Machine FOREIGN KEY (MachineID) REFERENCES Machine(MachineID);

-- Infraction; avertissement, sanction (1 a 5 points) ou bannissement
ALTER TABLE Infraction ADD
    CONSTRAINT PK_Infraction PRIMARY KEY (InfractionID),
    CONSTRAINT DF_Infraction_Date DEFAULT GETDATE() FOR InfractionDate,
    CONSTRAINT DF_Infraction_Points DEFAULT 0 FOR InfractionPoints,
    CONSTRAINT CK_Infraction_Type CHECK (InfractionType IN ('Avertissement', 'Sanction', 'Bannissement')),
    CONSTRAINT CK_Infraction_Points CHECK (
        (InfractionType = 'Sanction' AND InfractionPoints BETWEEN 1 AND 5)
        OR (InfractionType <> 'Sanction' AND InfractionPoints = 0)),
    CONSTRAINT FK_Infraction_Joueur FOREIGN KEY (JoueurID) REFERENCES Joueur(JoueurID),
    CONSTRAINT FK_Infraction_Equipe FOREIGN KEY (EquipeID) REFERENCES Equipe(EquipeID),
    CONSTRAINT FK_Infraction_Competition FOREIGN KEY (CompetitionID) REFERENCES Competition(CompetitionID);

-- Inscription; une inscription est soit solo (JoueurID), soit d'equipe (EquipeID)
ALTER TABLE Inscription ADD
    CONSTRAINT PK_Inscription PRIMARY KEY (InscriptionID),
    CONSTRAINT DF_Inscription_Date DEFAULT GETDATE() FOR InscriptionDate,
    CONSTRAINT CK_Inscription_JoueurOuEquipe CHECK (
        (JoueurID IS NOT NULL AND EquipeID IS NULL)
        OR (JoueurID IS NULL AND EquipeID IS NOT NULL)),
    CONSTRAINT CK_Inscription_Rang CHECK (InscriptionRangFinal > 0),
    CONSTRAINT FK_Inscription_Competition FOREIGN KEY (CompetitionID) REFERENCES Competition(CompetitionID),
    CONSTRAINT FK_Inscription_Joueur FOREIGN KEY (JoueurID) REFERENCES Joueur(JoueurID),
    CONSTRAINT FK_Inscription_Equipe FOREIGN KEY (EquipeID) REFERENCES Equipe(EquipeID);

-- un joueur (ou une equipe) ne s'inscrit qu'une fois a la meme competition
-- (index filtres : un UNIQUE normal accepterait un seul NULL)
CREATE UNIQUE INDEX UQ_Inscription_Competition_Joueur
    ON Inscription(CompetitionID, JoueurID) WHERE JoueurID IS NOT NULL;
CREATE UNIQUE INDEX UQ_Inscription_Competition_Equipe
    ON Inscription(CompetitionID, EquipeID) WHERE EquipeID IS NOT NULL;
GO





/* 4 Vues */

-- V1 : toutes les competitions ayant lieu pendant l'annee courante
CREATE VIEW vCompetitionsAnneeCourante AS
SELECT
    c.CompetitionID,
    c.CompetitionDate,
    t.TournoiNom,
    j.JeuNom,
    l.LocalNom
FROM Competition AS c
INNER JOIN Tournoi AS t ON t.TournoiID = c.TournoiID
INNER JOIN Jeu AS j ON j.JeuID = c.JeuID
INNER JOIN [Local] AS l ON l.LocalID = c.LocalID
WHERE YEAR(c.CompetitionDate) = YEAR(GETDATE());
GO

-- V2 : tous les joueurs qui ne font partie d'aucune equipe
CREATE VIEW vJoueursSansEquipe AS
SELECT
    JoueurID,
    JoueurPseudo,
    JoueurNom,
    JoueurPrenom,
    JoueurCourriel
FROM Joueur
WHERE EquipeID IS NULL;
GO

-- V3 : toutes les equipes qui ne sont inscrites a aucune competition
CREATE VIEW vEquipesNonInscrites AS
SELECT
    e.EquipeID,
    e.EquipeNom
FROM Equipe AS e
WHERE NOT EXISTS
(
    SELECT 1
    FROM Inscription AS i
    WHERE i.EquipeID = e.EquipeID
);
GO

-- V4 : tous les tournois qui comprennent plus de trois competitions
CREATE VIEW vTournoisPlusDe3Competitions AS
SELECT
    t.TournoiID,
    t.TournoiNom,
    COUNT(*) AS NbCompetitions
FROM Tournoi AS t
INNER JOIN Competition AS c ON c.TournoiID = t.TournoiID
GROUP BY t.TournoiID, t.TournoiNom
HAVING COUNT(*) > 3;
GO





/* 5 Fonctions scalaires */
   
-- F1 : nombre de joueurs distincts inscrits a au moins une competition (en solo ou au sein d'une equipe) pendant l'annee recue
CREATE FUNCTION fnNbJoueursInscrits (@Annee INT)
RETURNS INT
AS
BEGIN
    DECLARE @resultat INT;

    SELECT @resultat = COUNT(*)
    FROM
    (
        -- joueurs inscrits en solo
        SELECT i.JoueurID
        FROM Inscription AS i
        INNER JOIN Competition AS c ON c.CompetitionID = i.CompetitionID
        WHERE i.JoueurID IS NOT NULL
          AND YEAR(c.CompetitionDate) = @Annee

        UNION   -- sans ALL : enleve les doublons

        -- joueurs inscrits par leur equipe
        SELECT j.JoueurID
        FROM Inscription AS i
        INNER JOIN Competition AS c ON c.CompetitionID = i.CompetitionID
        INNER JOIN Joueur AS j ON j.EquipeID = i.EquipeID
        WHERE i.EquipeID IS NOT NULL
          AND YEAR(c.CompetitionDate) = @Annee
    ) AS joueurs;

    RETURN @resultat;
END;
GO


-- F2 moyenne du nombre d'inscriptions des competitions solo OU equipe (parametre : solo ou equipe);
CREATE FUNCTION fnMoyenneInscriptionsEquipes (@EnEquipe TINYINT) -- 0: solo; 1: equipe;
RETURNS DECIMAL
AS
BEGIN
    DECLARE @resultat DECIMAL;
        
        SELECT i.InscriptionID
        FROM Inscription AS i
        LEFT JOIN Competition as c ON c.CompetitionID = i.CompetitionID
     

    RETURN @resultat;
END; 


-- F3 nom du tournoi avec le plus d'inscriptions pour une annee (solo + equipes; une equipe = une inscription) ; param annee
CREATE FUNCTION fnTournoiPlusInscriptions (@annee INT)
RETURN VARCHAR
AS
BEGIN
    DECLARE @resultat VARCHAR

    SELECT TOP 1 t.TournoiNom, COUNT(*) as NombreInscription
    FROM Tournoi as t
    INNER JOIN Competition as c ON c.TournoiID = t.TournoiID
    INNER JOIN Inscription as i ON c.CompetitionID = i.CompetitionID
    WHERE YEAR(CompetitionDate) = 2026
    GROUP BY t.TournoiNom

    RETURN @resultat; -- je vais regarder ca plus tard: retourne le resultat de la requete sql
END;





/* 6 Fonctions de table */

-- Les joueurs de l'equipe dont le nom est recu
CREATE FUNCTION fnMembresEquipe (@EquipeNom VARCHAR(100))
RETURNS TABLE
AS
RETURN
(
    SELECT j.JoueurPseudo, j.JoueurNom, j.JoueurPrenom, j.JoueurCourriel, e.EquipeNom from Joueur as j
    INNER JOIN Equipe as e ON j.EquipeID = e.EquipeID
    where e.EquipeNom = @EquipeNom
);


-- pour UN tournoi avec son id en parametre trouver nombre d'insriptions (null/0 inclus)
CREATE FUNCTION fnInscriptionsParTournoi (@TournoiID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT t.TournoiID, COUNT(*) as NombreInscriptions
    FROM Tournoi as t
    INNER JOIN Competition as c ON c.TournoiID = t.TournoiID
    INNER JOIN Inscription as i ON c.CompetitionID = i.CompetitionID
    where t.TournoiID = @TournoiID
    Group by t.TournoiID
);





/* 7 Declencheurs */

-- Lorsqu'un joueur est supprime, il est d'abord retire de toutes les equipes dont il fait partie.
CREATE TRIGGER trSupprimerJoueur
ON Joueur
AFTER DELETE
AS
BEGIN
    DELETE FROM Equipe as e
    WHERE e.
end;





-- Lorsque la date d'une competition est modifiee, toutes ses inscriptions (solo et equipes) sont retirees. Sauf si date = pareil.
CREATE TRIGGER trModifierDateCompetition
ON Competition
AFTER UPDATE
AS
BEGIN
   
    SELECT @AncienneDate = DateCompetition FROM deleted;
    SELECT @NouvelleDate = DateCompetition FROM inserted;
    SELECT @CompID = CompetitionID FROM inserted;


    IF @AncienneDate <> @NouvelleDate
    BEGIN
        DELETE
        FROM Inscription as i
        WHERE i.CompetitionID = @CompID
    END;
END;





-- Lorsqu'une inscription solo est  ajoutee,
CREATE TRIGGER trStatsInscriptions
