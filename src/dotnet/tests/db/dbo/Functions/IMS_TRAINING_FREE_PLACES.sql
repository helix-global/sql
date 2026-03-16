
CREATE FUNCTION [dbo].[IMS_TRAINING_FREE_PLACES]
(
    @schedDateId int
)
RETURNS int
AS
BEGIN
    
    declare @ret int, @persCount int

    select @ret = isnull(A.MAXPERSONS - (select count(B.ID) from IMS_DEP_SCHEDULE_T B 
                left join IMS_DEP_SCHEDULE C on C.ID = B.VNESHID
               where C.SCHEDULEID = A.VNESHID
                 and C.S_S > 1
                 and isnull(B.SCHEDULEDATEID,0) = A.ID) ,0)
       from IMS_TRAINING_SCHEDULE_DATES A 
       where A.ID=@schedDateId

    return @ret

END