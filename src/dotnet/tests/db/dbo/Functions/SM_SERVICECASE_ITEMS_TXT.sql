CREATE function [dbo].[SM_SERVICECASE_ITEMS_TXT](@CaseID int,@aMode int)
returns nvarchar(max)
as
begin

   if @CaseID is null
       return null

   declare @res nvarchar(max)
   set @res = ''

	if @aMode = 1
	begin
	
	   select @res = @res + CHAR(13) + char(10) +  A.SN + ' ' + B.NAME + ' (' + B.CODE + ') ' + isnull(H.NAME,'') 
	   from SM_SERVICECASE_ITEMS A with (nolock)
	   left join PR_MODELS B with (nolock) on B.ID = A.MODELID
	   left join PR_DEVICE C with (nolock) on C.ID = A.DEVICEID
	   left join PR_PRORDER D with (nolock) on D.ID = C.ORDERID
	   left join PR_SUPPLY F with (nolock) on F.ID = C.SORDERID
	   left join COM_CUSTOMER H with (nolock) on H.ID = isnull(F.CUSTOMERID,D.CUSTOMERID)
	   where A.VNESHID = @CaseID
	   
	end
	else if @aMode = 2
	begin

		select @res = @res + A.SN + ' ' + B.NAME + CHAR(13) + char(10)
		from SM_SERVICECASE_ITEMS A with (nolock)
		left join PR_MODELS B with (nolock) on B.ID = A.MODELID
		where A.VNESHID = @CaseID

		if LEN(@res) > 2
		set @res = substring(@res,0,len(@res)-1)

	end
	else
	begin
	
	   select @res = @res + A.SN + ' ' + B.NAME + ' (' + B.CODE + ')' + CHAR(13) + char(10) 
	   from SM_SERVICECASE_ITEMS A with (nolock)
	   left join PR_MODELS B with (nolock) on B.ID = A.MODELID
	   where A.VNESHID = @CaseID
	   
       if LEN(@res) > 2
         set @res = substring(@res,0,len(@res)-1)  
	   
	end   
	   
   if LEN(@res) = 0
     return null
     
     
   return @res  

end;