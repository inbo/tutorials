---
title: "Styleguide SQL-scripts"
description: "Layout guidelines for writing clear SQL-scripts"
authors: [fredericpiesschaert, gertvanspaendonk, joloos, aaikedewever]
date: 2020-06-23
categories: ["styleguide"]
tags: ["styleguide", "SQL"]
---


SQL is a standard language for storing, manipulating and retrieving data in databases. This is not a SQL-course but a styleguide, describing how to enhance the readability of your SQL-scripts. Focus of the styleguide is on scripts for retrieving data.

# In short

```
    --This is how a basic SQL-script should look like
    
    /**
    Description: Lijst met broedvogels per UTM1-hok sinds 2010
    Created: 2015-08-12
    Created by: Frederic Piesschaert
    **/

    SELECT w.WRNG_JAR AS jaar
      , w.WRNG_UTM1_CDE AS utm1
      , s.SPEC_NAM_WET AS wetenschappelijke_naam
      , s.SPEC_NAM_NED AS nederlandse_naam
      , t.TOPO_DES AS locatie
    FROM tblWaarneming w
      INNER JOIN tblWaarnemingMeting wm ON w.WRNG_ID = wm.WRME_WRNG_ID
      INNER JOIN tblSoort s ON wm.WRME_SPEC_CDE = s.SPEC_CDE
      LEFT JOIN tblToponiem t on t.TOPO_ID = w.WRNG_TOPO_ID --toponiemen werden niet altijd ingevuld
    WHERE 1 = 1
      AND w.WRNG_UTM1_CDE IS NOT NULL
      AND w.WRNG_JAR > 2010
    GROUP BY w.WRNG_JAR
      , w.WRNG_UTM1_CDE
      , s.SPEC_NAM_WET
      , s.SPEC_NAM_NED
      , t.TOPO_DES
    ORDER BY s.SPEC_NAM_NED
```


* SQL-keywords (SELECT, FROM, JOIN, WHERE, GROUP BY, ...) are written in capitals
* Table names and field names are capitalized as they are defined in the database
* Use short and meaningful aliases and write them in lowercase
* Use a new line for each field in the SELECT-statement and each argument in the WHERE and GROUP BY clause
* Put the comma in front of the line in SELECT and GROUP BY statements
* Indent each field in the SELECT-statement and each argument in the WHERE and GROUP BY clause 
* When multiple arguments are used in the WHERE clause, AND/OR keywords are always placed at the front 
* Use full INNER JOIN statements
* JOINS should be indented
* Subqueries should be indented and properly named
* Put whitespaces around relational operators (= > ...)
* Document your scripts


# Layout

* SQL-keywords (SELECT, FROM, JOIN, WHERE, GROUP BY, ...) are written in capitals


    ```
    --Good

    SELECT *
    FROM person p
      INNER JOIN address a ON a.personid = p.id
    WHERE p.age > 50
    ```

    ```
    --Bad

    Select *
    From person p
      Inner join address a on a.personid = p.id
    where p.age > 50
    ```

    ```
    --Ugly

    :)
    ```

* Table names and field names are capitalized as they are defined in the database, i.e. lowercase when lowercase in the database, capitals when capitals in the database

* Aliases are written in lowercase

    ```
    --Good

    SELECT p.*
      , a.city
    FROM person p
      INNER JOIN address a ON a.personid = p.id
    WHERE p.age > 50
    ```

    ```
    --Bad

    SELECT P.*
      , A.city
    FROM person P
      INNER JOIN address A ON A.personid = P.id
    WHERE P.age > 50
    ```

* Table aliases are short and meaningful in the context of the query

    ```
    --Good

    SELECT p.*
      , a.city
    FROM person p
      INNER JOIN address a ON a.personid = p.id
    WHERE p.age > 50
    ```

    ```
    --Bad

    SELECT x.*
      , placewheresomeonelives.city
    FROM person x
      INNER JOIN address placewheresomeonelives ON placewheresomeonelives.personid = x.id
    WHERE x.age > 50
    ```
* Always use aliases

