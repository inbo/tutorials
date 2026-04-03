---
title: "Table Inheritance with PostgreSQL"
description: "A logical and efficient table structure for TODO lists and fieldwork calendars."
date: "2026-01-30"
authors: [falkmielke]
categories: ["databases", "development"]
tags: ["sql", "postgresql", "inheritance", "development"]
number-sections: true
link-citations: true
params:
  math: true
format:
  hugo-md:
    toc: false
    preserve_yaml: true
    html-math-method: katex
---

# Motivation

For our "Monitoring Programme for the Natural Environment" project (MNE, [*cf.*](https://www.vlaanderen.be/inbo/teams/meetnetten-natuurlijk-milieu)) we organize fieldwork with a [QGIS](https://qgis.org)/[QField](https://qfield.org) front-end which connects to a database backend.
The simplicity and elegance of this combination is much appreciated and has helped us enormously to distribute tasks and capture data.

One central component of our database is a fieldwork calendar, which you could think of as a sort of **TODO list**: in there are the various activity types, per location, with a due date.
This is outbound information: it is planned in desktop work, and facilitates the allocation of our efforts in the field.
On the other hand, there are the actual actions performed in the field: inbound information captured during execution of the task.
All the different tasks (installation/preparation/measurement) have **some data fields in common, whereas other fields are task-specific**.

This is a rather specific situation, but not too uncommon:
we have an *abstract definition* of a task (common fields), and *special sub-types* of tasks (specific fields).
In programming terms, the related concepts are [polymorphism](https://en.wikipedia.org/wiki/Polymorphism_(computer_science)) and [inheritance](https://en.wikipedia.org/wiki/Inheritance_(object-oriented_programming)).

This tutorial demonstrates how to implement a TODO list with activities of different task types in [postgreSQL](https://www.postgresql.org/docs/current/ddl-inherit.html).
The situation can be solved entirely without inheritance - in fact, we did so, naïvely, for our initial iteration of MNE fieldwork tools.
However, an adequate logical representation of the data type hierarchy is both logically convenient ("elegant", and understandable) and computationally efficient.
Thus, inheritance might be an option to consider for joining TODO lists or field activities.
I will herein explore the basic implementation, in practical use, and also assert which use cases this technique is good for.

# PostgreSQL installation (optional)

To get our hands on the examples below, running some kind of postgreSQL server is required.
There are convenient online services to test small chunks of pgSQL, which allow you to test the SQL code below without a local installation: for example <https://dbfiddle.uk> or <https://aiven.io/tools/pg-playground>.
You will find links to "fiddles" in between sections below.

However, installing a local postgreSQL server is not all too complicated, so I took the occasion to list the simple steps.
These will work on an arbitrary linux system (e.g. in a [container](https://tutorials.inbo.be/tags/containers/)), with minor variance.
Installation on Windows can be [achieved via an installer](https://www.postgresql.org/download/windows/) and documented elsewhere.


Thus, the following guidelines apply to a linux environment.
First off, install the right `postgresql` package for your operating system; usually it is called `postgresql`.
Here, I will mostly follow [this guide](https://wiki.archlinux.org/title/PostgreSQL), which contains good general advice independent of OS.

Next, a database must be initialized:

``` sh
su - postgres
initdb -D /var/lib/postgres/data
```

Initalization succeeds, and the server process can be started with the following command.

``` sh
pg_ctl -D /var/lib/postgres/data -l logfile start
```

If startup fails, you will find the `logfile` (a text file) in the folder where you started (e.g. folder permissions should be granted to the `postgres` user).

Otherwise, congratulations, a local server is up and running!
We will need a user...

``` sh
createuser --interactive
# I called my user "sauron", reference to a famous story. A superuser, of course.
```

... and a database.

``` sh
createdb middleearth -O sauron
```

Here, the test database is `middleearth`, its owner is `sauron`; names are totally arbitrary.

To connect to the database, use the `psql` command, specifying the user with option `-U` and the database with option `-d`.

``` sh
psql -U sauron -d middleearth
```

I skip over many details here, which you will find explained elsewhere.
For a production server, I highly recommend to carefully go through all the postgres configurations and settings, to set up a firewall, an so forth.

You might find [pgAdmin](https://www.pgadmin.org) a convenient tool to interact with the database, and it comes bundled with many postgres installations.
Also have a look at [pgModeler](https://pgmodeler.io) for more complex, visually guided database design.
For the toy data below, choice is all up to you.

To use the connection in this quarto notebook, I will establish a connection via R.

``` r
stopifnot("DBI" = require("DBI"))
```

    Loading required package: DBI

``` r
stopifnot("RPostgreSQL" = require("RPostgreSQL"))
```

    Loading required package: RPostgreSQL

``` r
conn <- DBI::dbConnect(
  drv = DBI::dbDriver("PostgreSQL"),
  # host = "localhost", port = 5432,
  user = "sauron", db = "middleearth"
)
```

# Test Data - Naïve Implementation

## Nomenclature

I will use this chapter to establish some basic terminology of SQL, stuff that you probably learn in all the very first books or tutorials you encounter.

*Raison d'être* for all SQL applications is the use of **relational databases**, i.e. sets of tables which are somehow *linked* to one another.
Linkage is established with keys, as I will not demonstrate below for the sake of simplicity.
Database software is designed to handle tables in a computationally efficient way.
**SQL** is the "language" which helps you to control your database (e.g. insert data, or ask for reports).
One dialect of SQL is **postgreSQL**, or postgres, or pgSQL, or `pg` for short.

You can think of the columns of the tables in your database as the characteristics which define each table entry.
Hence, they are called **fields**.
The data is stored in rows.
This is best understood on an example.

## Activities

We will create our first table with the following fields.
In brackets, the different columns are defined as a given data type.

``` sql
CREATE TABLE Activities (
  activity_id INT PRIMARY KEY,
  category VARCHAR(4),
  activity VARCHAR,
  due_date DATE,
  n_repeats INT,
  done BOOLEAN DEFAULT FALSE,
  notes TEXT DEFAULT NULL
);

-- if adjustment is needed:
-- DROP TABLE Activities;
```

To remain the ruler of middle earth, some workout might be justified.
Here is our training plan.

``` sql
INSERT INTO Activities (activity_id, category, activity, due_date, n_repeats)
VALUES
  ( 1, 'push', 'push-ups', '2026-02-01', 20),
  ( 2, 'quad', 'squats',   '2026-02-01', 16),
  ( 3, 'pull', 'pull-ups', '2026-02-01',  5),
  ( 4, 'push', 'dips',     '2026-02-01', 16),
  ( 5, 'quad', 'lunges',   '2026-02-01', 25),
  ( 6, 'pull', 'pull-ups', '2026-02-01',  5),
  ( 7, 'push', 'push-ups', '2026-02-02', 22),
  ( 8, 'quad', 'squats',   '2026-02-02', 17),
  ( 9, 'pull', 'pull-ups', '2026-02-02',  6),
  (10, 'push', 'dips',     '2026-02-02', 18),
  (11, 'quad', 'lunges',   '2026-02-02', 30),
  (12, 'pull', 'pull-ups', '2026-02-02',  6)
;
```

We can look at out training plan with a simple `SELECT`:

``` sql
SELECT * FROM Activities;
```

| activity_id | category | activity | due_date   | n_repeats | done  | notes |
|:------------|:---------|:---------|:-----------|----------:|:------|:------|
| 1           | push     | push-ups | 2026-02-01 |        20 | FALSE | NA    |
| 2           | quad     | squats   | 2026-02-01 |        16 | FALSE | NA    |
| 3           | pull     | pull-ups | 2026-02-01 |         5 | FALSE | NA    |
| 4           | push     | dips     | 2026-02-01 |        16 | FALSE | NA    |
| 5           | quad     | lunges   | 2026-02-01 |        25 | FALSE | NA    |
| 6           | pull     | pull-ups | 2026-02-01 |         5 | FALSE | NA    |
| 7           | push     | push-ups | 2026-02-02 |        22 | FALSE | NA    |
| 8           | quad     | squats   | 2026-02-02 |        17 | FALSE | NA    |
| 9           | pull     | pull-ups | 2026-02-02 |         6 | FALSE | NA    |
| 10          | push     | dips     | 2026-02-02 |        18 | FALSE | NA    |

    Displaying records 1 - 10

This is the key SQL syntax, and it is really that simple: `CREATE`, `INSERT`, `UPDATE`, `SELECT`, `DROP` all do what you intuitively think they would.

Note the conceptually different kinds of fields (columns) in this table:

-   `activity_id` is a technical identifier, the "primary key"; one would define a "sequence" in real databases
-   `category` and `activity` are the logical, human-readable tasks; they are not unique here and could be moved to a metadata-table (linked with a foreign key)
-   however, the combination of these with `date` uniquely characterizes an activity
-   `n_repeats` is given *a priori* by the personal trainer
-   `done` and `notes` are only entered upon execution; they are input fields

## All Activities are Equal...

> ... but some activities are more equal than others.

Let's assume that, in order to follow up training progress, we would like to capture additional information for only some activities, at execution time.

For example, we might be pushed to get fast on push-ups, so recording their `duration` in seconds might make sense (in contrast, "dips" may take their time, duration is not relevant).
For squats, a weight must be mounted beforehand, which makes less sense for lunges unless you intend the combined exercise.

Naïvely, this could be solved by extra tables which are activity-specific.

``` sql
CREATE TABLE PushUps (
  activity_id INT REFERENCES Activities (activity_id),
  duration_s DOUBLE PRECISION
);

CREATE TABLE Squats (
  activity_id INT REFERENCES Activities (activity_id),
  weight_kg DOUBLE PRECISION
);


-- Squat weights are defined a priori:
INSERT INTO Squats (activity_id, weight_kg)
VALUES
  ( 2, 60),
  ( 8, 64)
;
```

*(Technical note: normally, these auxiliary tables should contain their own primary keys. Omitted here for simplicity.)*

The training plan query gets a bit more involved:
it requires some [kind of join](https://www.postgresql.org/docs/current/queries-table-expressions.html).

``` sql
SELECT A.*, P.duration_s, S.weight_kg
FROM Activities A
LEFT JOIN PushUps P ON A.activity_id = P.activity_id
LEFT JOIN Squats S ON A.activity_id = S.activity_id
;
```

| activity_id | category | activity | due_date | n_repeats | done | notes | duration_s | weight_kg |
|---------:|:-------|:-------|:---------|--------:|:-----|:-----|---------:|--------:|
| 2 | quad | squats | 2026-02-01 | 16 | FALSE | NA | NA | 60 |
| 8 | quad | squats | 2026-02-02 | 17 | FALSE | NA | NA | 64 |
| 10 | push | dips | 2026-02-02 | 18 | FALSE | NA | NA | NA |
| 6 | pull | pull-ups | 2026-02-01 | 5 | FALSE | NA | NA | NA |
| 7 | push | push-ups | 2026-02-02 | 22 | FALSE | NA | NA | NA |
| 11 | quad | lunges | 2026-02-02 | 30 | FALSE | NA | NA | NA |
| 12 | pull | pull-ups | 2026-02-02 | 6 | FALSE | NA | NA | NA |
| 5 | quad | lunges | 2026-02-01 | 25 | FALSE | NA | NA | NA |
| 4 | push | dips | 2026-02-01 | 16 | FALSE | NA | NA | NA |
| 1 | push | push-ups | 2026-02-01 | 20 | FALSE | NA | NA | NA |

    Displaying records 1 - 10

Or, slightly less convoluted:

``` sql
SELECT *
FROM Activities
NATURAL FULL JOIN PushUps
NATURAL FULL JOIN Squats
;
```

| activity_id | category | activity | due_date | n_repeats | done | notes | duration_s | weight_kg |
|:---------|:-------|:-------|:---------|--------:|:-----|:-----|---------:|--------:|
| 1 | push | push-ups | 2026-02-01 | 20 | FALSE | NA | NA | NA |
| 2 | quad | squats | 2026-02-01 | 16 | FALSE | NA | NA | 60 |
| 3 | pull | pull-ups | 2026-02-01 | 5 | FALSE | NA | NA | NA |
| 4 | push | dips | 2026-02-01 | 16 | FALSE | NA | NA | NA |
| 5 | quad | lunges | 2026-02-01 | 25 | FALSE | NA | NA | NA |
| 6 | pull | pull-ups | 2026-02-01 | 5 | FALSE | NA | NA | NA |
| 7 | push | push-ups | 2026-02-02 | 22 | FALSE | NA | NA | NA |
| 8 | quad | squats | 2026-02-02 | 17 | FALSE | NA | NA | 64 |
| 9 | pull | pull-ups | 2026-02-02 | 6 | FALSE | NA | NA | NA |
| 10 | push | dips | 2026-02-02 | 18 | FALSE | NA | NA | NA |

    Displaying records 1 - 10

And filling the auxiliary tables might be tricky.
Push-up duration is filled on execution time, whereas squat weight might be planned by the supervisor at plan creation time.

{{% callout note %}}

This design works, but is relatively impractical, not only for reporting purposes.
The tables with "special" activities must be filled *a priori*, or in the gym, conditional upon the activity type, and consistency of the identifier fields must be ensured.

Keep track of your keys!

{{% /callout %}}

Our database is fully functional, yet maintenance is somewhat cumbersome.

It is time to start over and explore **inheritance**.

``` sql
DROP TABLE IF EXISTS Activities CASCADE;
DROP TABLE IF EXISTS PushUps;
DROP TABLE IF EXISTS Squats;
```

*(For reproduction, I dropped all the above here: <https://dbfiddle.uk/X9vf4Czd>)*

# Table Inheritance

## Structure

The central information structure of `Activities` is still fine.

``` sql
CREATE TABLE Activities (
  activity_id INT PRIMARY KEY,
  category VARCHAR(4),
  activity VARCHAR,
  due_date DATE,
  n_repeats INT,
  done BOOLEAN DEFAULT FALSE,
  notes TEXT DEFAULT NULL
);
```

However, in addition to the general activities, there are the special ones.
Their tables *inherit* all the fields and features from general activities.
They add their own fields.
(See also the example in the [postgresql documentation](https://www.postgresql.org/docs/current/ddl-inherit.html).)

``` sql
CREATE TABLE PushUps (
  duration_s DOUBLE PRECISION -- entered upon execution time
  ) INHERITS (Activities);

CREATE TABLE Squats (
  weight_kg DOUBLE PRECISION -- a priori training plan
  ) INHERITS (Activities);
```

Here are two changes from above: the identifier column may be omitted (it is inherited), and inheritance is established by the keyword `INHERITS (parenttable)`.

## Data

Data input should be specific to ensure that the correct types are filled:

``` sql
INSERT INTO Activities (activity_id, category, activity, due_date, n_repeats)
VALUES
  ( 3, 'pull', 'pull-ups', '2026-02-01',  5),
  ( 4, 'push', 'dips',     '2026-02-01', 16),
  ( 5, 'quad', 'lunges',   '2026-02-01', 25),
  ( 6, 'pull', 'pull-ups', '2026-02-01',  5),
  ( 9, 'pull', 'pull-ups', '2026-02-02',  6),
  (10, 'push', 'dips',     '2026-02-02', 18),
  (11, 'quad', 'lunges',   '2026-02-02', 30),
  (12, 'pull', 'pull-ups', '2026-02-02',  6)
;


INSERT INTO PushUps (activity_id, category, activity, due_date, n_repeats)
VALUES
  ( 1, 'push', 'push-ups', '2026-02-01', 20),
  ( 7, 'push', 'push-ups', '2026-02-02', 22)
;

INSERT INTO Squats (activity_id, category, activity, due_date, n_repeats, weight_kg)
VALUES
  ( 2, 'quad', 'squats',   '2026-02-01', 16, 60),
  ( 8, 'quad', 'squats',   '2026-02-02', 17, 64)
;

-- if something went wrong:
-- DELETE FROM Squats;
```

## Reports

Time for a fitness report:

``` sql
SELECT * FROM Activities;
```

| activity_id | category | activity | due_date   | n_repeats | done  | notes |
|------------:|:---------|:---------|:-----------|----------:|:------|:------|
|           3 | pull     | pull-ups | 2026-02-01 |         5 | FALSE | NA    |
|           4 | push     | dips     | 2026-02-01 |        16 | FALSE | NA    |
|           5 | quad     | lunges   | 2026-02-01 |        25 | FALSE | NA    |
|           6 | pull     | pull-ups | 2026-02-01 |         5 | FALSE | NA    |
|           9 | pull     | pull-ups | 2026-02-02 |         6 | FALSE | NA    |
|          10 | push     | dips     | 2026-02-02 |        18 | FALSE | NA    |
|          11 | quad     | lunges   | 2026-02-02 |        30 | FALSE | NA    |
|          12 | pull     | pull-ups | 2026-02-02 |         6 | FALSE | NA    |
|           1 | push     | push-ups | 2026-02-01 |        20 | FALSE | NA    |
|           7 | push     | push-ups | 2026-02-02 |        22 | FALSE | NA    |

    Displaying records 1 - 10

Trivially, PushUps can be queried by selecting from the respective table.
Yet there is also the option to show activities which are neither push-ups, nor squats, using `ONLY`.

``` sql
SELECT * FROM ONLY Activities;
```

| activity_id | category | activity | due_date   | n_repeats | done  | notes |
|------------:|:---------|:---------|:-----------|----------:|:------|:------|
|           3 | pull     | pull-ups | 2026-02-01 |         5 | FALSE | NA    |
|           4 | push     | dips     | 2026-02-01 |        16 | FALSE | NA    |
|           5 | quad     | lunges   | 2026-02-01 |        25 | FALSE | NA    |
|           6 | pull     | pull-ups | 2026-02-01 |         5 | FALSE | NA    |
|           9 | pull     | pull-ups | 2026-02-02 |         6 | FALSE | NA    |
|          10 | push     | dips     | 2026-02-02 |        18 | FALSE | NA    |
|          11 | quad     | lunges   | 2026-02-02 |        30 | FALSE | NA    |
|          12 | pull     | pull-ups | 2026-02-02 |         6 | FALSE | NA    |

    8 records

In both cases, only the fields common to all activities are returned ([see here](https://stackoverflow.com/questions/20036578/is-it-possible-to-access-child-information-from-parent-in-postgresql-inheritance)).

{{% callout note %}}

Inheritance in postgreSQL is *not* inheritance of content.
Parent tables and child tables remain strictly separated in terms of the data in them.
Instead, this is about **structural inheritance**: the child tables inherit fields of the parent table.

{{% /callout %}}

We still need a way to get the [combined set of fields](https://dba.stackexchange.com/a/125028/358945):

``` sql
SELECT * 
FROM ONLY Activities 
NATURAL FULL JOIN PushUps
NATURAL FULL JOIN Squats
ORDER BY activity_id ASC
;
```

| activity_id | category | activity | due_date | n_repeats | done | notes | duration_s | weight_kg |
|:---------|:-------|:-------|:---------|--------:|:-----|:-----|---------:|--------:|
| 1 | push | push-ups | 2026-02-01 | 20 | FALSE | NA | NA | NA |
| 2 | quad | squats | 2026-02-01 | 16 | FALSE | NA | NA | 60 |
| 3 | pull | pull-ups | 2026-02-01 | 5 | FALSE | NA | NA | NA |
| 4 | push | dips | 2026-02-01 | 16 | FALSE | NA | NA | NA |
| 5 | quad | lunges | 2026-02-01 | 25 | FALSE | NA | NA | NA |
| 6 | pull | pull-ups | 2026-02-01 | 5 | FALSE | NA | NA | NA |
| 7 | push | push-ups | 2026-02-02 | 22 | FALSE | NA | NA | NA |
| 8 | quad | squats | 2026-02-02 | 17 | FALSE | NA | NA | 64 |
| 9 | pull | pull-ups | 2026-02-02 | 6 | FALSE | NA | NA | NA |
| 10 | push | dips | 2026-02-02 | 18 | FALSE | NA | NA | NA |

    Displaying records 1 - 10

This gives us all the options for querying data from the tables.
But there is a caveat: *updating* data in the tables is conditional on the data type, i.e. activity-type-dependent.

``` sql
UPDATE Activities
SET duration_s = 16
WHERE category = 'push'
AND activity = 'push-ups'
AND due_date = '2026-02-01'
;
-- fails!
```

    Error in postgresqlExecStatement(conn, statement, ...): RPosgreSQL error: could not Retrieve the result : ERROR:  column "duration_s" of relation "activities" does not exist
    LINE 2: SET duration_s = 16
                ^

This might be intentional, if your front-end is specific for each activity type.
It is easily possible tu update the push-ups by updating the `PushUps` table directly, as in `UPDATE Activities SET duration_s = 16 [...]`.
But it is less convenient than with the non-inheritance, supertable solution to distinguish PushUps, Squats, and other Activities on upload.
If you built a general interface, making an exception for only certain activity types might be complicated.

However, there is a solution: update rules.
I would judge that update rules are a more advanced skill, but do not hold back: with some patience and testing, they are a convenient skill to master[^1].

[^1]: Another pretty useful application for update rules is this: during alteration of database structure, you can set up redirection rules which automatically parse incoming data from an old structure component to the new one. This ensures continuity and prevents data loss, even if a user or dev missed that important line your changelog.


## *Advanced:* Views and Update Rules

The first step to solve the above is formalizing our inclusive query above into a **View** ([*cf.* the documentation](https://www.postgresql.org/docs/18/sql-createview.html)):

``` sql
CREATE VIEW AllActivities AS
SELECT * 
FROM ONLY Activities 
NATURAL FULL JOIN PushUps
NATURAL FULL JOIN Squats
ORDER BY activity_id ASC
;
```

This by itself is convenient for reporting; the data is even ordered.

Views which combine tables cannot be updated directly, unless update rules are defined.
As with real fitness, I personally like to start with a `DO NOTHING`, and build up from that.

``` sql
-- first, erase all default updating activities
CREATE RULE Activities_upd0 AS
ON UPDATE TO AllActivities
DO INSTEAD NOTHING;

-- update common fields of general activities
CREATE RULE Activities_upd_all AS
ON UPDATE TO AllActivities
DO ALSO
  UPDATE Activities
  SET
    done = NEW.done,
    notes = NEW.notes
  WHERE activity_id = OLD.activity_id
;

-- finally, update specific activities which require user input
CREATE RULE Activities_upd_pushups AS
ON UPDATE TO AllActivities
DO ALSO
  UPDATE PushUps
  SET
    duration_s = NEW.duration_s
  WHERE activity_id = OLD.activity_id
;

SELECT * FROM AllActivities;
```

| activity_id | category | activity | due_date   | n_repeats | done  | notes | duration_s | weight_kg |
|:------------|:---------|:---------|:-----------|----------:|:------|:------|-----------:|----------:|
| 1           | push     | push-ups | 2026-02-01 |        20 | FALSE | NA    |         NA |        NA |
| 2           | quad     | squats   | 2026-02-01 |        16 | FALSE | NA    |         NA |        60 |
| 3           | pull     | pull-ups | 2026-02-01 |         5 | FALSE | NA    |         NA |        NA |
| 4           | push     | dips     | 2026-02-01 |        16 | FALSE | NA    |         NA |        NA |
| 5           | quad     | lunges   | 2026-02-01 |        25 | FALSE | NA    |         NA |        NA |
| 6           | pull     | pull-ups | 2026-02-01 |         5 | FALSE | NA    |         NA |        NA |
| 7           | push     | push-ups | 2026-02-02 |        22 | FALSE | NA    |         NA |        NA |
| 8           | quad     | squats   | 2026-02-02 |        17 | FALSE | NA    |         NA |        64 |
| 9           | pull     | pull-ups | 2026-02-02 |         6 | FALSE | NA    |         NA |        NA |
| 10          | push     | dips     | 2026-02-02 |        18 | FALSE | NA    |         NA |        NA |

    Displaying records 1 - 10

Testing it:

``` sql
UPDATE AllActivities
SET duration_s = 16, notes = 'best attempt ever!'
WHERE category = 'push'
AND activity = 'push-ups'
AND due_date = '2026-02-01'
;
-- this stdouts "UPDATE 0", but did actually work:

SELECT * FROM AllActivities;
```

| activity_id | category | activity | due_date   | n_repeats | done  | notes                | duration_s | weight_kg |
|:------------|:---------|:---------|:-----------|----------:|:------|:---------------------|-----------:|----------:|
| 1           | push     | push-ups | 2026-02-01 |        20 | TRUE  | 'best attempt ever!' |         16 |        NA |
| 2           | quad     | squats   | 2026-02-01 |        16 | FALSE | NA                   |         NA |        60 |
| 3           | pull     | pull-ups | 2026-02-01 |         5 | FALSE | NA                   |         NA |        NA |
| 4           | push     | dips     | 2026-02-01 |        16 | FALSE | NA                   |         NA |        NA |
| 5           | quad     | lunges   | 2026-02-01 |        25 | FALSE | NA                   |         NA |        NA |
| 6           | pull     | pull-ups | 2026-02-01 |         5 | FALSE | NA                   |         NA |        NA |
| 7           | push     | push-ups | 2026-02-02 |        22 | FALSE | NA                   |         NA |        NA |
| 8           | quad     | squats   | 2026-02-02 |        17 | FALSE | NA                   |         NA |        64 |
| 9           | pull     | pull-ups | 2026-02-02 |         6 | FALSE | NA                   |         NA |        NA |
| 10          | push     | dips     | 2026-02-02 |        18 | FALSE | NA                   |         NA |        NA |

    Displaying records 1 - 10

There are additional benefits to this seemingly cumbersome setup of views and update rules:

-   dynamic sorting and grouping are possible
-   only editable fields are edited (e.g. user has no saying on the number of repeats)
-   multiple inheritance and complex joins are possible
-   keys/indexes/serials can cover all tables in the inheritance chain

For technical UPDATEs and INSERTs, however, the implemented routines best remain conditional (unless they only affect the common fields).

{{% callout note %}}
*A tip if you interact with inherited tables in R, using `dplyr`:*
R/`dplyr`/`dbplyr` lacks a switch to trigger the `ONLY` keyword, or at least I did not find one.
However, you can work around by creating your own function for that, based on the `tbl(...)` query and `anti_join` ([docs](https://dplyr.tidyverse.org/reference/filter-joins.html)).
Alternatively, build around direct queries via `DBI`.
{{% /callout %}}


Views are not exclusive to situations which use Inheritance: they could have equally well simplified the naïve, non-hierarchical situation.

*(A snapshot of this second design variant is available here: <https://dbfiddle.uk/cWOS-ALP>)*

# Summary and Discussion

While databases are convenient and highly efficient to work with, there are lots of considerations and choices for database design.
The most fundamental idea of relational databases is that tables relate to each other via keys, and that different types or classes of data should be stored in their own tables.

However, in some specific cases, the naïve implementation is agnostic to the logical relation of data classes.
This could cause technical inefficiency by redundancy.
In these cases, table **inheritance** might be an elegant solution.

Even if the computational load would be equivalent in both the implementations I presented above,
the use of `INHERITS` gives some extra conceptual structure to the data which has documentational value.

Inheritance is not a general solution, and should be carefully considered.
Keep in mind that postgreSQL inheritance is *structural* inheritance (I think of it as automatic `UNION`s which happen when I query the common fields; `NATURAL FULL JOIN`s play nicely into that).
Advanced functionality is available with other `JOIN`s, Views, and `UPDATE` Rules.

Taking this further, some more ideas.

As in all good manifestations of inheritance, multiple inheritance is possible: your tables can be the recombination of multiple parent tables (e.g. you could define a combination of fitness `Activities` and `Calendar` elements).

There is a crucial design choice I have skipped above: namely whether the parent table is supposed to contain data at all.
What I have shown is a cumulative hierarchical implementation, where some subset of a data type receives extra fields.
In other situations, the definition of an abstract [interface](https://en.wikipedia.org/wiki/Interface_(object-oriented_programming)) would be useful.
Think of one table which defines all the columns and data types common to all activities (but holds no actual data), and a set of descendant "sibling tables" which inherit these fields and each add their own.

Finally, you might want to check how user roles and permissions behave in different inheritance settings.
Basically, child tables inherit the permissions of the parent tables; just keep track of permissions (`\dp`).

These are interesting design options, which require basic understanding of the conceptual idea.
I hope the test setting above helped you to familiarize with the concept, enabling you to implement your own meaningful and elegant relational database structures.

# Further Reading

Some references I found on the way:

-   <https://www.postgresql.org/docs/current/tutorial-inheritance.html>
-   <https://www.postgresql.org/docs/current/ddl-inherit.html>
-   <https://ruheni.dev/writing/sql-table-inheritance/>
-   <https://medium.com/@akshatgadodia/unlocking-the-power-of-postgresql-table-inheritance-a-hidden-gem-842229a1848f>
-   <https://www.experts-exchange.com/questions/21399911/inheritance-of-tables-in-mssql.html>
-   <https://www.scaler.com/topics/postgresql/inheritance-in-postgresql/>

*(Final steps to clean up the sql environment.)*

``` sql
DROP TABLE IF EXISTS Activities CASCADE;
DROP TABLE IF EXISTS PushUps;
DROP TABLE IF EXISTS Squats;
```

``` r
DBI::dbDisconnect(conn)
```

    [1] TRUE
