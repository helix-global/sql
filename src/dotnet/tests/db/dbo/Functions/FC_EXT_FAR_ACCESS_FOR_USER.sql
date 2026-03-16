
CREATE FUNCTION [dbo].[FC_EXT_FAR_ACCESS_FOR_USER](
    @UserID int, @Option int, @DepID int
)
RETURNS int
AS
BEGIN
    
    declare @ret int = 0

	if dbo.DEF_USERINGROUP7(@UserID, 'ADM')=1
		return 1

    if  exists (select EMPLOYEEID 
                    from FC_EXT_FAR_ACCESS_OPTIONS O 
                        join FC_EXT_FAR_ACCESS A on O.ACCESSID=A.ID
                    where O.ACCESS_OPTION=@Option 
                        and O.EMPLOYEEID=dbo.DEF_EMPLOYEE(@UserID)
                        and A.ENDDEPID=@DepID)
        set @ret = 1

    return @ret

END