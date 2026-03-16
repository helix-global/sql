CREATE function [dbo].[FC_REPORT_FROMOPERATION]( @FRID int, @FRIntExt int, @aMode int)
returns nvarchar(100)
as
begin
/*KB1697*/

if @FRIntExt <> 1
  return null

declare @res nvarchar(100)
declare @parentID int

select top 1 @res = B.NAME
 	  ,@parentID = A.PARENTID
from PR_OPERATION A with (nolock)
left join PR_OPERATIONS B with (nolock) on B.ID = A.OPERTYPEID
where A.FAILUREREPORTID = @FRID
order by A.ID 
     
if @parentID is not null  /*если troubleshooting*/
begin
  
    set @parentID = null

	select @res = B.NAME
		,@parentID = A.PARENTID
	from PR_OPERATION A with (nolock)
	left join PR_OPERATIONS B with (nolock) on B.ID = A.OPERTYPEID
	where A.ID = @parentID

	if @parentID is not null  /*если troubleshooting из troubleshooting */
	begin
	   select @res = B.NAME
	   from PR_OPERATION A with (nolock)
	   left join PR_OPERATIONS B with (nolock) on B.ID = A.OPERTYPEID
	   where A.ID = @parentID
    end

end     
     
return @res  

end;