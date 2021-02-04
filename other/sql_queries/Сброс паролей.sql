-- MSSQL:

-- 1 запрос
EXEC sp_rename 'v8users', 'v8users_old'
GO
UPDATE Params
SET FileName = 'users.usr_old'
WHERE FileName = 'users.usr'
GO

-- Открыть конфигуратор

-- 2 запрос
DROP TABLE v8users
GO
EXEC sp_rename 'v8users_old', 'v8users'
GO
UPDATE Params
SET FileName = 'users.usr'
WHERE FileName = 'users.usr_old'
GO

-- PG:

-- 1 запрос
ALTER TABLE v8users RENAME TO v8users_old;
UPDATE Params SET FileName = 'users.usr_old' WHERE FileName = 'users.usr';

-- Открыть конфигуратор

-- 2 запрос
DROP TABLE v8users;
ALTER TABLE v8users_old RENAME TO v8users;
UPDATE Params SET FileName = 'users.usr' WHERE FileName = 'users.usr_old';
