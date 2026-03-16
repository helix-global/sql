CREATE function [dbo].[PR_MODELS_TO_BOMITEM](@OperID int, @BomID int, @OnDate datetime)  
 returns @res table(ID INT)
as 
begin  
  
  declare @DeviceID int
  declare @RevID int
  declare @OperType int
  declare @depID int
  
  select @DeviceID = A.DEVICEID
        ,@RevID = D.REVID
        ,@OperType = B.OPERTYPE
        ,@depID = T.DEPARTMENTID
  from PR_OPERATION A
  left join PR_OPERATIONS B on B.ID = A.OPERTYPEID
  left join PR_DEVICE D on D.ID = A.DEVICEID
  left join PR_MODELS M on M.ID = D.MODELID
  left join PR_MODELTYPE T on T.ID = M.TYPEID
  where A.ID = @OperID
    
  if ((select NAME from PR_REVISION where ID = @RevID) = 'GENERIC')
    set @RevID = null
  
  if (@OperType in (5,22) or @RevID is null)
  begin

      insert into @res (ID)
      select PARTMODELID 
      from dbo.PR_DEVICE_BOM_MODELS(@DeviceID) where BOMID = @BomID


	  insert into @res (ID)
	  select A.ID
	  from PR_MODELS A with (nolock) 
	  where A.TYPEID in (select B.BOMMTID 
	                       from PR_MODELTYPE_BOM B 
	                      where B.ID = @BomID
	                      union 
	                      select C.BOMMTID 
	                       from PR_MODELTYPE_BOM_T C
	                       where C.VNESHID = @BomID)
	    and (isnull(A.SHARETOALL,0) = 1 or exists (select G.ID from PR_MODEL_SHARINGR G 
	                                                where G.MODELID = A.ID and G.DEPARTMENTID = @depID))
	    and not exists (select L.ID from @res L where L.ID = A.ID)
  
  
  end
  else
  begin
  
     insert into @res (ID)
     select PARTMODELID 
     from dbo.PR_DEVICE_BOM_MODELS(@DeviceID) where BOMID = @BomID
  
  end
  
  return

end