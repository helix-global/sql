-- KB4934: Initial Update.
CREATE function [dbo].[DEF_CHECK_ENV_ACCESS4](@UserID int,@Date datetime, @Type int,@ClassOID int,@ReportOID int,@OperationOID int,@ViewOID int,@UnitOID int)
returns int as 
begin
  declare @res int
  if @Type = 1 /*report*/
  begin
    select
      @res = [dbo].[DEF_F_ACCESS](A.ARC,null,11,@Date,@UserID,0)
    from [dbo].[DEF_REPORTS] A with(nolock)
    where A.OID = @ReportOID
    return @res
  end
  else if @Type = 2 /*context list*/
  begin
    select
      @res = [dbo].[DEF_F_ACCESS](A.ARC,null,2,@Date,@UserID,0)
    from [dbo].[DEF_CLASSES] A with(nolock)
    where A.OID = @ClassOID
    return @res
  end
  else if @Type = 3 /*context add document*/
  begin
    select
      @res = [dbo].[DEF_F_ACCESS](A.ARC,null,6,@Date,@UserID,0)
    from [dbo].[DEF_CLASSES] A with(nolock)
    where A.OID = @ClassOID
    return @res
  end
  else if (@Type in (4,7,12,10)) /*operation*/
  begin
    if @OperationOID is not null
    begin
      select
        @res = [dbo].[DEF_F_ACCESS](A.ARC,null,99,@Date,@UserID,0)
      from [dbo].[DEF_OPERATION] A with(nolock)
      where A.OID = @OperationOID
    end if @UnitOID is not null
    begin
      set @res=1
    end
    return @res
  end
  else if @Type = 6 /*view*/
  begin
    declare @checkOID int
    declare @viewARC int
    select
       @res = dbo.DEF_F_ACCESS(B.ARC,null,2,@Date,@UserID,0) 
      ,@checkOID = B.OID
      ,@viewARC = A.ARC
    from DEF_VIEWS A with (nolock) 
      left join DEF_CLASSES B with (nolock) on B.OID = A.CLASSOID
    where A.OID = @ViewOID

    if @checkOID is null /*если view без ссылки на класс - то это view по основному классу*/
      set @res = 1

    if @viewARC is not null /*30.04.2018 если у view есть собственный маркер доступа - проверить его*/
      set @res = dbo.DEF_F_ACCESS(@viewARC,null,200,@Date,@UserID,0) 
    return @res
  end
  return 1
end