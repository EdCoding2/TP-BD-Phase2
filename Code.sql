-- Eduola
-- Date de remise: 2 décembre.



/* 1 Creation de la base de donnees */

CREATE DATABASE [Starplayers]
ON PRIMARY
(
    NAME = N'Starplayers',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\Starplayers.mdf',
    SIZE = 8192KB,
    MAXSIZE = 512MB,
    FILEGROWTH = 8192KB
)
LOG ON
(
    NAME = N'Starplayers_log',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\Starplayers_log.ldf',
    SIZE = 8192KB,
    MAXSIZE = 256MB,
    FILEGROWTH = 8192KB
);
GO



/* 2 Creation des tables (et contraintes) */

/* 1. PAYS*/

CREATE TABLE Pays
(
    PaysID INT IDENTITY(1,1),
    PaysNom VARCHAR(100) NOT NULL,
    PaysCodeIso VARCHAR(100) NOT NULL
);
GO


/*2. ENTRAINEUR */

CREATE TABLE Entraineur
(
    EntraineurID INT IDENTITY(1,1),
    EntraineurNom VARCHAR(100) NOT NULL,
    EntraineurPrenom VARCHAR(100) NOT NULL
);
GO


/*3. ORGANISATEUR */

CREATE TABLE Organisateur
(
    OrganisateurID INT IDENTITY(1,1),
    OrganisateurNom VARCHAR(100) NOT NULL,
    OrganisateurPrenom VARCHAR(100) NOT NULL,
    OrganisateurCourriel VARCHAR(255) NOT NULL UNIQUE,
    OrganisateurTelephone VARCHAR(13)
);
GO


/*4. TYPE ETABLISSEMENT*/

CREATE TABLE TypeEtablissement
(
    TypeEtablissementID INT IDENTITY(1,1),
    TypeEtablissementNom VARCHAR(100) NOT NULL
);
GO


/* 5. TYPE JEU */

CREATE TABLE TypeJeu
(
    TypeJeuID INT IDENTITY(1,1),
    TypeJeuNom VARCHAR(100) NOT NULL
);
GO


/*6. COMPAGNIE */

CREATE TABLE Compagnie
(
    CompagnieID INT IDENTITY(1,1),
    CompagnieNom VARCHAR(100) NOT NULL
    -- id pays
);
GO


/*7. JOUEUR */

CREATE TABLE Joueur
(
    JoueurID INT IDENTITY(1,1),
    JoueurPseudo VARCHAR(100) NOT NULL,
    JoueurNom VARCHAR(100) NOT NULL,
    JoueurPrenom VARCHAR(20) NOT NULL,
    JoueurDateNaissance DATE NOT NULL,
    JoueurCourriel VARCHAR(255) NOT NULL UNIQUE
    -- pays id: int, fk
    -- equipe id: int, fk
);
GO


/* 8. EQUIPE */

CREATE TABLE Equipe
(
    EquipeID INT IDENTITY(1,1),
    EquipeNom VARCHAR(100) NOT NULL
    -- chef: int, fk
    -- entraineur: int, fk
    -- sponsor: int, fk
);
GO


/* 9. ETABLISSEMENT */

CREATE TABLE Etablissement
(
    EtablissementID INT IDENTITY(1,1),
    EtablissementNom VARCHAR(100) NOT NULL,
    EtablissementAdresse VARCHAR(100) NOT NULL,
    EtablissementVille VARCHAR(255) NOT NULL UNIQUE
    -- pays: int, fk
    -- type detablissement: int, fk
);
GO


/*10. TOURNOI*/

CREATE TABLE Tournoi
(
    TournoiID INT IDENTITY(1,1),
    TournoiNom VARCHAR(100) NOT NULL,
    TournoiDateDebut DATE NOT NULL,
    TournoiDateFin DATE NOT NULL
    -- id etablissement
    -- id organisateur
);
GO


/*11. JEU */

CREATE TABLE Jeu
(
    JeuID INT IDENTITY(1,1),
    JeuNom VARCHAR(100) NOT NULL,
    JeuAnneParution INT NOT NULL, -- check pas dans le futur
    EstEnEquipe TINYINT NOT NULL
    -- id type jeu
    -- id studio
    -- id editeur
    -- id fournisseur
);
GO


/* 12. COMPETITION */

CREATE TABLE Competition
(
    CompetitionID INT IDENTITY(1,1),
    CompetitionDate DATE NOT NULL
    -- id tournoi
    -- id jeu
    -- id local
);
GO


/* 13. LOCAL */

CREATE TABLE [Local]
(
    LocalID INT IDENTITY(1,1),
    LocalNom VARCHAR(50) NOT NULL,
    LocalCapacite INT
    -- id etablissement
);
GO


/*14. MACHINE */

CREATE TABLE Machine
(
    MachineID INT IDENTITY(1,1),
    MachineNumeroSerie VARCHAR(15) NOT NULL, -- SP-0000-0000
    MachineProcesseur VARCHAR(35) NOT NULL,
    MachineGraphique VARCHAR(35) NOT NULL,
    MachineMemoire INT NOT NULL,
    MachineSystemeExploitation VARCHAR(25) NOT NULL
);
GO


