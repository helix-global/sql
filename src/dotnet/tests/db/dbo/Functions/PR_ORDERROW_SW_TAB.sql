CREATE function [dbo].[PR_ORDERROW_SW_TAB](@OrderRowID int, @ParamID int)
returns @res table (SWTOOLID int,SWVERID int,SWMODE int,SWNAME nvarchar(200))
begin

  declare @pkind int;
  declare @pdatatype int;
  declare @revID int;
  declare @modelID int;
  declare @typeID int;
  
  
  select @pkind = A.PARAMKIND
        ,@pdatatype = A.DATATYPE 
   from PR_MODELTYPE_PARAMS A with (nolock) where A.ID = @ParamID
  
  select @revID = A.REVID
       , @typeID = B.TYPEID
       , @modelID = A.MODELID
  from PR_PRORDER_T A with (nolock) 
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID 
  where A.ID = @OrderRowID
  
  if @pdatatype = 10 /* SW */
  begin
     
     declare @opt table (OPTID int)
     
     insert into @opt (OPTID)
     select G.OPTID from PR_PRORDER_TO G where G.OPID = @OrderRowID
     
     insert into @opt (OPTID)
     select A.OPTIONID from PR_MODEL_OPTIONS A
     where A.MODELID = @modelID
       and ISNULL(A.PREDEFINEDOPT,0) = 1
     
     insert into @res (SWTOOLID,SWVERID,SWMODE,SWNAME)
     select top 1 A.SWTOOLID,A.SWVERSIONID,A.SWMODE,B.NAME
     from PR_REV_SW A with (nolock)
     left join SW_TOOLS B with (nolock) on B.ID = A.SWTOOLID 
     where A.REVID = @revID
       and A.ONLYOPTION in (select G.OPTID from @opt G)
       and A.ONLYOPTION2 in (select G.OPTID from @opt G)
       and A.ONLYOPTION3 in (select G.OPTID from @opt G)
       and A.SWID = @ParamID
       
     if (select count(*) from @res) > 0 return
     
     insert into @res (SWTOOLID,SWVERID,SWMODE,SWNAME)
     select top 1 A.SWTOOLID,A.SWVERSIONID,A.SWMODE,B.NAME
     from PR_REV_SW A with (nolock)
     left join SW_TOOLS B with (nolock) on B.ID = A.SWTOOLID 
     where A.REVID = @revID
       and A.ONLYOPTION in (select G.OPTID from @opt G)
       and A.ONLYOPTION2 in (select G.OPTID from @opt G)
       and A.ONLYOPTION3 is null
       and A.SWID = @ParamID
       
     if (select count(*) from @res) > 0 return

     
     insert into @res (SWTOOLID,SWVERID,SWMODE,SWNAME)
     select top 1 A.SWTOOLID,A.SWVERSIONID,A.SWMODE,B.NAME
     from PR_REV_SW A with (nolock)
     left join SW_TOOLS B with (nolock) on B.ID = A.SWTOOLID 
     where A.REVID = @revID
       and A.ONLYOPTION in (select G.OPTID from @opt G)
       and A.ONLYOPTION2 is null
       and A.ONLYOPTION3 is null
       and A.SWID = @ParamID
       
     if (select count(*) from @res) > 0 return

     insert into @res (SWTOOLID,SWVERID,SWMODE,SWNAME)
     select top 1 A.SWTOOLID,A.SWVERSIONID,A.SWMODE,B.NAME
     from PR_REV_SW A with (nolock)
     left join SW_TOOLS B with (nolock) on B.ID = A.SWTOOLID 
     where A.REVID = @revID
       and A.ONLYOPTION is null
       and A.ONLYOPTION2 is null
       and A.ONLYOPTION3 is null
       and A.SWID = @ParamID
     
  end
  
  return

end