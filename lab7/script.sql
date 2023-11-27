IF DB_ID(N'FilmDB') IS NOT NULL
    DROP DATABASE FilmDB;
GO

CREATE DATABASE FilmDB;
GO

USE FilmDB;
GO

CREATE TABLE Users(
    user_id int PRIMARY KEY IDENTITY,
    email nvarchar(256) UNIQUE NOT NULL ,
    username nvarchar(30) NOT NULL,
    registration_date datetime NOT NULL DEFAULT (GETDATE())
);
GO

INSERT INTO  Users(email, username)
   VALUES (N'test@test.ru', N'geogreck'),
         (N'test@test12.ru', N'lokshinsrw'),
         (N'test@test123.ru', N'kirilltop');
GO

CREATE TABLE Reviews(
    review_id int PRIMARY KEY IDENTITY,
    text nvarchar(max) NOT NULL DEFAULT  '',
    creation_date datetime NOT NULL DEFAULT (GETDATE()),
    verdict int NOT NULL DEFAULT 0,
    author_id int NOT NULL REFERENCES Users(user_id),
)

INSERT INTO Reviews(text, verdict, author_id)
    VALUES (N'Хороший фильм', 1, 1),
     (N'Плохой фильм', -1, 1),
     (N'Норм фильм фильм', 0, 1);
GO

SELECT *
FROM Users;
GO

SELECT *
FROM Reviews;
GO

-- Создание простого представленяи

CREATE VIEW  UsersEmailUsernameView
AS
    SELECT email, username
FROM Users;
GO

SELECT * FROM UsersEmailUsernameView;
GO


-- Создание представления на основе полей обеих связанных таблиц

CREATE VIEW UsersReviewsView WITH SCHEMABINDING
AS
    SELECT Users.user_id, Users.username, Reviews.review_id, Reviews.verdict, Reviews.text
    FROM dbo.Users JOIN dbo.Reviews on dbo.Users.user_id = dbo.Reviews.author_id
WITH CHECK OPTION;
GO

SELECT * FROM UsersReviewsView;
GO

-- Создание индекса для таблицы

CREATE INDEX USERS_EMAIL_IDX
    ON Users (email)
    INCLUDE (username);
GO

SELECT *
FROM sys.indexes
WHERE object_id = (SELECT object_id FROM sys.objects WHERE name = 'Users');
GO

-- Создание индексированного представления

CREATE UNIQUE CLUSTERED INDEX USERS_REVIEWS_VIEW_INDEX ON UsersReviewsView(username, verdict);
GO