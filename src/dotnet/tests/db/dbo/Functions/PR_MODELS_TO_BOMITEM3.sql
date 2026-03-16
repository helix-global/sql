create function [dbo].[PR_MODELS_TO_BOMITEM3](@OperID int, @BomID int, @OnDate datetime,@aSN nvarchar(50))  
 returns @res table(ID INT,SOURCE_TYPE int)
as 
begin  
  /* v.3 если в результирующих моделях найден @aSN, то такой модели ставится SOURCE_TYPE = 0 */
  declare @DeviceID int
  declare @RevID int
  declare @OperType int
  declare @depID int
  declare @modelID int
  
  select @DeviceID = A.DEVICEID
        ,@RevID = D.REVID
        ,@OperType = B.OPERTYPE
        ,@depID = T.DEPARTMENTID
        ,@modelID = D.MODELID
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

      insert into @res (ID,SOURCE_TYPE)
      select PARTMODELID,1  
      from dbo.PR_DEVICE_BOM_MODELS(@DeviceID) where BOMID = @BomID


	  insert into @res (ID,SOURCE_TYPE)
	  select A.ID,100
	  from PR_MODELS A with (nolock) 
	  where A.TYPEID in (select B.BOMMTID 
	                       from PR_MODELTYPE_BOM B with (nolock)
	                      where B.ID = @BomID
	                      union 
	                      select C.BOMMTID 
	                       from PR_MODELTYPE_BOM_T C with (nolock)
	                       where C.VNESHID = @BomID)
	    and (isnull(A.SHARETOALL,0) = 1 or exists (select G.ID from PR_MODEL_SHARINGR G with (nolock)
	                                                where G.MODELID = A.ID and G.DEPARTMENTID = @depID))
	    and not exists (select L.ID from @res L where L.ID = A.ID)
	    
	   update @res set SOURCE_TYPE = 10
	   where SOURCE_TYPE = 100
	     and exists (select H.ID 
	                   from PR_REV_BOM2 H with (nolock)
	                   left join PR_REVISION K with (nolock) on K.ID = H.REVID
	                   where K.MODELID = @modelID
	                     and H.BOMID = @BomID
	                     and H.PARTMODELID = "@res".ID)
	                   
	    if @aSN is not null
	    begin
	      update @res set SOURCE_TYPE = 0
	      where exists (select top 1 A.ID from PR_DEVICE A with (nolock) where A.MODELID = "@res".ID and A.SN = @aSN)
	    end             
  
  
  end
  else
  begin
  
     insert into @res (ID,SOURCE_TYPE)
     select PARTMODELID ,1
     from dbo.PR_DEVICE_BOM_MODELS(@DeviceID) where BOMID = @BomID
  
  end
  
  return

end