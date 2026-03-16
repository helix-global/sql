-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-10-28
-- Description: Alternative version of [dbo].[PR_BOM_HAS_AVAILABLE_BOMANDPARAMS] function with optional parameter.
-- =============================================
-- KB5029:2024-10-28: Initial update.
CREATE function [dbo].[PR_BOM_HAS_AVAILABLE_BOMANDPARAMS_OPT](@BomID int,@aMode int, @UserID int,@Options nvarchar(max))
returns int as
begin
  declare @ChildModelTypesT table ([ID] int,primary key clustered ([ID]))
  insert into @ChildModelTypesT ([ID])
    select distinct [ID]
    from [dbo].[PR_MTYPES_4_BOMITEM](@BomID,0)

  if exists (select [N].[ID]
             from [dbo].[PR_MODELTYPE_BOM] [N] with(nolock)
             where [N].[MTID] in (select [ID] from @ChildModelTypesT)
               and [N].[SHAREBOM] = 1
            )
  begin
    return 1
  end

  declare @OptionsT table([OPTION] nvarchar(max))
  insert into @OptionsT
    select [a].[OPTION]
    from [dbo].[COM_OPT_SPLIT](@Options) [a]

  if exists(select * from @OptionsT [a] where [a].[OPTION] like N'DataType=%')
  begin
    declare @DataTypeT table([DATATYPE] int,primary key clustered ([DATATYPE]))
    insert @DataTypeT
      select distinct [a].[ID]
      from [dbo].[COM_STR2TABLE_INT]((select top 1 right([o].[OPTION],len([o].[OPTION])-9)
                                     from @OptionsT [o] where [o].[OPTION] like N'DataType=%')) [a]
    if exists (select [D].[ID]
               from [dbo].[PR_MODELTYPE_PARAMS] [D] with(nolock)
                 left join [dbo].[PR_MODELTYPE_PARAMS_GR] [FG] with(nolock) on [FG].[ID] = [D].[PGROUP]
               where [D].[TYPEID] in (select [ID] from @ChildModelTypesT)
                 and [D].[DATATYPE] in (select [DATATYPE] from @DataTypeT)
                 and ([D].[SHAREPRM] = 1 or [dbo].[COM_DEP_ACCESS2]([FG].[DEPID],@aMode,@UserID,getdate()) = 1)
                 )
    begin
      return 1
    end
    return 0
  end

  if exists (select [D].[ID]
             from [dbo].[PR_MODELTYPE_PARAMS] [D] with(nolock)
               left join [dbo].[PR_MODELTYPE_PARAMS_GR] [FG] with(nolock) on [FG].[ID] = [D].[PGROUP]
             where [D].[TYPEID] in (select [ID] from @ChildModelTypesT)
               and ([D].[SHAREPRM] = 1 or [dbo].[COM_DEP_ACCESS2]([FG].[DEPID],@aMode,@UserID,getdate()) = 1)
             )
  begin
    return 1
  end
   return 0
end