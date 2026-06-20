-- ============================================================
-- БАЗА ДАННЫХ: Hospital (Больница)
-- С ПРОВЕРКОЙ НА СУЩЕСТВОВАНИЕ
-- ============================================================

USE Hospital;
GO

-- ============================================================
-- 1. УДАЛЕНИЕ СУЩЕСТВУЮЩИХ ТАБЛИЦ (если есть)
-- ============================================================

DROP TABLE IF EXISTS DoctorsExaminations;
DROP TABLE IF EXISTS Donations;
DROP TABLE IF EXISTS Wards;
DROP TABLE IF EXISTS Examinations;
DROP TABLE IF EXISTS Doctors;
DROP TABLE IF EXISTS Sponsors;
DROP TABLE IF EXISTS Departments;
GO

-- ============================================================
-- 2. СОЗДАНИЕ ТАБЛИЦ
-- ============================================================

-- Таблица 1: Отделения (Departments)
CREATE TABLE Departments (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> '')
);
GO

-- Таблица 2: Врачи (Doctors)
CREATE TABLE Doctors (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Surname NVARCHAR(50) NOT NULL CHECK (Surname <> ''),
    Name NVARCHAR(50) NOT NULL CHECK (Name <> ''),
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Premium MONEY NOT NULL CHECK (Premium >= 0) DEFAULT 0
);
GO

-- Таблица 3: Обследования (Examinations)
CREATE TABLE Examinations (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> '')
);
GO

-- Таблица 4: Палаты (Wards)
CREATE TABLE Wards (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(20) NOT NULL UNIQUE CHECK (Name <> ''),
    Places INT NOT NULL CHECK (Places >= 1),
    DepartmentId INT NOT NULL,
    CONSTRAINT FK_Wards_Departments FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);
GO

-- Таблица 5: Спонсоры (Sponsors)
CREATE TABLE Sponsors (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> '')
);
GO

-- Таблица 6: Пожертвования (Donations)
CREATE TABLE Donations (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Amount MONEY NOT NULL CHECK (Amount > 0),
    Date DATE NOT NULL DEFAULT GETDATE() CHECK (Date <= GETDATE()),
    DepartmentId INT NOT NULL,
    SponsorId INT NOT NULL,
    CONSTRAINT FK_Donations_Departments FOREIGN KEY (DepartmentId) REFERENCES Departments(Id),
    CONSTRAINT FK_Donations_Sponsors FOREIGN KEY (SponsorId) REFERENCES Sponsors(Id)
);
GO

-- Таблица 7: Врачи и обследования (DoctorsExaminations)
CREATE TABLE DoctorsExaminations (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    DoctorId INT NOT NULL,
    ExaminationId INT NOT NULL,
    WardId INT NOT NULL,
    CONSTRAINT FK_DoctorsExaminations_Doctors FOREIGN KEY (DoctorId) REFERENCES Doctors(Id),
    CONSTRAINT FK_DoctorsExaminations_Examinations FOREIGN KEY (ExaminationId) REFERENCES Examinations(Id),
    CONSTRAINT FK_DoctorsExaminations_Wards FOREIGN KEY (WardId) REFERENCES Wards(Id),
    CONSTRAINT CHK_StartTime CHECK (StartTime BETWEEN '08:00' AND '18:00'),
    CONSTRAINT CHK_EndTime CHECK (EndTime > StartTime AND EndTime <= '18:00')
);
GO

-- ============================================================
-- 3. ЗАПОЛНЕНИЕ ТАБЛИЦ ТЕСТОВЫМИ ДАННЫМИ
-- ============================================================

-- Отделения
INSERT INTO Departments (Building, Name) VALUES
(1, 'Кардиология'),
(1, 'Неврология'),
(2, 'Терапия'),
(2, 'Хирургия'),
(3, 'Педиатрия');
GO

-- Врачи
INSERT INTO Doctors (Surname, Name, Salary, Premium) VALUES
('Иванов', 'Иван', 50000, 10000),
('Петрова', 'Мария', 60000, 15000),
('Сидоров', 'Петр', 45000, 5000),
('Козлова', 'Анна', 70000, 20000),
('Смирнов', 'Алексей', 55000, 8000);
GO

-- Обследования
INSERT INTO Examinations (Name) VALUES
('ЭКГ'),
('МРТ'),
('УЗИ'),
('Анализ крови'),
('Рентген');
GO

