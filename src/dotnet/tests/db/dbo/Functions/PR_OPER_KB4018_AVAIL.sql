CREATE function [dbo].[PR_OPER_KB4018_AVAIL](@aUserID int, @dd datetime, @aMode int)
returns int
as
begin

/*
KB4018
проверяет что можно создавать операции special type 100 и 101
@aMode: 100 или 101
*/

declare @emplid int = dbo.DEF_EMPLOYEE(@aUserID)
declare @allow int 
declare @nonProd int
declare @prodSupp int

if not exists (select FF.ID from COM_EMPL_PARTINPROD FF with(nolock) where FF.EMPLID = @emplid) /*вообще нет признака что разрешено*/
   return 0

if @aMode = 100  /*non-production*/
begin

  select top 1 @allow = isnull(A.ALLOW_NON_PS,0) 
  from COM_EMPL_PARTINPROD A with(nolock) 
  where A.EMPLID = @emplid
    and A.DD <= @dd
  order by A.DD desc    
   
  if @allow <> 1
    return 0
   
  select top 1 @nonProd = isnull(A.ISRANDD,0) 
  from COM_EMPL_PARTINPROD A with(nolock) 
  where A.EMPLID = @emplid
    and A.DD <= @dd
  order by A.DD desc    
    
  if @nonProd <> 1
    return 0  
       

  return 1 

end
else if @aMode = 101  /*production support*/
begin

  select top 1 @allow = isnull(A.ALLOW_NON_PS,0) 
  from COM_EMPL_PARTINPROD A with(nolock) 
  where A.EMPLID = @emplid
    and A.DD <= @dd
  order by A.DD desc    
   
  if @allow <> 1
    return 0

  select top 1 @prodSupp = isnull(A.PRODSUPPORT,0) 
  from COM_EMPL_PARTINPROD A with(nolock) 
  where A.EMPLID = @emplid
    and A.DD <= @dd
  order by A.DD desc    
    
  if @prodSupp = 0
    return 0  


  return 1

end

     
return 0

end;