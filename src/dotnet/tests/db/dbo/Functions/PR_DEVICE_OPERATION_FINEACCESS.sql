CREATE FUNCTION [dbo].[PR_DEVICE_OPERATION_FINEACCESS]
(@operId int, @userId int)
returns nvarchar(20)
as
begin

    declare @ret nvarchar(20), @emplId int

    select @emplId=U.EMPLOYEEID
        from DEF_USERS U 
        where U.ID=@userId

    if exists(select ID from COM_TRAINING_OPERATIONS O where O.OPERID=@operId
                        union
                select ID from COM_TRAINING_PREPARATORY O where O.OPERID=@operId)
        set @ret='IN_TRAINING'
    else
        return @ret
    
    if exists( select A.ID
                from (select ID from COM_TRAINING_OPERATIONS O where O.OPERID=@operId and O.TRAINER_ID=@emplId
                        union
                        select ID from COM_TRAINING_PREPARATORY O where O.OPERID=@operId and O.TRAINER_ID=@emplId)  A)
        set @ret='TRAINER'

    return @ret

end