---
name: bmu-sa-sql
description: Generate, review, explain, and improve Microsoft SQL Server queries for the BMU_sa database using verified schema memory and business rules. Use for BMU_sa student, grant, programme, enrolment, assessment, contract, order, and institutional-reporting SQL tasks, especially when joins, active-status filters, academic-year rules, or safe query construction must be applied.
---

# BMU_sa SQL

## Workflow

1. Read [references/bmu-sa-memory.md](references/bmu-sa-memory.md) for known tables, relationships, and business rules.
2. Read [references/grant-statistics.sql](references/grant-statistics.sql) when working with grant or no-grant statistics.
3. Restate the reporting scope: academic year, student statuses, enrolment status, excluded programmes, grant confirmation, and output grouping.
4. Generate Microsoft SQL Server syntax using explicit joins and qualified column names.
5. Default to read-only SQL unless the user explicitly requests a data modification.
6. Before any INSERT, UPDATE, or DELETE, identify the exact target rows with a SELECT and call out transaction and backup requirements.
7. Never invent unknown table names, columns, status meanings, or relationships. Ask for the schema or a verified example when memory is incomplete.
8. Never include credentials, connection strings, student personal data, or production exports in generated repository content.

## Query quality checks

- Prevent duplicate counts caused by one-to-many joins.
- Use `COUNT(DISTINCT StudentID)` when the reporting unit is a student.
- Keep active student and active programme-enrolment filters explicit.
- Make academic-year and excluded-programme values easy to identify.
- Use `NOT EXISTS` for the verified no-grant exclusion pattern.
- Explain assumptions and parameterize variable values when practical.
