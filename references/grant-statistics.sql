/*
Purpose:
  Count students with and without confirmed grants by year of study,
  grant percentage/type, and programme type.

Verified report scope:
  - AcademicYearID = 6
  - Student StatusID IN (1, 12)
  - Active programme enrolment: spe.StatusID = 1
  - Excluded programme: spe.ProgramID = 18
  - Excluded grant percentage: FIX
*/

WITH StudentWithGrants AS
(
    SELECT DISTINCT
        g.StudentID
    FROM BMU_sa.Grants AS g
    INNER JOIN BMU_sa.Students AS s
        ON s.StudentID = g.StudentID
    WHERE g.IsConfirmed = 1
      AND g.AcademicYearID = 6
      AND s.StatusID IN (1, 12)
      AND g.Percentage <> 'FIX'
)
-- Students with grants
SELECT
    s.YearOfStudy,
    CAST(g.Percentage AS varchar(50)) AS Percentage,
    g.[Type],
    pt.ProgramTypeName,
    COUNT(DISTINCT s.StudentID) AS NumberOfStudents
FROM BMU_sa.Grants AS g
INNER JOIN BMU_sa.Students AS s
    ON s.StudentID = g.StudentID
INNER JOIN BMU_sa.StudentProgramEnrolments AS spe
    ON spe.StudentID = s.StudentID
INNER JOIN BMU_sa.Programs AS p
    ON p.ProgramID = spe.ProgramID
INNER JOIN BMU_sa.ProgramTypes AS pt
    ON pt.ProgramTypeID = p.ProgramTypeID
WHERE g.IsConfirmed = 1
  AND g.AcademicYearID = 6
  AND s.StatusID IN (1, 12)
  AND g.Percentage <> 'FIX'
  AND spe.StatusID = 1
  AND spe.ProgramID <> 18
GROUP BY
    s.YearOfStudy,
    g.Percentage,
    g.[Type],
    pt.ProgramTypeName

UNION ALL

-- Students without grants
SELECT
    s.YearOfStudy,
    'No Grant' AS Percentage,
    'No Grant' AS [Type],
    pt.ProgramTypeName,
    COUNT(DISTINCT s.StudentID) AS NumberOfStudents
FROM BMU_sa.Students AS s
INNER JOIN BMU_sa.StudentProgramEnrolments AS spe
    ON spe.StudentID = s.StudentID
INNER JOIN BMU_sa.Programs AS p
    ON p.ProgramID = spe.ProgramID
INNER JOIN BMU_sa.ProgramTypes AS pt
    ON pt.ProgramTypeID = p.ProgramTypeID
WHERE s.StatusID IN (1, 12)
  AND spe.StatusID = 1
  AND spe.ProgramID <> 18
  AND NOT EXISTS
  (
      SELECT 1
      FROM StudentWithGrants AS swg
      WHERE swg.StudentID = s.StudentID
  )
GROUP BY
    s.YearOfStudy,
    pt.ProgramTypeName
ORDER BY
    YearOfStudy,
    ProgramTypeName,
    Percentage,
    [Type];
