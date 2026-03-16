CREATE function [dbo].[PR_ORDERROW_SWID](@OrderRowID int, @ParamID int)
returns int as 
begin

  declare @res int;
  declare @pkind int;
  declare @pdatatype int;
  declare @revID int;
  declare @typeID int;
  
  
  select @pkind = A.PARAMKIND
        ,@pdatatype = A.DATATYPE 
   from PR_MODELTYPE_PARAMS A with (nolock) where A.ID = @ParamID
  
  select @revID = A.REVID
       , @typeID = B.TYPEID
  from PR_PRORDER_T A with (nolock) 
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID 
  where A.ID = @OrderRowID
  
  
  if @pdatatype = 10 /* SW */
  begin

     declare @opts table (ID int)
     insert into @opts (ID)
     select distinct G.OPTID from PR_PRORDER_TO G where G.OPID = @OrderRowID
     /*predefined*/
     insert into @opts (ID)
     select distinct G.OPTIONID 
     from PR_PRORDER_T A with (nolock)
     left join PR_MODEL_OPTIONS G on G.MODELID = A.MODELID
     where A.ID = @OrderRowID
       and isnull(G.PREDEFINEDOPT,0) = 1
       and not exists (select H.ID from @opts H where H.ID = G.OPTIONID)

     
     select top 1 @res = A.SWTOOLID
     from PR_REV_SW A with (nolock)
     where A.REVID = @revID
       and A.ONLYOPTION in (select ID from @opts)
       and A.ONLYOPTION2 in (select ID from @opts)
       and A.ONLYOPTION3 in (select ID from @opts)
       and A.SWID = @ParamID
       
     if @res is not null return @res  
     
     select top 1 @res = A.SWTOOLID
     from PR_REV_SW A with (nolock)
     where A.REVID = @revID
       and A.ONLYOPTION in (select ID from @opts)
       and A.ONLYOPTION2 in (select ID from @opts)
       and A.ONLYOPTION3 is null
       and A.SWID = @ParamID
       
     if @res is not null return @res  
     
     select top 1 @res = A.SWTOOLID
     from PR_REV_SW A with (nolock)
     where A.REVID = @revID
       and A.ONLYOPTION in (select ID from @opts)
       and A.ONLYOPTION2 is null
       and A.ONLYOPTION3 is null
       and A.SWID = @ParamID
       
     if @res is not null return @res  

     select top 1 @res = A.SWTOOLID
     from PR_REV_SW A with (nolock)
     where A.REVID = @revID
       and A.ONLYOPTION is null
       and A.ONLYOPTION2 is null
       and A.ONLYOPTION3 is null
       and A.SWID = @ParamID
       
     if @res is not null return @res  
     
     return @res
  end
  
  return null  

end