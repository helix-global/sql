CREATE procedure [dbo].[PR_CHANGE_SN_IFNEED] 
   @OperationID int
as 
set nocount on


declare @DeviceID int
declare @snChMode int
declare @snChPrm nvarchar(50)
declare @snChMask nvarchar(50)

declare @snCh nvarchar(50)
declare @prowid int
declare @oldSN nvarchar(50)

declare @depID int

declare @snNmin int
declare @ModelID int
declare @sn4model int; /*искать сл. номер по маске в пределах модели*/
declare @mtypeID int;
declare @sn4mt int; /*искать сл. номер по маске в пределах типа модели*/


select 
 @snChMode = coalesce(M.SNPMODE,T.SNPMODE,0)
,@snChPrm = coalesce(M.SNPRM,T.SNPRM)
,@snChMask = coalesce(M.SNPMASK,T.SNPMASK)
,@sn4model = coalesce(M.SNP4MODEL,0)
,@oldSN = D.SN
,@DeviceID = D.ID
,@depID = M.DEPID
,@snNmin = coalesce(M.SNPMIN,T.SNPMIN,0)
,@ModelID = D.MODELID
,@mtypeID = M.TYPEID
,@sn4mt = coalesce(T.SNP4MTYPE,0)
from PR_OPERATION A with (nolock)
left join PR_DEVICE D with (nolock) on D.ID = A.DEVICEID
left join PR_MODELS M with (nolock) on M.ID = D.MODELID
left join PR_MODELTYPE T with (nolock) on T.ID = M.TYPEID
where A.ID = @OperationID

if @snChMode = 0
begin
  set nocount off
  return
end  


if @snChMode in (11) and CHARINDEX('not assigned',@oldSN) = 0
begin
  set nocount off
  return
end  


if @snChMode in (1,4,11)  /* по параметру */
begin
  
  select 
    @snCh = LTRIM(RTRIM(convert(nvarchar,A.PVALUE)))
   ,@prowid = A.ID
  from PR_OPERATION_PARAMS A with (nolock)
  left join PR_MODELTYPE_PARAMS B with (nolock) on B.ID = A.PARAMID 
  where A.OPERID = @OperationID
    and B.NAME = @snChPrm
	
  if @prowid is not null
  begin
    if @snChMask is not null
	  set @snCh = replace(@snChMask,'?',@snCh)
	set @snCh = LTRIM(rtrim(@snCh))
	if @snCh is not null 
	   if @snCh <> @oldSN 
          update PR_DEVICE set SN = @snCh where ID = @DeviceID 
  end	

end 
else if @snChMode = 2  /* по компоненту */
begin

  select 
    @snCh = LTRIM(RTRIM(convert(nvarchar,A.SN)))
   ,@prowid = A.ID
  from PR_OPERATION_INSTALL A with (nolock)
  left join PR_MODELTYPE_BOM B with (nolock) on B.ID = A.BOMID
  where A.OPERID = @OperationID
    and B.NAME = @snChPrm
	
  if @prowid is not null
  begin
    if @snChMask is not null
	  set @snCh = replace(@snChMask,'?',@snCh)
    set @snCh = LTRIM(rtrim(@snCh))	  
	if @snCh is not null   
	   if @snCh <> @oldSN
          update PR_DEVICE set SN = @snCh where ID = @DeviceID
  end	

end
else if @snChMode = 3  /* по маске и первой операции */
begin
  
	if CHARINDEX('not assigned',@oldSN) > 0
	begin
   
		declare @newSNC nvarchar(50)
	  
		set @newSNC = dbo.PR_SNC_OPER(@OperationID)
	    set @newSNC = dbo.PR_SN_OPER(@newSNC,@OperationID);    		

		declare @newSNN int
		
		
		select @newSNN = isnull(max(B.SNN),0)+1 
		 from PR_DEVICE B with (nolock) 
		left join PR_MODELS M with (nolock) on M.ID = B.MODELID
		where B.SNC = @newSNC
		  and (M.DEPID = @depID or isnull(@sn4mt,0) = 2)
		  and (B.MODELID = @ModelID or isnull(@sn4model,0) <> 1)
		  and (M.TYPEID = @mtypeID or isnull(@sn4mt,0) = 0)
		  ;
		  
	    if @snNmin > 0
	      if @newSNN < @snNmin
	      begin
	    
 	          if not exists (select A.ID from PR_DEVICE A
 	                  where A.MODELID = @ModelID
					    and A.SNC is not null
						and A.SNN is not null
						and A.ID <> @DeviceID)
  	             set @newSNN = @snNmin
	      
	      end		  
		
		set @snCh = dbo.PR_SN(@newSNC,@newSNN,@DeviceID);    
	   
		update PR_DEVICE set SN = @snCh, SNC = @newSNC, SNN = @newSNN where ID = @DeviceID;
		
    end    
   
end

set nocount off