/* 15. ENREGISTREMENT MACHINE */

CREATE TABLE EnregistrementMachine
(
    TournoiID INT NOT NULL, -- id tournoi cp, fk
    JoueurID INT NOT NULL,  -- id joueur cp, fk
    MachineID INT NOT NULL -- id machine fk
);
GO


/*16. INFRACTION */

CREATE TABLE Infraction
(
    InfractionID INT IDENTITY(1,1),
    InfractionDate DATE NOT NULL,
    InfractionDescription VARCHAR(200) NOT NULL,
    InfractionType VARCHAR(20) NOT NULL,
    InfractionPoints INT NOT NULL
    -- id joueur
    -- id equipe
    -- id competition
);
GO


/* 17. INSCRIPTION */

CREATE TABLE Inscription
(
    InscriptionID INT IDENTITY(1,1),
    InscriptionRangFinal INT NOT NULL,
    InscriptionDATE DATE NOT NULL
    -- id competition
    -- id joueur null si id equipe
    -- id equipe null si id joueur
);
GO

/* 3 Ajout des relations (cles etrangeres + clées primaires) */
/*JOUEUR */

ALTER TABLE Joueur
    ADD CONSTRAINT PK_Joueur
    PRIMARY KEY (JoueurID);

ALTER TABLE Joueur
    ADD JoueurPays INT NOT NULL,
        CONSTRAINT FK_JoueurPays_PaysID
        FOREIGN KEY (JoueurPays) REFERENCES Pays(PaysID),

        JEquipeID INT,
        CONSTRAINT FK_JEquipeID_EquipeID
        FOREIGN KEY (JEquipeID) REFERENCES Equipe(EquipeID);


/*PAYS */

ALTER TABLE Pays
    ADD CONSTRAINT PK_PaysID
    PRIMARY KEY (PaysID);


/* EQUIPE */

ALTER TABLE Equipe
    ADD CONSTRAINT PK_EquipeID
    PRIMARY KEY (EquipeID);

ALTER TABLE Equipe
    ADD ChefID INT NOT NULL,
        EntraineurID INT NOT NULL,
        SponsorID INT NOT NULL,

        CONSTRAINT FK_ChefID_JoueurID
        FOREIGN KEY (ChefID) REFERENCES Joueur(JoueurID),

        CONSTRAINT FK_EntraineurID_EntraineurID
        FOREIGN KEY (EntraineurID) REFERENCES Entraineur(EntraineurID),

        CONSTRAINT FK_SponsorID_CompagnieID
        FOREIGN KEY (SponsorID) REFERENCES Compagnie(CompagnieID);


/* ENTRAINEUR */

ALTER TABLE Entraineur
    ADD CONSTRAINT PK_EntraineurID
    PRIMARY KEY (EntraineurID);


/* ORGANISATEUR */

ALTER TABLE Organisateur
    ADD CONSTRAINT PK_OrganisateurID
    PRIMARY KEY (OrganisateurID);


/* ETABLISSEMENT */

ALTER TABLE Etablissement
    ADD CONSTRAINT PK_EtablissementID
    PRIMARY KEY (EtablissementID);

ALTER TABLE Etablissement
    ADD PaysID INT NOT NULL,
        TypeEtablissementID INT NOT NULL,

        CONSTRAINT FK_PaysID_PaysID
        FOREIGN KEY (PaysID) REFERENCES Pays(PaysID),

        CONSTRAINT FK_TypeEtablissementID_TypeEtablissementID
        FOREIGN KEY (TypeEtablissementID)
        REFERENCES TypeEtablissement(TypeEtablissementID);


/*TYPE ETABLISSEMENT */

ALTER TABLE TypeEtablissement
    ADD CONSTRAINT PK_TypeEtablissementID
    PRIMARY KEY (TypeEtablissementID);


/* TOURNOI */

ALTER TABLE Tournoi
    ADD CONSTRAINT PK_TournoiID
    PRIMARY KEY (TournoiID);

ALTER TABLE Tournoi
    ADD EtablissementID INT NOT NULL,
        OrganisateurID INT NOT NULL,

        CONSTRAINT FK_EtablissementID_EtablissementID
        FOREIGN KEY (EtablissementID)
        REFERENCES Etablissement(EtablissementID),

        CONSTRAINT FK_OrganisateurID_OrganisateurID
        FOREIGN KEY (OrganisateurID)
        REFERENCES Organisateur(OrganisateurID);


/* JEU */

ALTER TABLE Jeu
    ADD CONSTRAINT PK_JeuID
    PRIMARY KEY (JeuID);