-- Палаты
INSERT INTO Wards (Name, Places, DepartmentId) VALUES
('101', 4, 1),
('102', 2, 1),
('201', 3, 2),
('202', 4, 2),
('301', 2, 3),
('401', 4, 4),
('501', 3, 5);
GO

-- Спонсоры
INSERT INTO Sponsors (Name) VALUES
('Фонд Здоровье'),
('Медицинский центр'),
('Благотворительный фонд'),
('Корпорация Медика');
GO

-- Пожертвования
INSERT INTO Donations (Amount, Date, DepartmentId, SponsorId) VALUES
(10000, '2024-01-15', 1, 1),
(25000, '2024-02-20', 2, 2),
(15000, '2024-03-10', 3, 1),
(30000, '2024-04-05', 4, 3),
(20000, '2024-05-12', 5, 4),
(5000, '2024-06-18', 1, 2);
GO

-- Врачи и обследования
INSERT INTO DoctorsExaminations (StartTime, EndTime, DoctorId, ExaminationId, WardId) VALUES
('09:00', '10:00', 1, 1, 1),
('10:00', '11:30', 2, 2, 2),
('11:00', '12:00', 3, 3, 3),
('13:00', '14:30', 4, 4, 4),
('14:00', '15:00', 5, 5, 5),
('15:00', '16:00', 1, 2, 6),
('16:00', '17:00', 2, 3, 7);
GO

-- ============================================================
-- 4. ПРОВЕРКА ДАННЫХ (TOP 1000)
-- ============================================================

SELECT TOP 1000 * FROM Departments;
SELECT TOP 1000 * FROM Doctors;
SELECT TOP 1000 * FROM Examinations;
SELECT TOP 1000 * FROM Wards;
SELECT TOP 1000 * FROM Sponsors;
SELECT TOP 1000 * FROM Donations;
SELECT TOP 1000 * FROM DoctorsExaminations;
GO

-- ============================================================
-- 5. ЗАПРОСЫ С ДВУМЯ И БОЛЕЕ ТАБЛИЦАМИ
-- ============================================================

-- Запрос 1: Информация о врачах и их обследованиях
SELECT 
    d.Surname + ' ' + d.Name AS Врач,
    e.Name AS Обследование,
    de.StartTime AS Начало,
    de.EndTime AS Конец,
    w.Name AS Палата,
    dep.Name AS Отделение
FROM DoctorsExaminations de
JOIN Doctors d ON de.DoctorId = d.Id
JOIN Examinations e ON de.ExaminationId = e.Id
JOIN Wards w ON de.WardId = w.Id
JOIN Departments dep ON w.DepartmentId = dep.Id
ORDER BY de.StartTime;
GO

-- Запрос 2: Количество обследований по врачам
SELECT 
    d.Surname + ' ' + d.Name AS Врач,
    COUNT(de.Id) AS Количество_обследований
FROM Doctors d
LEFT JOIN DoctorsExaminations de ON d.Id = de.DoctorId
GROUP BY d.Surname, d.Name
ORDER BY Количество_обследований DESC;
GO

-- Запрос 3: Пожертвования по отделениям
SELECT 
    dep.Name AS Отделение,
    COUNT(don.Id) AS Количество_пожертвований,
    SUM(don.Amount) AS Общая_сумма
FROM Donations don
JOIN Departments dep ON don.DepartmentId = dep.Id
GROUP BY dep.Name
ORDER BY Общая_сумма DESC;
GO

-- Запрос 4: Спонсоры и их пожертвования
SELECT 
    s.Name AS Спонсор,
    COUNT(don.Id) AS Количество_пожертвований,
    SUM(don.Amount) AS Общая_сумма,
    AVG(don.Amount) AS Средняя_сумма
FROM Sponsors s
JOIN Donations don ON s.Id = don.SponsorId
GROUP BY s.Name
ORDER BY Общая_сумма DESC;
GO

-- Запрос 5: Врачи с зарплатой выше средней
SELECT 
    d.Surname + ' ' + d.Name AS Врач,
    d.Salary AS Зарплата
FROM Doctors d
WHERE d.Salary > (SELECT AVG(Salary) FROM Doctors)
ORDER BY d.Salary DESC;
GO