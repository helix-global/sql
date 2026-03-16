create FUNCTION [dbo].[EQ_LINKED_ATTACHMENTDATE](@eqId int,@contextid int,@mode int)
RETURNS date
AS
BEGIN
	
	declare @ret date = null
	
	if isnull(@eqId,-11) <> isnull(@contextid,-1221)
	begin

      select top 1 @ret = case @mode when 1 then A.LINKDBEG when 2 then A.LINKDEND else null end
      from EQ_EQUIPMENT_LINKED A with(nolock)
      where A.VNESHID = @contextid
        and A.LINKED_EQID = @eqId

    end
    
	return @ret

END