create function [dbo].[PR_EMPL_IDS_IN_STAGE_STR](@StageID int, @dBeg datetime, @dEnd datetime, @UserID int)
returns nvarchar(max) as 
begin
  declare @res nvarchar(max) = ''
  
  select @res = @res + ',' + cast(E.EMPLOYEEID as nvarchar)
	from PR_STAGES S with (nolock)
		join PR_OPERATIONS O with (nolock) on O.STAGEID=S.ID
		join PR_OPERATIONS_GR G with (nolock) on O.OPERGRID=G.ID
		join PR_EMPL_TO_OPERGR E with (nolock) on G.ID=E.GROUPID
		join COM_EMPLOYEE EMP with (nolock) on E.EMPLOYEEID=EMP.ID
	where S.ID = @StageID
		 and isnull(E.DBEG,'19900101') <= @dEnd
		 and isnull(E.DEND,'40000101') >= @dBeg
		 and EMP.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@UserID, 1, getdate()))
	GROUP BY E.EMPLOYEEID

    
  return @res
end