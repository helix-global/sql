
-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2025-03-18
-- Description: Serialize [SqlTypeSpecifier] into xml.
-- =============================================
-- KB5302:2025-03-18: Initial Update.
CREATE function [dbo].[Serialize_SqlTypeSpecifier](@ObjectID int,@ColumnID int)
returns xml
as
begin
  declare @Out xml
  if @ObjectID is not null and @ColumnID is not null
  begin
    declare @Length int
    declare @Precision int
    declare @Scale int
    declare @SystemTypeID int
    declare @TypeName nvarchar(max)
    declare @IsTableType int
    declare @IsUserDefined int
    declare @UserTypeID int
    declare @IsBuiltInType int=0
    declare @PropT table([PropertyName] nvarchar(max),[PropertyValue] nvarchar(max))

    select
       @Length=[a].[max_length]
      ,@Precision=[a].[precision]
      ,@Scale=[a].[scale]
      ,@SystemTypeID=[a].[system_type_id]
      ,@UserTypeID=[a].[user_type_id]
      ,@TypeName=[b].[name]
      ,@IsTableType=[b].[is_table_type]
      ,@IsUserDefined=[b].[is_user_defined]
    from sys.columns [a] with(nolock)
      left join sys.types [b] with(nolock) on [b].[system_type_id]=[a].[system_type_id] and [b].[user_type_id]=[a].[user_type_id]
    where [a].[object_id]=@ObjectID
      and [a].[column_id]=@ColumnID

    if @TypeName in ('nchar','nvarchar','char','varchar','binary','varbinary')
    begin
      if @Length=-1
      begin
        insert into @PropT ([PropertyName],[PropertyValue]) values ('IsMax','True')
      end else
      begin
        if @TypeName in ('nchar','nvarchar')
        begin
          set @Length=@Length/2
        end
        insert into @PropT ([PropertyName],[PropertyValue]) values ('Length',cast(@Length as nvarchar(max)))
      end
    end
    if exists(select * from sys.systypes [a] where [a].[xtype]=@SystemTypeID and [a].[xusertype]=@UserTypeID)
    begin
      set @IsBuiltInType=1
    end

    if @IsBuiltInType=1
    begin
      set @Out=(
        select
          'SqlTypeSpecifier' [@Type]
          ,(select
               [props].[PropertyName]  [@Property]
              ,[props].[PropertyValue] [@Value]
            from @PropT [props]
            for xml path('Property'),type)
          ,'Type'            [Relationship/@Name]
          ,'BuiltIns'        [Relationship/Entry/References/@ExternalSource]
          ,'['+@TypeName+']' [Relationship/Entry/References/@Name]
        for xml path('Element'),type,elements)
    end
  end
  return @Out
end