* Use a new line for each field in the SELECT-statement and each argument in the WHERE and GROUP BY clause.

    ```
    --Good

    SELECT p.firstname
      , p.lastname
      , a.city
    FROM person p
      INNER JOIN address a ON a.personid = p.id
    WHERE p.age > 50
      AND a.city like ‘Ar%’
    ```

    ```
    --Bad

    SELECT p.firstname, p.lastname, a.city
    FROM person p
      INNER JOIN address a ON a.personid = p.id
    WHERE p.age > 50 AND a.city like ‘Ar%’
    ```

* Put the comma in front of the line in SELECT and GROUP BY statements

    ```
    --Good

    SELECT p.firstname
      , p.lastname
      , a.city
      , COUNT(*) AS Aantal
    FROM person p
      INNER JOIN address a ON a.personid = p.id
    WHERE p.age > 50
      AND a.city like ‘Ar%’
    GROUP BY p.firstname
      , p.lastname
      , a.city
    ```
    
    ```
    --Less good

    SELECT p.firstname,
      p.lastname,
      a.city,
      COUNT(*) AS Aantal
    FROM person p
      INNER JOIN address a ON a.personid = p.id
    WHERE p.age > 50
      AND a.city like ‘Ar%’
    GROUP BY p.firstname,
      p.lastname,
      a.city
    ```

* Indent each field in the SELECT-statement and each argument in the WHERE and GROUP BY clause 


    ```
    --Good

    SELECT p.firstname
      , p.lastname
      , a.city
    FROM person p
      INNER JOIN address a ON a.personid = p.id
    WHERE p.age > 50
      AND a.city like ‘Ar%’
    ```

    ```
    --Bad

    SELECT p.firstname
    , p.lastname
    , a.city
    FROM person p
      INNER JOIN address a ON a.personid = p.id
    WHERE p.age > 50 
    AND a.city like ‘Ar%’
    ```

* When multiple arguments are used in the WHERE clause, AND/OR keywords are always placed at the front

    ```
    --Good

    SELECT *
    FROM person p
      INNER JOIN address a ON a.personid = p.id
    WHERE p.age > 50
      AND a.city like ‘Ar%’
      AND p.firstname = 'Billy'
    ```

    ```
    --Bad

    SELECT *
    FROM person p
      INNER JOIN address a ON a.personid = p.id
    WHERE p.age > 50 AND 
      a.city like ‘Ar%’ AND
      p.firstname = 'Billy'
    ```

* Multiple constraints for a JOIN are on the same line

    ```
    --Good layout (for a poorly designed database)

    SELECT *
    FROM person p
      INNER JOIN address a ON a.firstname = p.firstname AND a.lastname = p.lastname
    WHERE p.age > 50
      AND a.city like ‘Ar%’
      AND p.firstname = 'Billy'
    ```

    ```
    --Bad

    SELECT *
    FROM person p
      INNER JOIN address a ON a.firstname = p.firstname 
      AND a.lastname = p.lastname
    WHERE p.age > 50
      AND a.city like ‘Ar%’
      AND p.firstname = 'Billy'
    ```

* Use a full INNER JOIN statement


    ```
    --Good

    SELECT p.*
      , a.city
    FROM person p
      INNER JOIN address a ON a.personid = p.id
      LEFT JOIN hobby h ON h.personid = p.id
    ```

    ```
    --Bad

    SELECT p.*
      , a.city
    FROM person p
      JOIN address a ON a.personid = p.id
      LEFT JOIN hobby h ON h.personid = p.id
    ```

* Joins should be indented


    ```
    --Good

    SELECT p.*
      , a.city
    FROM person p
      INNER JOIN address a ON a.personid = p.id
      LEFT OUTER JOIN hobby h ON h.personid = p.id
    WHERE p.age > 50
    ```

    ```
    --Bad

    SELECT p.*
      , a.city
    FROM person p
    INNER JOIN address a ON a.personid = p.id
    LEFT OUTER JOIN hobby h ON h.personid = p.id
    WHERE p.age > 50
    ```
    
