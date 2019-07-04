---
title: "Database conventions"
description: "These are INBO database conventions. This page is intended for those who design (ms-SQL Server)databases for their project."
author: "Gert Van Spaendonk, Jo Loos, Frederic Piesschaert"
date: 2019-07-04
categories: ["styleguide databases"]
tags: ["database", "styleguide"]
---

# General
  * All SQL objects are prefixed, except for databases, schemas, tables and columns and users/logins.
  * The prefixes used depend on the type of object:

| Prefix | Object type |
| --- | ---------------------- |
| PK_	| primary key constraint |
| FK_ |	foreign key constraint |
| CU_ |	unique key constraint  |
| CC_ |	check constraint       |
| CD_ |	default                |
| IN_ |	index                  |
| VW_ |	view                   |
| TR_ |	trigger                |
| SQ_ |	sequence               |
| DR_ |	database role          |

  * (connection strings application name in connectstring, ...)
  * (English of Nederlands)

# Database
  * The database is created by the DBA.
  * Database name is provided by the DBA.
  * For a list of DB's following the new name conventions, see List of databases.

# Schemas
* The database is created by the DBA.dbo only.
* The database is created by the DBA.unless special requirements.

# Tables
  * Meaningful name .
  * CamelCase.
  * Singular
  * No pre- or suffixes.
  * [ a-b ], [ A-B ], [ 0-9 ].

# Columns
  * Meaningful name.
  * CamelCase.
  * No pre- or suffixes.
  * [ a-z ], [ A-Z ], [ 0-9 ] and [ -,\_ ] if necessary.
  * specify the kind of column at the end of the name in case of potential doubt, e.g. CreateUser, UpdateDate, BiotopeKey, TaxonCode, SpeciesID.
  * do not repeat the table name in the column name; a column only exists in the context of the table.
  * primary key column
    * always 1 per table,
    * non functional,
    * datatype: int or bigint, not null, identity (autonumber),
    * name: ID
  * foreign key column
    * name: table name + primary key column (ID) of column to which the foreign key refers, e.g. Measurement.SpeciesID refers to Species.ID
    * clearify in case of multiple relations between 2 tables, e.g. Observation.ObserverPersonID and Observation.ValidatorPersonID both refer to Person.ID
  * minimum columns in each table (see Code Snippets):
    * ID
    * CreateUser
    * CreateDate
    * UpdateUser
    * UpdateDate
    * RV

# Primary key constraints
  * always.
  * single column, non-composite.
  * non functional.
  * naming: PK\_\<table name\>, e.g.:
    * PK\_Species for Species table,
    * PK\_Measurement for Measurement table

# Foreign key constraints
  * use db referential integrity when necessary and when possible, do not rely on application logic solely.
  * single column, non composite.
  * naming: FK\_\<referring table name\>\_\<referred table name\>(\_\<discriminator\>), e.g.:
    * FK\_Measurement_Species for foreign key from Measurement table to Species table,
    * FK\_Observation_Person_Observer and FK\_Observation\_Person\_Validator for foreign keys from Observation table to Person table ,
  * good practice to add an index on foreign key columns; this is not autmatically done; use the index naming logic: IN\_\<table name\>\_\<specification\>

# Unique key constraints
  * always use constraints instead of indexes to enforce uniqueness.
  * can be composite.
  * naming: CU\_\<table name\>\_\<functional description\>, e.g.:
    * CU\_ObservationPerson\_ObservationPerson for unique constraint on ObservationID and PersonID columns in ObservationPerson table,
    * CU\_SampleOnvolledigReden\_SampleOnvolledigReden for unique constraint on SampleID and OnvolledigRedenID columns in SampleOnvolledigReden table.

# Check constraints
  * not often used, it might be better to have this kind of logic in the business layer.
  * naming CC\_\<table name\>\_\<functional description\>, e.g.:
    * CC_Measurement_PositiveNumber for check constraint that validates the Number column in Measurement table being positive.

# Defaults
  * always provide a default value for bit-columns.
  * always provide a default value for standard columns CreateDate an CreateUser, resp GETDATE() and SUSER_NAME().
  * naming: CD\_\<table name\>\_\<column name\>, e.g.
    * CD_Measurement_CreateDate for default value on CreateDate column in Measurement table.
  * This code example adds defaults for columns CreateUser and CreateDate of table Method:

