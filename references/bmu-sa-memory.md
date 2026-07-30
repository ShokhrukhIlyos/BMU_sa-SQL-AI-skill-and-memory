# BMU_sa verified memory

This file contains only facts confirmed by user-provided, working SQL. Expand it when additional schema details and business rules are verified.

## Platform and schema

- SQL dialect: Microsoft SQL Server / T-SQL.
- Application schema: `BMU_sa`.

## Verified tables and relationships

| Table | Alias | Verified relationship or role |
| --- | --- | --- |
| `BMU_sa.Students` | `s` | Student record keyed by `StudentID`; exposes `YearOfStudy` and `StatusID`. |
| `BMU_sa.Grants` | `g` | Grant record joined to students through `StudentID`; exposes `IsConfirmed`, `AcademicYearID`, `Percentage`, and `Type`. |
| `BMU_sa.StudentProgramEnrolments` | `spe` | Student-program link joined through `StudentID`; exposes `ProgramID` and `StatusID`. |
| `BMU_sa.Programs` | `p` | Programme record joined from `spe.ProgramID`; exposes `ProgramTypeID`. |
| `BMU_sa.ProgramTypes` | `pt` | Programme-type lookup joined through `ProgramTypeID`; exposes `ProgramTypeName`. |

## Rules confirmed by the StudentList grant-statistics query

- The report population comes exclusively from the supplied `StudentList` CTE.
- No `Students.StatusID` filter is applied in the revised report.
- `spe.StatusID = 1` selects the active programme enrolment.
- `spe.ProgramID <> 18` excludes Programme 18.
- `g.IsConfirmed = 1` selects confirmed grants.
- `g.AcademicYearID = 6` limits the report to Academic Year 6.
- `g.Percentage <> 'FIX'` excludes fixed-amount grants.
- A listed student with any confirmed, non-`FIX` grant in Academic Year 6 is excluded from the `No Grant` group.
- The result groups students by `YearOfStudy`, grant percentage/type, and `ProgramTypeName`.
- `COUNT(DISTINCT es.StudentID)` prevents a student from being counted more than once inside a result group.
- The verified input contained 1,276 unique StudentIDs, and the report totals also equalled 1,276.

## Important scope warning

Do not assume numeric IDs have the same meaning in every report. Preserve them for this verified query, but ask for confirmation before reusing or changing them in a different business context.

The repository is public. Never commit a real StudentID population list. Keep only a placeholder in the reusable SQL and supply the approved list at runtime.

## Safety rules

- Prefer `SELECT` statements.
- Do not generate a write query from incomplete schema memory.
- Before changing data, create a matching verification `SELECT`, define the exact affected rows, and recommend a transaction.
- Never store credentials, connection strings, production exports, or personally identifiable student data in this repository.
