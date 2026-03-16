create function [dbo].[FC_DEPID_2_PRINTDEPID2](@aFromDepID int, @aMTID int, @aDepID int)
returns int as 
begin
  /* возвращает ID подразделения куда направлять сломанные изделия */
  /* учитывая настройку из FC_DEPSHARING */
  
  /* v.2 сначала использует настройки в fc_return_departments */
  

  declare @resDepID int 
  set @resDepID = @aDepID
    
  declare @aMode int
  declare @specifiedDepID int
  
  select @aMode = A.RETURNTO
        ,@specifiedDepID = A.RETURNTODEPID
    from FC_RETURN_DEPARTMENTS A with (nolock)
   where A.DEPID = @aFromDepID
     and A.MTID = @aMTID
  
  if @aMode = 1  /* MT owner */
  begin
    
    select @resDepID = A.DEPARTMENTID from PR_MODELTYPE A with (nolock) where A.ID = @aMTID
    return @resDepID
    
  end  
  else if @aMode = 2  /* Specified dep */
  begin
    
    return @specifiedDepID;  
    
  end
     
  select top 1 @resDepID = A.ALLOW2DEPID 
  from FC_DEPSHARING A with (nolock) 
  where A.DEPID = @aDepID and isnull(A.PRINTDEP,0) = 1
    
  return @resDepID;
end