``` 
 ALTER TABLE Method ADD
     CONSTRAINT CD_Method_CreateUser  DEFAULT (SUSER_NAME()) FOR CreateUser       
   , CONSTRAINT CD_Method_CreateDate  DEFAULT (GETDATE()) FOR CreateDate
```

# Triggers 
  * only used for low level database logic.
  * naming: TR\_\<table name\>\_\<trigger action\>, where trigger action can be AU (after update), AI (after insert), AD (after delete) or any combination (A(U)(I)(D)) or IO (instead of), e.g.
    * TR_Measurement_AU for after update trigger on Measurement table .
  * This code example creates an after update trigger for table Measurement. Columns UpdateDate and UpdateUser are updated on each update:

```
CREATE TRIGGER [dbo].[TR_Measurement_AU]
 ON [dbo].[Measurement]
 AFTER UPDATE
 AS
 BEGIN
  SET NOCOUNT ON;
  UPDATE t
  SET t.UpdateDate = GETDATE()
    , t.UpdateUser = SUSER_SNAME()
  FROM inserted i
  INNER JOIN Measurement t
    ON t.ID = i.ID;
 END
```

# Indexes
  * Indexes are used to speed up lookups and sorting.
  * Do not use indexes to enforce uniqueness; use unique key constraint instead, which creates an index itself. Exception to this: when uniqueness is required in combination with a filtering criterium.
  * As a rule of thumb create an index on each foreign key column.
  * As a rule of thumb make sure that the primary key constraint uses a clustered index.
  * Clustered indexes are created on DATA filegroup; non-clustered indexes on INDEXES filegroup.
  * Leave the rest of the indexing up to the DBA. In order to help the DBA in choosing the correct indexes, explain him the (search and sorting) behaviour of the application.
  * Performance issues might require the creation (or deletion) of indexes during the lifetime of the db. Indexes do not contribute to the versioning of the database.
  * Naming: IN\_\<table name\>\_\<specification\> where specification describes function of index or columns included
   * IN\_Measurement\_MeasurementStatusID for an index on the MeasurementStatusID column of the Measurement table.
  * This example creates an index on the SpeciesID column of the Measurement table. Non-clustered indexes are always created on the INDEXES filegroup:

```
CREATE NONCLUSTERED INDEX IN_Measurement_SpeciesID ON Measurement(SpeciesID) ON INDEXES;
```

  * Example on how to enforce the primary key using a clustered index. Clustered indexes ares always created on the DATA filegroup:

```
ALTER TABLE Measurement ADD     
   CONSTRAINT PK_Measurement PRIMARY KEY CLUSTERED (ID) ON DATA;
```

# Views
  * Stored queries.
  * Views can be updatable.
  * For creation of indexed views (e.g. on calculated columns)  consult the DBA.
  * Don't use ORDER BY in views.
  * Naming: VW\_\<logical name\>, e.g.
    * VW\_ActiveMesearumentStatus, retrieves the currently active measurement statusses 

# Synonyms
  * Do not use synonyms; they get the databases intertwined.

# Stored procedures
  * no guidelines yet
  
# Functions
  * no guidelines yet
  
# Sequences
  * Use IDENTITY column instead of sequence to get an auto-increment behaviour at the table level.
  * Use sequence to get an auto-increment behaviour across multiple tables (rare).
  * Naming: SQ\_\<logical name\>

# Security
  * DBA's task to implement security.
  * Good to know how it's normally implemented.
  * Permissions are granted to database roles and users are assigned to database roles; the user gets the permissions of the database role to which it is assigned.
  * Permissions are never granted to users
  * When possible a user should be assigned to 1 database role only

# Database Roles
  * following custom database roles per database:
    * DR\_Admin: has dba permissions on the database; dba can be implement this using following steps
      * grant create permissions for all objects the dba wants to allow to be created (at database level), eg create table
      * + grant alter any schema (at database level)
    * DR\_\<schema\>\_Admin: has dba permissions on the schema <schema> of the database; dba can be implement this using following steps
      * grant create permissions for all objects the dba wants to allow to be created (at database level), eg create table
    * + grant alter (at \<schema\> level)
    * DR\_Reader: has readonly (R) permissions on all tables and views
    * DR\_App\<Application name\>: has application specific permissions: developer determines which permissions should be applied on the individual tables
    * DR\_Rpt\<Reporting name\>
  * When required extra database roles can be provided

