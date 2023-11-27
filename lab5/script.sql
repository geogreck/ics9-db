USE master;
GO
IF DB_ID(N'FilmDB') IS NOT NULL
DROP DATABASE FilmDB;
GO

-- 1. Создание базы данных, определение настроек размеров файлов
CREATE DATABASE FilmDB
ON PRIMARY
  ( NAME='Film_dat',
    FILENAME = '/data/data.mdf',
    SIZE=10MB,
    MAXSIZE=UNLIMITED, FILEGROWTH=5%)

  LOG ON (
      NAME =  'Film_log',
      FILENAME = '/data/film_log.ldf',
      SIZE=10MB,
      MAXSIZE=25MB,
      FILEGROWTH=5MB
      );


USE FilmDB;
-- 2. Создание произвольной таблицы

IF OBJECT_ID(N'USERS') IS NOT NULL
    DROP TABLE  USERS;

CREATE TABLE USERS(
    user_id int PRIMARY KEY,
    email nvarchar(256) UNIQUE NOT NULL ,
    username nvarchar(30) NOT NULL,
    registration_date datetime NOT NULL DEFAULT (GETDATE())
);


-- 3. Создание файловой группы и файла данных

ALTER DATABASE FilmDB
ADD FILEGROUP FilmFilegroup;
GO

ALTER  DATABASE FilmDB
ADD FILE (
    NAME='Film_user_dat',
    FILENAME = '/data/Film_user_dat.ndf',
    SIZE=10MB,
    MAXSIZE=UNLIMITED, FILEGROWTH=5%
    )
TO FILEGROUP FilmFilegroup;
GO

-- 4. Установка новой файловой группы группой по-умолчанию

ALTER DATABASE FilmDB
MODIFY FILEGROUP FilmFilegroup DEFAULT;

-- 5. Создание еще одной таблицы


if OBJECT_ID(N'GENRES') is NOT NULL
	DROP Table GENRES;

CREATE TABLE GENRES(
    genre_name nvarchar(30) NOT NULL PRIMARY KEY,
);

-- 6. Удаление группы

ALTER DATABASE FilmDB
    MODIFY FILEGROUP [primary] default;

DROP TABLE  GENRES;

ALTER  DATABASE  FilmDB
    REMOVE FILE Film_user_dat;

ALTER DATABASE FilmDB
    REMOVE FILEGROUP FilmFilegroup;

-- 7. Создание схемы, перемещение таблицы, удаление таблицы, удаление схемы

CREATE SCHEMA Film_SCHEMA;

ALTER SCHEMA Film_SCHEMA TRANSFER dbo.Users;

DROP TABLE  Film_SCHEMA.Users;

DROP SCHEMA Film_SCHEMA;
