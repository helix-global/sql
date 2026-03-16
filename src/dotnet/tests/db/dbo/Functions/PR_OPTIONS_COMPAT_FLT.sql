create function [dbo].[PR_OPTIONS_COMPAT_FLT] (@aExistingModels nvarchar(max),@aMode int)
returns @res table (ID int)
as 
begin


  insert into @res (ID)
  select distinct A.OPTIONID
  from PR_MODEL_OPTIONS A with (nolock)
  where A.MODELID in (select ID from dbo.COM_STR2TABLE_INT(@aExistingModels))

  return

end