# Users / Logins
  * The terms login (server level) and user (database level) are separate concepts in SQL Server; it's the login that's used in connection string; the login is mapped to a user at the database level; we map both 1 to 1 and refer to it as user.
  * Each component of an application that interacts with the database needs its own, unique user:
    * unique at INBO level
    * dedicated user : tracebility
    * when an application uses multiple services, which interact with the db, each service should have its own user.
    * when an application connects in different ways to the db (e.g. transactional vs reporting) each functional component should have its own user.
    * the (application)user is assigned to the DR_App<Application name> role.
  * Naming: \<Application context\>\_\<BusinessRole\>, where
    * \<application context\>: a unique and clear reference to the application that's adressing the database; for INBO-applications this might be the accepted name for the application (e.g. watinawsbusiness, the business service of Watina); for ACD-applications this might be the Nexus group ID (e.g be.inbo.wstaxon, the wstaxon service).
    * \<BusinessRole\>: reporter, user, admin
  * [ developer  is dba on dev db server ]
  * [ inbo\users is readonly ]
  * [ pwd zelfde op dev en zelfde op qas ]

# Documentation
  * Database self explanatory through use of extended properties on
    * database: properties Code, Name, Description and Version
    * tables: property Description
    * columns: property Description
  * Meta about database model and deployed instances in wiki: List of databases

