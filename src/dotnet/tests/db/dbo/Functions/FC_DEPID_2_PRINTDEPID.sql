create function [dbo].[FC_DEPID_2_PRINTDEPID](@aDepID int)
returns int as 
begin
  /* возвращает ID подразделения куда направлять сломанные изделия */
  /* учитывая настройку из FC_DEPSHARING */

  declare @resDepID int 
  set @resDepID = @aDepID
     
  select top 1 @resDepID = A.ALLOW2DEPID 
  from FC_DEPSHARING A with (nolock) 
  where A.DEPID = @aDepID and isnull(A.PRINTDEP,0) = 1
    
  return @resDepID;
end