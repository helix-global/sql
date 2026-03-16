--KB5029: Initial Update.
CREATE function [dbo].[PR_MTYPES_4_BOMITEM_OPT](@BomID int, @Options nvarchar(max))
returns @OutT table([TYPEID] int primary key clustered)
as
begin
  insert into @OutT ([TYPEID])
    select distinct [a].[BOMMTID]
    from [dbo].[PR_MODELTYPE_BOM] [a] with(nolock)
    where [a].[ID] = @BomID
      and [a].[BOMMTID] is not null

  merge @OutT [a]
  using
    (
    select distinct [a].[BOMMTID]
    from [dbo].[PR_MODELTYPE_BOM_T] [a] with(nolock)
    where [a].[VNESHID] = @BomID
    ) [b] on [b].[BOMMTID]=[a].[TYPEID]
  when not matched then
    insert ([TYPEID]) values ([b].[BOMMTID]);

  declare @OptionsT table([OPTION] nvarchar(max))
  insert into @OptionsT
    select [a].[OPTION]
    from [dbo].[COM_OPT_SPLIT](@Options) [a]

  if @BomID > 0 and exists (select * from @OptionsT [a] where [a].[OPTION]=N'IncludeAllModelTypes')
  begin
    merge @OutT [a]
    using
      (
      select ID from [dbo].[PR_MODELTYPE] [a] with(nolock)
      ) [b] on [b].[ID]=[a].[TYPEID]
    when not matched then
      insert ([TYPEID]) values ([b].[ID]);
  end
  return
end