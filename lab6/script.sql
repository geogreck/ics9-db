USE FilmDB;
GO

IF OBJECT_ID(N'Users') IS NOT NULL
    DROP TABLE  Users;
GO

-- 1. Таблица с автоинкрементым первичным ключом.

CREATE TABLE Users(
    user_id int PRIMARY KEY IDENTITY,
    email nvarchar(256) UNIQUE NOT NULL ,
    username nvarchar(30) NOT NULL,
    registration_date datetime NOT NULL DEFAULT (GETDATE())
);
GO

INSERT INTO  Users(email, username)
   VALUES ('test@test.ru', 'geogreck'),
         ('test@test12.ru', 'lokshinsrw');
GO

-- Функции, предназначенные  для получения сгенерированного значения
-- Способ 1
SELECT IDENT_CURRENT('Users');
GO


-- Способ 2
SELECT @@IDENTITY;
GO

-- Способ 3
SELECT SCOPE_IDENTITY();
GO

IF OBJECT_ID(N'Genres') IS NOT NULL
    DROP TABLE  Genres;
GO

-- 2. Таблица с CHECK

CREATE TABLE Genres (
    genre_name nvarchar(30) NOT NULL PRIMARY KEY,
    CONSTRAINT GENRE_NAME_LENGTH CHECK (LEN(genre_name) <= 15)
)
GO

INSERT INTO  Genres(genre_name)
   VALUES ('action'),
         ('detective');
GO

IF OBJECT_ID(N'Films') IS NOT NULL
    DROP TABLE  Films;
GO

-- Таблица с DEFAULT

CREATE TABLE Films(
    film_id int PRIMARY KEY IDENTITY,
    year int NOT NULL,
    title nvarchar(60) NOT NULL,
    description nvarchar(max) NOT NULL DEFAULT '',
)
GO

INSERT INTO  Films(year, title, description)
   VALUES (1968, 'Space Odyssey', 'Film about space.'),
    (2023, N'Новый фильм', N'очень тонко');
GO

IF OBJECT_ID(N'Reviews') IS NOT NULL
    DROP TABLE  Reviews;
GO

-- 3. Таблица с глобальным ключом

CREATE TABLE Reviews(
    review_id int PRIMARY KEY IDENTITY,
    text nvarchar(max) NOT NULL DEFAULT  '',
    creation_date datetime NOT NULL DEFAULT (GETDATE()),
    verdict int NOT NULL DEFAULT 0,
    author_id int NOT NULL REFERENCES Users(user_id),
    film_id int NOT NULL REFERENCES Films(film_id),
    review_num uniqueidentifier ROWGUIDCOL NOT NULL DEFAULT (newid()),
)

INSERT INTO Reviews(text, verdict, author_id, film_id)
    VALUES (N'Хороший фильм', 1, 1, 1);

-- 4. Таблица с первичным ключом на основе последовательности.

IF OBJECT_ID('ScoreSequence') IS NOT NULL
    DROP SEQUENCE ScoreSequence;
GO

CREATE SEQUENCE ScoreSequence
    START WITH 1
    INCREMENT BY 1;
GO

IF OBJECT_ID('Scores') IS NOT NULL
    DROP TABLE  Scores;
GO

CREATE TABLE Scores (
    score_id int PRIMARY KEY DEFAULT (NEXT VALUE FOR ScoreSequence),
    mark int NOT NULL,
    author_id int NOT NULL REFERENCES Users(user_id),
    film_id int NOT NULL REFERENCES Films(film_id),
)
GO

INSERT INTO Scores(mark, author_id, film_id)
    VALUES (1, 1, 1),
     (1, 1, 2);
GO

SELECT  * FROM Scores;
GO

-- 5. Связанные таблицы (users & scores)
CREATE TABLE Users(
    user_id int PRIMARY KEY IDENTITY,
    email nvarchar(256) UNIQUE NOT NULL ,
    username nvarchar(30) NOT NULL,
    registration_date datetime NOT NULL DEFAULT (GETDATE())
);
GO

IF OBJECT_ID('Scores') IS NOT NULL
    DROP TABLE  Scores;
GO

CREATE TABLE Scores (
    score_id int PRIMARY KEY DEFAULT (NEXT VALUE FOR ScoreSequence),
    mark int NOT NULL,
    author_id int REFERENCES Users(user_id),
    film_id int REFERENCES Films(film_id),
);
GO

INSERT INTO Scores(mark, author_id, film_id)
    VALUES (1, 1, 1),
     (1, 1, 2);
GO

SELECT  * FROM Scores;

-- No action
DELETE FROM Users where user_id = 1;
GO

-- Delete cascade

ALTER TABLE Scores
ADD CONSTRAINT USER_ID_FK FOREIGN KEY(author_id) REFERENCES Users(user_id) ON DELETE CASCADE;

ALTER TABLE Scores
ADD CONSTRAINT FILM_ID_FK FOREIGN KEY(film_id) REFERENCES Films(film_id) ON DELETE CASCADE;

ALTER TABLE Scores
DROP CONSTRAINT USER_ID_FK;

ALTER TABLE Scores
DROP CONSTRAINT FILM_ID_FK;


-- Set null

ALTER TABLE Scores
ADD CONSTRAINT USER_ID_FK FOREIGN KEY(author_id) REFERENCES Users(user_id) ON DELETE SET NULL;

ALTER TABLE Scores
ADD CONSTRAINT FILM_ID_FK FOREIGN KEY(film_id) REFERENCES Films(film_id) ON DELETE SET NULL;

ALTER TABLE Scores
DROP CONSTRAINT USER_ID_FK;

ALTER TABLE Scores
DROP CONSTRAINT FILM_ID_FK;

-- Set default

ALTER TABLE Scores
ADD CONSTRAINT USER_ID_FK FOREIGN KEY(author_id) REFERENCES Users(user_id) ON DELETE SET DEFAULT;

ALTER TABLE Scores
ADD CONSTRAINT FILM_ID_FK FOREIGN KEY(film_id) REFERENCES Films(film_id) ON DELETE SET DEFAULT;

ALTER TABLE Scores
DROP CONSTRAINT USER_ID_FK;

ALTER TABLE Scores
DROP CONSTRAINT FILM_ID_FK;
