CREATE function [dbo].[FC_REPORT_AHISTORY_ACCESS](@aUserID int, @aFarID int, @aMode int, @aDate datetime)
returns int as 
begin

  /*в соответствии с KB1989 доступ д.б. только для типа моделей Pulsed Lasers*/

  if dbo.DEF_USERINGROUP7(@aUserID,'KB1989') = 1
  begin
    
     declare @mtID int
     
     select @mtID = C.ID
     from FC_REPORT A with (nolock)
     left join PR_MODELS B with (nolock) on B.ID = A.MODELID
     left join PR_MODELTYPE C with (nolock) on C.ID = B.TYPEID
     where A.ID = @aFarID
       and C.ID = 'c1226717-1d81-4eed-9ede-7f08f378d268'  /*Pulsed Lasers*/
       
     if @mtID is null
       return 0  
     
  
  end  
  
  return 1

end