# Code snippets
  * Minimum required for normal table...
 ```
 /* create table */
CREATE TABLE Measurement
(
     ID int IDENTITY(1,1) NOT NULL
   /* ... table specific columns
   , MeasurementStatusID int NOT NULL
   , SpeciesID int NOT NULL
   ...*/
   , CreateUser nvarchar(150) NOT NULL
   , CreateDate datetime2(7) NOT NULL
   , UpdateUser nvarchar(150) NULL
   , UpdateDate datetime2(7) NULL
   , RV timestamp NOT NULL);
 GO
/* add primary key constraint */
ALTER TABLE Measurement ADD
     CONSTRAINT PK_Measurement PRIMARY KEY CLUSTERED (ID) ON DATA;
GO
/* add defaults */
ALTER TABLE Measurement ADD 
     CONSTRAINT CD_Measurement_CreateUser  DEFAULT (SUSER_NAME()) FOR CreateUser
   , CONSTRAINT CD_Measurement_CreateDate  DEFAULT (GETDATE()) FOR CreateDate;
GO
/* add foreign key constraints */
/* eg
ALTER TABLE Measurement ADD 
     CONSTRAINT FK_Measurement_MeasurementStatus FOREIGN KEY(MeasurementStatusID) REFERENCES MeasurementStatus (ID)
   , CONSTRAINT FK_Measurement_Species FOREIGN KEY(SpeciesID) REFERENCES Species (ID);
GO
*/
/* add indexes */
/* eg on foreign key columns */
/*
CREATE NONCLUSTERED INDEX IN_Measurement_MeasurementStatusID ON Measurement(MeasurementStatusID) ON INDEXES;
CREATE NONCLUSTERED INDEX IN_Measurement_SpeciesID ON Measurement(SpeciesID) ON INDEXES;
GO
*/
/* add trigger that updates audit columns */
CREATE TRIGGER TR_Measurement_AU
   ON Measurement
   AFTER UPDATE
   AS
    BEGIN
     SET NOCOUNT ON;
     UPDATE t
     SET   t.UpdateDate = GETDATE()
         , t.UpdateUser = SUSER_SNAME()
     FROM Measurement t
     INNER JOIN inserted i ON i.ID = t.ID;
    END
;
GO
/* add data dictionary */
/* (you can leave this up to the dba if you have a properly formatted list of table and column names with their description */
EXEC sys.sp_addextendedproperty
     @name=N'Description', @value=N'The measurements of ....lorem ipsum dolor.'
   , @level0type=N'SCHEMA',@level0name=N'dbo'
   , @level1type=N'TABLE',@level1name=N'Measurement';
 
GO
EXEC sys.sp_addextendedproperty
     @name=N'Description', @value=N'Measurement ID.'
   , @level0type=N'SCHEMA',@level0name=N'dbo'
   , @level1type=N'TABLE',@level1name=N'Measurement'
   , @level2type=N'COLUMN',@level2name=N'ID';
GO
EXEC sys.sp_addextendedproperty
     @name=N'Description', @value=N'Creation user.'
   , @level0type=N'SCHEMA',@level0name=N'dbo'
   , @level1type=N'TABLE',@level1name=N'Measurement'
   , @level2type=N'COLUMN',@level2name=N'CreateUser';
GO
EXEC sys.sp_addextendedproperty
     @name=N'Description', @value=N'Creation date.'
   , @level0type=N'SCHEMA',@level0name=N'dbo'
   , @level1type=N'TABLE',@level1name=N'Measurement'
   , @level2type=N'COLUMN',@level2name=N'CreateDate';
GO
EXEC sys.sp_addextendedproperty
     @name=N'Description', @value=N'Last update user.'
   , @level0type=N'SCHEMA',@level0name=N'dbo'
   , @level1type=N'TABLE',@level1name=N'Measurement'
   , @level2type=N'COLUMN',@level2name=N'UpdateUser';
GO
EXEC sys.sp_addextendedproperty
     @name=N'Description', @value=N'Last update date.'
   , @level0type=N'SCHEMA',@level0name=N'dbo'
   , @level1type=N'TABLE',@level1name=N'Measurement'
   , @level2type=N'COLUMN',@level2name=N'UpdateDate';
GO
EXEC sys.sp_addextendedproperty
     @name=N'Description', @value=N'Row version.'
   , @level0type=N'SCHEMA',@level0name=N'dbo'
   , @level1type=N'TABLE',@level1name=N'Measurement'
   , @level2type=N'COLUMN',@level2name=N'RV';
GO
```

  * Minimum required for code tables, controlled vocabularies, ...
 
 ```
 /* create table */
CREATE  TABLE Method
(
     ID int IDENTITY(1,1) NOT NULL
   , Code nvarchar(10) NOT NULL
   , [Description] nvarchar(200) NOT NULL
   , SortOrder int NOT NULL
   , ValidFromDate datetime2(7) NOT NULL
   , ValidTillDate datetime2(7) NULL
   , CreateUser nvarchar(50) NULL
   , CreateDate datetime2(7) NOT NULL
   , UpdateUser nvarchar(50) NULL
   , UpdateDate datetime2(7) NULL
   , RV timestamp NOT NULL
);
GO
/* add primary key constraint */
ALTER TABLE Method ADD
     CONSTRAINT PK_Method PRIMARY KEY CLUSTERED (ID) ON DATA;
GO
/* add defaults */
ALTER TABLE Method ADD 
     CONSTRAINT CD_Method_SortOrder  DEFAULT (0) FOR SortOrder
   , CONSTRAINT CD_Method_CreateUser  DEFAULT (SUSER_NAME()) FOR CreateUser       
   , CONSTRAINT CD_Method_CreateDate  DEFAULT (GETDATE()) FOR CreateDate
   , CONSTRAINT CD_Method_ValidFromDate  DEFAULT (GETDATE()) FOR ValidFromDate;
GO
/* add unique keys */
ALTER TABLE Method ADD
     CONSTRAINT CU_Method_CodeValidFromDate UNIQUE NONCLUSTERED (Code, ValidFromDate) ON INDEXES
   , CONSTRAINT CU_Method_CodeValidTillDate UNIQUE NONCLUSTERED (Code, ValidTillDate ) ON INDEXES;
GO
/* add check constraint */
ALTER TABLE Method  ADD
     CONSTRAINT CC_Method_ValidFromLessThenValidTillDate CHECK  (ValidFromDate < ValidTillDate OR ValidTillDate IS NULL);
GO
/* add trigger that updates audit columns */
CREATE TRIGGER [TR_Method_AU]
   ON [Method]
   AFTER UPDATE
   AS
    BEGIN
 
     SET NOCOUNT ON;
     UPDATE t
     SET   t.UpdateDate = GETDATE()
         , t.UpdateUser = SUSER_SNAME()
     FROM Method t
     INNER JOIN inserted i ON i.ID = t.ID;
    END;
GO
 
/* add data dictionary */
/* (you can leave this up to the dba if you have a properly formatted list of table and column names with their description */
EXEC sys.sp_addextendedproperty
     @name=N'Description', @value=N'The observation methods.'    
   , @level0type=N'SCHEMA',@level0name=N'dbo'   
   , @level1type=N'TABLE',@level1name=N'Method';
GO
EXEC sys.sp_addextendedproperty
     @name=N'Description', @value=N'Method ID.'
   , @level0type=N'SCHEMA',@level0name=N'dbo'
   , @level1type=N'TABLE',@level1name=N'Method'
   , @level2type=N'COLUMN',@level2name=N'ID';
GO
EXEC sys.sp_addextendedproperty
     @name=N'Description', @value=N'Method code. This codes must be unique at a certain point of time.'
   , @level0type=N'SCHEMA',@level0name=N'dbo'
   , @level1type=N'TABLE',@level1name=N'Method'
   , @level2type=N'COLUMN',@level2name=N'Code';
GO
EXEC sys.sp_addextendedproperty
     @name=N'Description', @value=N'Method description.'
   , @level0type=N'SCHEMA',@level0name=N'dbo'
   , @level1type=N'TABLE',@level1name=N'Method'
   , @level2type=N'COLUMN',@level2name=N'Description';
GO
EXEC sys.sp_addextendedproperty
     @name=N'Description', @value=N'The index of the item when the list is sorted, eg in dropdownboxes.'
   , @level0type=N'SCHEMA',@level0name=N'dbo'
   , @level1type=N'TABLE',@level1name=N'Method'
   , @level2type=N'COLUMN',@level2name=N'SortOrder';
GO
EXEC sys.sp_addextendedproperty
     @name=N'Description', @value=N'Date from which this method is valid.'
   , @level0type=N'SCHEMA',@level0name=N'dbo'
   , @level1type=N'TABLE',@level1name=N'Method'
   , @level2type=N'COLUMN',@level2name=N'ValidFromDate';
GO
EXEC sys.sp_addextendedproperty
     @name=N'Description', @value=N'Date untill which this method is valid. If this column is empty, the method is currently valid.'
   , @level0type=N'SCHEMA',@level0name=N'dbo'
   , @level1type=N'TABLE',@level1name=N'Method'
   , @level2type=N'COLUMN',@level2name=N'ValidTillDate';
GO
EXEC sys.sp_addextendedproperty
     @name=N'Description', @value=N'Creation user.'
   , @level0type=N'SCHEMA',@level0name=N'dbo'
   , @level1type=N'TABLE',@level1name=N'Method'
   , @level2type=N'COLUMN',@level2name=N'CreateUser';
GO
EXEC sys.sp_addextendedproperty
     @name=N'Description', @value=N'Creation date.'
   , @level0type=N'SCHEMA',@level0name=N'dbo'
   , @level1type=N'TABLE',@level1name=N'Method'
   , @level2type=N'COLUMN',@level2name=N'CreateDate';
GO
EXEC sys.sp_addextendedproperty
     @name=N'Description', @value=N'Last update user.'
   , @level0type=N'SCHEMA',@level0name=N'dbo'
   , @level1type=N'TABLE',@level1name=N'Method'
   , @level2type=N'COLUMN',@level2name=N'UpdateUser';
GO
EXEC sys.sp_addextendedproperty
     @name=N'Description', @value=N'Last update date.'
   , @level0type=N'SCHEMA',@level0name=N'dbo'
   , @level1type=N'TABLE',@level1name=N'Method'
   , @level2type=N'COLUMN',@level2name=N'UpdateDate';
GO
EXEC sys.sp_addextendedproperty
     @name=N'Description', @value=N'Row version.'
   , @level0type=N'SCHEMA',@level0name=N'dbo'
   , @level1type=N'TABLE',@level1name=N'Method'
   , @level2type=N'COLUMN',@level2name=N'RV';
 ```
