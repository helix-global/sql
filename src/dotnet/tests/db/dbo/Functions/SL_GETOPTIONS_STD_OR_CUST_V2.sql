CREATE function [dbo].[SL_GETOPTIONS_STD_OR_CUST_V2] (@aModelID int,@aMode int,@CustomerID int)
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
     and (B.PRTYPE = 2 
           or (isnull(A.OVERPTYPE,0) = 1 and dbo.SL_CHECK_CUSTOMIZED4_V2(2, A.CUSTOM4ID, A.CUSTOM4GROUP, @CustomerID) = 1)
           /*22.11.2018 добавлена проверка для кого они кастомизированы */
          )

end

return

end