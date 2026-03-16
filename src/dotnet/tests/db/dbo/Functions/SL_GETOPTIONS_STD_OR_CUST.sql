CREATE function [dbo].[SL_GETOPTIONS_STD_OR_CUST] (@aModelID int,@aMode int)
returns @res table (ID int)
as 
begin

if (@aMode = 1) /*standart options*/
begin

  insert into @res (ID)
  select distinct A.OPTIONID 
    from SL_MODEL_OPTIONS A with (nolock)
    left join SL_OPTIONS B with (nolock) on B.ID = A.OPTIONID
   where A.MODELID = @aModelID 
     and B.PRTYPE = 1 
     and B.S_S = 4180002
     and isnull(A.OVERPTYPE,0) = 0

end
else if (@aMode = 2) /*customized options*/
begin

  insert into @res (ID)
  select distinct A.OPTIONID 
    from SL_MODEL_OPTIONS A with (nolock)
    left join SL_OPTIONS B with (nolock) on B.ID = A.OPTIONID
   where A.MODELID = @aModelID 
     and B.S_S = 4180002
     and (B.PRTYPE = 2 or isnull(A.OVERPTYPE,0) = 1)

end

return

end