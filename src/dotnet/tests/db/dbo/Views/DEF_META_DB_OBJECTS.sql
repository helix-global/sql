
--KB5314:2025-03-24: Added [SCHEMA] field.
CREATE view [dbo].[DEF_META_DB_OBJECTS] as
  select
     [a].[OID]
    ,[a].[NAME]
    ,[a].[S_CR]
    ,[a].[S_MR]
    ,[a].[S_CDT]
    ,[a].[S_MDT]
    ,[a].[MTYPE]
    ,[a].[TABLENAME]
    ,[a].[SCHEMA]
  from [dbo].[DEF_META_DB_OBJECTS_CORE](null) [a]