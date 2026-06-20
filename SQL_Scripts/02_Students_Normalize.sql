-- ============================================================
-- БАЗА ДАННЫХ: Students (Нормализация)
-- ============================================================

USE Academy;
GO

-- ============================================================
-- 1. ПРОВЕРКА ТЕКУЩЕЙ СТРУКТУРЫ
-- ============================================================

-- Таблица Students имеет столбцы: id, LastName, FirstName, BirthDate, Grants, Email, GroupId
-- Таблица Groups: id, GroupName, FacultyID

-- ============================================================
-- 2. ПРИВЕДЕНИЕ К 3НФ
-- ============================================================

-- 1НФ: Все поля атомарны (уже соблюдено)
-- 2НФ: Выносим GroupName в отдельную таблицу (уже есть Groups)
-- 3НФ: Выносим Faculty в отдельную таблицу

-- Создаём таблицу "Факультеты"
CREATE TABLE Факультеты (
    ФакультетID INT IDENTITY(1,1) PRIMARY KEY,
    НазваниеФакультета NVARCHAR(100) NOT NULL UNIQUE
);
GO

-- Добавляем FacultyID в Groups (если ещё нет)
-- ALTER TABLE Groups ADD ФакультетID INT NULL;
-- GO

-- Создаём связь с Факультетами
-- ALTER TABLE Groups ADD CONSTRAINT FK_Groups_Факультеты FOREIGN KEY (ФакультетID) REFERENCES Факультеты(ФакультетID);
-- GO

-- ============================================================
-- 3. ЗАПРОСЫ С ДВУМЯ И БОЛЕЕ ТАБЛИЦАМИ
-- ============================================================

-- Запрос 1: Студенты с названиями групп и факультетов
SELECT
    s.LastName + ' ' + s.FirstName AS Студент,
    g.GroupName AS Группа,
    f.НазваниеФакультета AS Факультет,
    s.Email,
    s.Grants AS Стипендия
FROM Students s
JOIN Groups g ON s.GroupId = g.id
LEFT JOIN Факультеты f ON g.ФакультетID = f.ФакультетID;
GO

-- Запрос 2: Количество студентов по группам
SELECT
    g.GroupName AS Группа,
    COUNT(*) AS Количество_студентов
FROM Students s
JOIN Groups g ON s.GroupId = g.id
GROUP BY g.GroupName
ORDER BY Количество_студентов DESC;
GO

-- Запрос 3: Студенты и их оценки (из Achievements)
SELECT
    s.LastName + ' ' + s.FirstName AS Студент,
    sub.SubjectName AS Предмет,
    a.Assesment AS Оценка
FROM Students s
JOIN Achievements a ON s.id = a.StudentId
JOIN Subjects sub ON a.SubjectId = sub.id
ORDER BY Студент, Предмет;
GO

-- Запрос 4: Средний балл по группам
SELECT
    g.GroupName AS Группа,
    AVG(a.Assesment) AS Средний_балл
FROM Students s
JOIN Groups g ON s.GroupId = g.id
JOIN Achievements a ON s.id = a.StudentId
GROUP BY g.GroupName
ORDER BY Средний_балл DESC;
GO

-- Запрос 5: Студенты с минимальной и максимальной оценкой
SELECT
    s.LastName + ' ' + s.FirstName AS Студент,
    g.GroupName AS Группа,
    MIN(a.Assesment) AS Минимальная_оценка,
    MAX(a.Assesment) AS Максимальная_оценка
FROM Students s
JOIN Groups g ON s.GroupId = g.id
JOIN Achievements a ON s.id = a.StudentId
GROUP BY s.LastName, s.FirstName, g.GroupName
ORDER BY Минимальная_оценка;
GO