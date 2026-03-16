CREATE function [dbo].[PR_PRORDER_INFO](@aOrderID int,@aMode int)
returns nvarchar(1024)
as
begin
  
  if @aMode = 0 /* модели */
  begin 
	  declare @cou int
	  select @cou = COUNT(distinct MODELID) from PR_PRORDER_T A with (nolock) where A.PRORDERID = @aOrderID

	  if @cou = 1
	  begin
		declare @res nvarchar(1024)
	    
		select top 1 @res = B.NAME
		from PR_PRORDER_T A with (nolock)
		left join PR_MODELS B with (nolock) on B.ID = A.MODELID
		where A.PRORDERID = @aOrderID
	    
		if exists (select C.ID from PR_PRORDER_TO C with (nolock) where C.OPID in (select A.ID from PR_PRORDER_T A with (nolock) where A.PRORDERID = @aOrderID))
		  set @res = rtrim(@res) + ' with options'
	      
	      
		return @res 
	  end
	  else if @cou > 1
	  begin
		return 'several models'
	  end
  end
  else if @aMode = 1 /* ревизии */
  begin 
	  declare @cou2 int
	  select @cou2 = COUNT(distinct A.REVID) from PR_PRORDER_T A with (nolock) where A.PRORDERID = @aOrderID

	  if @cou2 = 1
	  begin
		declare @res2 nvarchar(1024)
	    
		select top 1 @res2 = B.NAME
		from PR_PRORDER_T A with (nolock)
		left join PR_REVISION B with (nolock) on B.ID = A.REVID
		where A.PRORDERID = @aOrderID
	      
		return @res2 
	  end
	  else if @cou > 1
	  begin
		return 'several revisions'
	  end
  end
  else if @aMode = 2 /*PNs*/
  begin
    
    declare @res3 nvarchar(1024)
    
    select @res3 = isnull(@res3,'') + case when len(@res3) > 0 then ', '+CODE else CODE end
    from (
    select distinct B.CODE    
	from PR_PRORDER_T A with (nolock)
	left join PR_MODELS B with (nolock) on B.ID = A.MODELID
	where A.PRORDERID = @aOrderID
	) M

    return @res3
    
  end 
    
  return null;
end;