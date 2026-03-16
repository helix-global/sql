CREATE function [dbo].[PR_DEVICE_IN_TOPDEVICE_TAB2](@aDeviceID int,@aTopMTID int)
returns @res table (ID int)
as
begin
  
  /*
    отличается от PR_DEVICE_IN_TOPDEVICE_TAB наличием второго параметра, 
    который дает возможность задать тип модели "до которого" искать host
  */
  
  insert into @res (ID)
  select B.DEVICEID
  from PR_OPERATION_INSTALL A with (nolock) 
  left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
  where A.PARTID = @aDeviceID
    and dbo.PR_UNINSTALL_ID(A.ID) is null
    and (B.S_S IN (1000013, 1000019, 1000038,1000116))

  insert into @res (ID)
  select B.ID
  from @res A
  outer apply dbo.PR_DEVICE_IN_TOPDEVICE_TAB2(A.ID,@aTopMTID) B
  
  if isnull(@aTopMTID,0) > 0
  begin
    delete from @res
    where (select B.TYPEID 
             from PR_MODELS B with (nolock) 
            where B.ID = (select C.MODELID 
                            from PR_DEVICE C with (nolock)
                           where C.ID = "@res".ID)) <> @aTopMTID
  end
  else
  begin
    delete from @res
    where exists (select B.ID from PR_OPERATION_INSTALL B where B.PARTID = "@res".ID)
  end  
   
  delete from @res where ID is null 
   
  return 
end;