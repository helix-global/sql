CREATE function [dbo].[PR_DEVICE_ADDEDREPORTS_MPL]( @DeviceID int)
returns nvarchar(max) 
as
begin

    declare @res nvarchar(max)
    set @res = ''

	declare @mtid int
declare @mtid2 int

select @mtid = max(A.TYPEID),@mtid2 = min(A.TYPEID) from PR_MODELS A with (nolock) 
where A.ID in (select B.MODELID from PR_DEVICE B with (nolock) where ID in (@DeviceID)) 

if @mtid <> @mtid2
  set @mtid = null
  
declare @allReady int = 0
if not exists (select F.ID from PR_DEVICE F with (nolock) where F.ID in (@DeviceID) and F.COMPLETED_DT is null)
  set @allReady = 1

declare @allInProd int = 0
if not exists (select F.ID from PR_DEVICE F with (nolock) where F.ID in (@DeviceID) and F.COMPLETED_DT is not null)
  set @allInProd = 1

	   select @res = @res + cast(A.ID as nvarchar)+';'
			from PR_REPORTS A with (nolock) 
			where A.MTID = @mtid
			  and A.S_S = 1000075 /* Approved */
			  and (      (A.USE_DEV_PROD = 1 and A.USE_DEV_READY = 1) 
					  or (A.USE_DEV_PROD = 1 and @allInProd = 1)
					  or (A.USE_DEV_READY = 1 and @allReady = 1)
				  )
			  and 1 = all (select dbo.PR_REPORT_USING2(A.ID,S.MODELID,S.REVID) from PR_DEVICE S where S.ID in (@DeviceID) ) 
			  and 1 = all (select dbo.PR_REPORT_USING4(A.ID,S.ID) from PR_DEVICE S where S.ID in (@DeviceID) ) 
			  and (   (select count(*) from PR_REPORTS_T T where T.VNESHID = A.ID) = 0
					or exists (select G.ID from PR_REPORTS_T G 
										  where G.VNESHID = A.ID 
											and G.MODELID in (select B.MODELID 
																from PR_DEVICE B with (nolock) 
															   where ID in (@DeviceID)) 
											and G.REVID is null)
					or exists (select G.ID from PR_REPORTS_T G 
										  where G.VNESHID = A.ID 
											and G.REVID in (select B.REVID
															  from PR_DEVICE B with (nolock) 
															 where ID in (@DeviceID)) )
				  )
				and dbo.COM_TOP_PARENT_DEPCODE(A.DEPID)='IPGL' 
     
	   
    if LEN(@res) = 0
      return null
     
    return @res  

end;