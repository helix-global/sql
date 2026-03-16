create function [dbo].[PR_REVWHEREUSED_QTY] (@revid int, @contextID int, @mode int)
returns decimal(18,6)
as
begin
   
   /*KB3234*/

    declare @res int

    if @mode = 1
    begin
		select @res = sum(isnull(A.QTY,1)) from PR_REV_BOM2 A with(nolock) where A.REVID = @revid and A.PARTMODELID = @contextID
	end
	else if @mode = 2
	begin
		select @res = sum(isnull(A.QUANTITY,1)) from PR_REV_PDMU A with(nolock) where A.REVID = @revid and A.MID = @contextID
	end	
                
    return @res
end