ALTER TABLE Jeu
    ADD TypeJeuID INT NOT NULL,
        StudioId INT NOT NULL,
        EditeurID INT NOT NULL,
        FournisseurID INT,

        CONSTRAINT FK_TypeJeuID_TypeJeuID
        FOREIGN KEY (TypeJeuID) REFERENCES TypeJeu(TypeJeuID),

        CONSTRAINT FK_StudioId_CompagnieID
        FOREIGN KEY (StudioId) REFERENCES Compagnie(CompagnieID),

        CONSTRAINT FK_EditeurID_CompagnieID
        FOREIGN KEY (EditeurID) REFERENCES Compagnie(CompagnieID),

        CONSTRAINT FK_FournisseurID_CompagnieID
        FOREIGN KEY (FournisseurID) REFERENCES Compagnie(CompagnieID);


/* TYPE JEU */

ALTER TABLE TypeJeu
    ADD CONSTRAINT PK_TypeJeuID
    PRIMARY KEY (TypeJeuID);


/* COMPAGNIE */

ALTER TABLE Compagnie
    ADD CONSTRAINT PK_CompagnieID
    PRIMARY KEY (CompagnieID);

ALTER TABLE Compagnie
    ADD PaysID INT NOT NULL,

        CONSTRAINT FK_PaysID_PaysID
        FOREIGN KEY (PaysID) REFERENCES Pays(PaysID);


/* COMPETITION */

ALTER TABLE Competition
    ADD CONSTRAINT PK_CompetitionID
    PRIMARY KEY (CompetitionID);

ALTER TABLE Competition
    ADD TournoiID INT NOT NULL,
        JeuID INT NOT NULL,
        LocalID INT NOT NULL,

        CONSTRAINT FK_TournoiID_TournoiID
        FOREIGN KEY (TournoiID) REFERENCES Tournoi(TournoiID),

        CONSTRAINT FK_JeuID_JeuID
        FOREIGN KEY (JeuID) REFERENCES Jeu(JeuID),

        CONSTRAINT FK_LocalID_LocalID
        FOREIGN KEY (LocalID) REFERENCES [Local](LocalID);


/* LOCAL */

ALTER TABLE [Local]
    ADD CONSTRAINT PK_LocalID
    PRIMARY KEY (LocalID);

ALTER TABLE [Local]
    ADD EtablissementID INT NOT NULL,

        CONSTRAINT FK_EtablissementID_EtablissementID
        FOREIGN KEY (EtablissementID)
        REFERENCES Etablissement(EtablissementID);


/* MACHINE */

ALTER TABLE Machine
    ADD CONSTRAINT PK_MachineID
    PRIMARY KEY (MachineID);


/*ENREGISTREMENT MACHINE */

ALTER TABLE EnregistrementMachine
    ADD EnregistrementMachineID INT IDENTIFY(1,1) NOT NULL,
        CONSTRAINT PK_EnregistrementMachine PRIMARY KEY (EnregistrementMachine);

ALTER TABLE EnregistrementMachine
    ADD TournoiID INT NOT NULL,
        JoueurID INT NOT NULL,
        MachineID INT NOT NULL,

        CONSTRAINT FK_TournoiID_TournoiID
        FOREIGN KEY (TournoiID) REFERENCES Tournoi(TournoiID),

        CONSTRAINT FK_JoueurID
        FOREIGN KEY (JoueurID) REFERENCES Joueur(JoueurID),

        CONSTRAINT FK_MachineID
        FOREIGN KEY (MachineID) REFERENCES Machine(MachineID);


/*INFRACTION */

ALTER TABLE Infraction
    ADD CONSTRAINT PK_InfractionID
    PRIMARY KEY (InfractionID);

ALTER TABLE Infraction
    ADD JoueurID INT NOT NULL,
        EquipeID INT NOT NULL,
        CompetitionID INT NOT NULL,

        CONSTRAINT FK_JoueurID_JoueurID
        FOREIGN KEY (JoueurID) REFERENCES Joueur(JoueurID),

        CONSTRAINT FK_EquipeID_EquipeID
        FOREIGN KEY (EquipeID) REFERENCES Equipe(EquipeID),

        CONSTRAINT FK_CompetitionID_CompetitionID
        FOREIGN KEY (CompetitionID) REFERENCES Competition(CompetitionID);


/* INSCRIPTION */

ALTER TABLE Inscription
    ADD CONSTRAINT PK_InscriptionID
    PRIMARY KEY (InscriptionID);

ALTER TABLE Inscription
    ADD CompetitionID INT NOT NULL,
        JoueurID INT,
        EquipeID INT,

        CONSTRAINT FK_CompetitionID_CompetitionID
        FOREIGN KEY (CompetitionID) REFERENCES Competition(CompetitionID),

        CONSTRAINT FK_JoueurID_JoueurID
        FOREIGN KEY (JoueurID) REFERENCES Joueur(JoueurID),

        CONSTRAINT FK_EquipeID_EquipeID
        FOREIGN KEY (EquipeID) REFERENCES Equipe(EquipeID);

/* 4 Vues */

/* 5 Fonctions scalaires Exigences techniques */

/* 6 Fonctions de table */

/* 7 Declencheurs */

/* 8 Procedures stockees */

/* 9 elements de securite */

/* 10 Saisie de donnees et tests */
