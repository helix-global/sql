CREATE FUNCTION [dbo].[PR_READINESS]
(
	@DeviceID int, @OrderID int
)
RETURNS decimal (10,1)
AS
BEGIN
  declare @allOperations decimal(12,6);
  declare @doneOperations decimal(12,6);
  declare @res decimal(12,6);
  
  if @DeviceID is not null
  begin
    declare @RevID int
    declare @d_state int
    declare @Mapid int
    declare @prOrderID int
    declare @prCompleted datetime
    
    select @RevID = REVID
         , @d_state = A.S_S 
         , @Mapid = A.MAPID
         , @prOrderID = A.ORDERID
         , @prCompleted = A.COMPLETED_DT
      from PR_DEVICE A with (nolock) 
     where A.ID = @DeviceID
     
    if @Mapid is null
      return null
    if @prCompleted is not null
      return 100
    if @d_state = 1000029 /*pend.prod*/
      return 0    
    if @d_state not in (1000008,1000022)
      return null
    if @d_state = 1000022  
      return 100
      
    select @allOperations = COUNT(*) from PR_MAP_OPER with (nolock) where MAPID = @Mapid
    if @allOperations = 0 
      return 100
      
    select @doneOperations = COUNT(*) 
      from PR_OPERATION A with (nolock) 
     where A.DEVICEID = @DeviceID 
       and A.S_S in (1000013,1000019)
       and A.ORDERID = @prOrderID
       and A.REVOPERID is not null
       
   declare @skipped int
    select @skipped = count(distinct REVOPERID)
      from PR_DEVICE_SKIPPED_OP A with (nolock)
     where A.DEVICEID = @DeviceID 
       and A.ORDERID = @prOrderID
       and A.REVOPERID is not null
       
    set @doneOperations = @doneOperations + @skipped   
    
    set @res = @doneOperations / @allOperations;
    
    set @res = @res * 100
    if @res > 100
      set @res = 100
    return @res 
         
  end
  else if @OrderID is not null and @DeviceID is null
  begin
     declare @state int;
     select @state = S_S from PR_PRORDER with (nolock) where ID = @OrderID;
     if @state in (1,1000056,1000063,1000082)
       return 0

     select @res = avg(isnull(A.STOREDREADINESS,dbo.PR_READINESS(A.ID,null))) 
     from PR_DEVICE A with (nolock)
     where A.ORDERID = @OrderID
     
     if @res > 100
       set @res = 100
     return @res 

  end
  
  return 0;

END