


--KB5144:2024-12-05: Added link to "IT_TASK_REL_UNI".
--KB4881:2024-10-11: Added link to "IT_TASK_REL_INT".
--KB4881:2024-09-27: Added link to "IT_TASK_REL_ENU".
--KB4881:2024-08-14: Initial update.
CREATE view [dbo].[IT_TASK_REL_OBJ]
AS
with [T]
  as
  (
  select
      [a].[ID]      [TASKID]
     ,[b].[RELOID]  [RELOID]
     ,[c].[ID]      [RELID]
     ,N'def_sql'    [CLASS]
     ,N'Query'      [TYPE]
     ,[c].[LABEL]   [LABEL]
     ,[c].[NAME]    [NAME]
     ,coalesce([b].[DT],[b].[S_CDT],[b].[S_MDT]) [DT]
     ,[b].[COMMENT] [COMMENT]
  from [dbo].[IT_TASKS] [a] with(nolock)
    inner join [dbo].[IT_TASK_REL_SQL] [b] with(nolock) on [b].[TASKID]=[a].[ID]
    inner join [dbo].[DEF_SQL]         [c] with(nolock) on [c].[OID]=[b].[RELOID]
  union all
  select
      [a].[ID]       [TASKID]
     ,[b].[RELOID]   [RELOID]
     ,[c].[ID]       [RELID]
     ,N'def_reports' [CLASS]
     ,N'Report'      [TYPE]
     ,[c].[LABEL]    [LABEL]
     ,[c].[NAME]     [NAME]
     ,coalesce([b].[DT],[b].[S_CDT],[b].[S_MDT]) [DT]
     ,[b].[COMMENT]  [COMMENT]
  from [dbo].[IT_TASKS] [a] with(nolock)
    inner join [dbo].[IT_TASK_REL_REP] [b] with(nolock) on [b].[TASKID]=[a].[ID]
    inner join [dbo].[DEF_REPORTS]     [c] with(nolock) on [c].[OID]=[b].[RELOID]
  union all
  select
      [a].[ID]       [TASKID]
     ,[b].[RELOID]   [RELOID]
     ,[c].[ID]       [RELID]
     ,N'def_meta'    [CLASS]
     ,[dbo].[DEF_ENUM_V](null,N'def_meta_type',[c].[MTYPE]) [TYPE]
     ,[c].[NAME]     [LABEL]
     ,[c].[NAME]     [NAME]
     ,coalesce([b].[DT],[b].[S_CDT],[b].[S_MDT]) [DT]
     ,[b].[COMMENT]  [COMMENT]
  from [dbo].[IT_TASKS] [a] with(nolock)
    inner join [dbo].[IT_TASK_REL_MET] [b] with(nolock) on [b].[TASKID]=[a].[ID]
    inner join [dbo].[DEF_META]        [c] with(nolock) on [c].[OID]=[b].[RELOID]
  union all
  select
      [a].[ID]       [TASKID]
     ,[b].[RELOID]   [RELOID]
     ,[c].[ID]       [RELID]
     ,N'def_classes' [CLASS]
     ,N'Class'       [TYPE]
     ,[c].[LABEL]    [LABEL]
     ,[c].[NAME]     [NAME]
     ,coalesce([b].[DT],[b].[S_CDT],[b].[S_MDT]) [DT]
     ,[b].[COMMENT]  [COMMENT]
  from [dbo].[IT_TASKS] [a] with(nolock)
    inner join [dbo].[IT_TASK_REL_CLA] [b] with(nolock) on [b].[TASKID]=[a].[ID]
    inner join [dbo].[DEF_CLASSES]     [c] with(nolock) on [c].[OID]=[b].[RELOID]
  union all
  select
      [a].[ID]       [TASKID]
     ,[b].[RELOID]   [RELOID]
     ,[c].[ID]       [RELID]
     ,N'def_entity'  [CLASS]
     ,N'Entity'      [TYPE]
     ,[c].[LABEL]    [LABEL]
     ,[c].[NAME]     [NAME]
     ,coalesce([b].[DT],[b].[S_CDT],[b].[S_MDT]) [DT]
     ,[b].[COMMENT]  [COMMENT]
  from [dbo].[IT_TASKS] [a] with(nolock)
    inner join [dbo].[IT_TASK_REL_ENT] [b] with(nolock) on [b].[TASKID]=[a].[ID]
    inner join [dbo].[DEF_ENTITY]      [c] with(nolock) on [c].[OID]=[b].[RELOID]
  union all
  select
      [a].[ID]       [TASKID]
     ,[b].[RELOID]   [RELOID]
     ,[c].[ID]       [RELID]
     ,N'def_stages'  [CLASS]
     ,N'Stage'       [TYPE]
     ,[c].[LABEL]    [LABEL]
     ,[c].[NAME]     [NAME]
     ,coalesce([b].[DT],[b].[S_CDT],[b].[S_MDT]) [DT]
     ,[b].[COMMENT]  [COMMENT]
  from [dbo].[IT_TASKS] [a] with(nolock)
    inner join [dbo].[IT_TASK_REL_STA] [b] with(nolock) on [b].[TASKID]=[a].[ID]
    inner join [dbo].[DEF_STAGES]      [c] with(nolock) on [c].[OID]=[b].[RELOID]
  union all
  select
      [a].[ID]       [TASKID]
     ,[b].[RELOID]   [RELOID]
     ,[c].[ID]       [RELID]
     ,N'def_view'    [CLASS]
     ,N'View'        [TYPE]
     ,[c].[LABEL]    [LABEL]
     ,[c].[NAME]     [NAME]
     ,coalesce([b].[DT],[b].[S_CDT],[b].[S_MDT]) [DT]
     ,[b].[COMMENT]  [COMMENT]
  from [dbo].[IT_TASKS] [a] with(nolock)
    inner join [dbo].[IT_TASK_REL_VIE] [b] with(nolock) on [b].[TASKID]=[a].[ID]
    inner join [dbo].[DEF_VIEWS]       [c] with(nolock) on [c].[OID]=[b].[RELOID]
  union all
  select
      [a].[ID]       [TASKID]
     ,[b].[RELOID]   [RELOID]
     ,[c].[ID]       [RELID]
     ,N'def_enumeration'    [CLASS]
     ,N'Enum'        [TYPE]
     ,[c].[LABEL]    [LABEL]
     ,[c].[NAME]     [NAME]
     ,coalesce([b].[DT],[b].[S_CDT],[b].[S_MDT]) [DT]
     ,[b].[COMMENT]  [COMMENT]
  from [dbo].[IT_TASKS] [a] with(nolock)
    inner join [dbo].[IT_TASK_REL_ENU] [b] with(nolock) on [b].[TASKID]=[a].[ID]
    inner join [dbo].[DEF_ENUMERATION] [c] with(nolock) on [c].[OID]=[b].[RELOID]
  union all
  select
      [a].[ID]         [TASKID]
     ,[b].[RELOID]     [RELOID]
     ,[c].[ID]         [RELID]
     ,N'def_interface' [CLASS]
     ,N'Interface'     [TYPE]
     ,[c].[LABEL]      [LABEL]
     ,[c].[NAME]       [NAME]
     ,coalesce([b].[DT],[b].[S_CDT],[b].[S_MDT]) [DT]
     ,[b].[COMMENT]  [COMMENT]
  from [dbo].[IT_TASKS] [a] with(nolock)
    inner join [dbo].[IT_TASK_REL_INT] [b] with(nolock) on [b].[TASKID]=[a].[ID]
    inner join [dbo].[DEF_INTERFACE]   [c] with(nolock) on [c].[OID]=[b].[RELOID]
  union all
  select
      [a].[ID]         [TASKID]
     ,[b].[RELOID]     [RELOID]
     ,[c].[ID]         [RELID]
     ,N'def_unit'      [CLASS]
     ,N'Unit'          [TYPE]
     ,[c].[LABEL]      [LABEL]
     ,[c].[NAME]       [NAME]
     ,coalesce([b].[DT],[b].[S_CDT],[b].[S_MDT]) [DT]
     ,[b].[COMMENT]  [COMMENT]
  from [dbo].[IT_TASKS] [a] with(nolock)
    inner join [dbo].[IT_TASK_REL_UNI] [b] with(nolock) on [b].[TASKID]=[a].[ID]
    inner join [dbo].[DEF_UNIT]        [c] with(nolock) on [c].[OID]=[b].[RELOID]
  )
select
   row_number() over (order by [a].[RELOID],[a].[RELID]) [ID]
  ,[a].[TASKID]
  ,[a].[RELOID]
  ,[a].[RELID]
  ,[a].[CLASS]
  ,[a].[TYPE]
  ,[a].[LABEL]
  ,[a].[NAME]
  ,[a].[DT]
  ,[a].[COMMENT]
from [T] [a]