* Subqueries should be indented and properly named. Opening bracket is on a new line and aligned with the JOIN. Closing bracket is aligned with the opening bracket.


    ```
    --Good

    SELECT ppds.ppnt_cde
      , ds.drso_ser_nbr
      , dsth.dsth_dsha_cde
      , dsth.dsth_ocr_dte
    FROM tblDruksondetoestandhistoriek dsth
      INNER JOIN tblDruksonde ds ON ds.drso_id = dsth.dsth_drso_id
      INNER JOIN 
      (
        SELECT p.ppnt_cde
          , pd.ppds_drso_id 
        FROM relPeilpuntdruksonde pd
          INNER JOIN tblPeilpunt p ON p.ppnt_id = pd.ppds_ppnt_id
        WHERE p.ppnt_cde like 'KAMP%'
      )ppds ON ppds.ppds_drso_id = dsth.dsth_drso_id
    WHERE dsth.dsth_dsha_cde = 'PROG’
    ```

    ```
    --Bad

    SELECT ppds.ppnt_cde
      , ds.drso_ser_nbr
      , dsth.dsth_dsha_cde
      , dsth.dsth_ocr_dte
    FROM tblDruksondetoestandhistoriek dsth
      INNER JOIN tblDruksonde ds ON ds.drso_id = dsth.dsth_drso_id
      INNER JOIN (
      SELECT p.ppnt_cde
        , pd.ppds_drso_id 
      FROM relPeilpuntdruksonde pd
        INNER JOIN tblPeilpunt p ON p.ppnt_id = pd.ppds_ppnt_id
      WHERE p.ppnt_cde like 'KAMP%')ppds ON ppds.ppds_drso_id = dsth.dsth_drso_id
    WHERE dsth.dsth_dsha_cde = 'PROG’
    ```


# Documentation

* Rename your output fields when necessary. It makes the output comprehensible for users that are not familiar with the datamodel.


    ```
    --Good

    SELECT mpnt_cde AS meetpunt
      , mpnt_mpst_cde AS meetpuntstatus
      , mpnt_mptp_cde AS meetpuntype
    FROM tblmeetpunt
    ```

    ```
    --Bad

    SELECT mpnt_cde
      , mpnt_mpst_cde
      , mpnt_mptp_cde
    FROM tblmeetpunt
    ```

* Use  /** and **/ for comment blocks, e.g. a description at the beginning of the query


    ```
    --Example

    /**
    Deze query haalt naam en gemeente op van de werknemers boven de 50 jaar
    CreateDate: 21/05/2015
    Created by: Bill Gates
    **/

    SELECT p.name
    , a.city
    , p.age
    FROM person p
      LEFT OUTER JOIN address a ON a.personid = p.id
    WHERE p.age > 50
       AND p.firstname = ‘Piet’
    ```

* Use -- for small comments in the query


    ```
    --Example

    SELECT mpnt_cde AS meetpunt
      , mpnt_mpst_cde AS meetpuntstatus
      , mpnt_mptp_cde AS meetpuntype
    FROM tblmeetpunt
    WHERE mpnt_mpst_cde = ‘VLD’ --only validated points
    ```

# Tips and tricks

* Use TOP 10 (or LIMIT 10 in Postgres) when designing queries with a large resultset (taking a long time to run). It saves a lot of time in the design stage.

* Use 1 = 1 as the first line of the WHERE clause. This allows you to easily turn on and off all restrictions while designing your query. Beware of OR: where 1 = 1 OR age > 50 doesn’t mean that everybody is +50.


    ```
    --Example

    SELECT p.firstname
      , p.lastname
      , a.city
    FROM person p
      INNER JOIN address a ON a.personid = p.id
    WHERE 1 = 1
    --AND p.age > 50
      AND a.city like ‘Ar%’

    --Try to turn on and off the age constraint in this case. Pretty annoying, isn’t it? 

    SELECT p.firstname
      , p.lastname
      , a.city
    FROM person p
      INNER JOIN address a ON a.personid = p.id
    WHERE p.age > 50
      AND a.city like ‘Ar%’
    ```
* Ordering the output records can be done by explicitly using the name of the fields or by using the field number as you have defined them in the SELECT statement

    ```
    --Example

    SELECT p.firstname
      , p.lastname
      , a.city
    FROM person p
      INNER JOIN address a ON a.personid = p.id
    ORDER BY a.city, p.lastname

    --This will return the same result

    SELECT p.firstname
      , p.lastname
      , a.city
    FROM person p
      INNER JOIN address a ON a.personid = p.id
    ORDER BY 3, 2
    ```
* For advanced users: use Common Table Expressions instead of complex subqueries. It makes your query modular and easier to understand for other users

