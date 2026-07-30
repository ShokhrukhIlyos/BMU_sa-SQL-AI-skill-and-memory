/*
Purpose:
  Count only students supplied through StudentList, grouped by year of study,
  grant percentage/type, and programme type.

Verified report scope:
  - Student population comes exclusively from StudentList
  - No Students.StatusID filter is applied
  - Active programme enrolment: spe.StatusID = 1
  - Excluded programme: spe.ProgramID = 18
  - Confirmed grants from AcademicYearID = 6
  - Excluded grant percentage: FIX

Privacy:
  Do not commit the real StudentID list to a public repository.
*/

;WITH StudentList (StudentID) AS
(
    -- Insert the approved StudentIDs at runtime.
    -- Example:
    SELECT v.StudentID
    FROM
    (
        VALUES
            ('example-student-id')
    ) AS v(StudentID)
),
EligibleStudents AS
(
    SELECT DISTINCT
        sl.StudentID,
        s.YearOfStudy,
        pt.ProgramTypeName
    FROM StudentList AS sl
    INNER JOIN BMU_sa.Students AS s
        ON s.StudentID = sl.StudentID
    INNER JOIN BMU_sa.StudentProgramEnrolments AS spe
        ON spe.StudentID = sl.StudentID
       AND spe.StatusID = 1
       AND spe.ProgramID <> 18
    INNER JOIN BMU_sa.Programs AS p
        ON p.ProgramID = spe.ProgramID
    INNER JOIN BMU_sa.ProgramTypes AS pt
        ON pt.ProgramTypeID = p.ProgramTypeID
),
StudentWithGrants AS
(
    SELECT DISTINCT
        es.StudentID
    FROM EligibleStudents AS es
    INNER JOIN BMU_sa.Grants AS g
        ON g.StudentID = es.StudentID
       AND g.IsConfirmed = 1
       AND g.AcademicYearID = 6
       AND g.Percentage <> 'FIX'
)
-- Students with grants
SELECT
    es.YearOfStudy,
    CAST(g.Percentage AS varchar(50)) AS Percentage,
    g.[Type],
    es.ProgramTypeName,
    COUNT(DISTINCT es.StudentID) AS NumberOfStudents
FROM EligibleStudents AS es
INNER JOIN BMU_sa.Grants AS g
    ON g.StudentID = es.StudentID
   AND g.IsConfirmed = 1
   AND g.AcademicYearID = 6
   AND g.Percentage <> 'FIX'
GROUP BY
    es.YearOfStudy,
    g.Percentage,
    g.[Type],
    es.ProgramTypeName

UNION ALL

-- Students without grants
SELECT
    es.YearOfStudy,
    'No Grant' AS Percentage,
    'No Grant' AS [Type],
    es.ProgramTypeName,
    COUNT(DISTINCT es.StudentID) AS NumberOfStudents
FROM EligibleStudents AS es
WHERE NOT EXISTS
(
    SELECT 1
    FROM StudentWithGrants AS swg
    WHERE swg.StudentID = es.StudentID
)
GROUP BY
    es.YearOfStudy,
    es.ProgramTypeName
ORDER BY
    YearOfStudy,
    ProgramTypeName,
    Percentage,
    [Type];
