CREATE FUNCTION [dbo].[COM_TRAINERS_OPERATIONS2]
(
    @UserID int
)
RETURNS @ret TABLE (ID int)
AS
BEGIN

	--EMA HEAD Waldemar Rerich 114	--89
	--EMA-PS Alexander Krist 112  --211
	--declare @UserID int = 155
	--declare @ret TABLE (ID int)



	declare @employeeId int
	set @employeeId = dbo.DEF_EMPLOYEE(@UserID)

	    
    declare @skills table (ID int)

	
    /* KB2643 : Добавление вывода операций и для пользователя группы "Head of Dep & Deputy" своего и подчиненного отдела */
	if(dbo.DEF_USERINGROUP7(@UserID,'DH&VICE')= 1)
	begin
		declare @today datetime = GetDate()
		
		--Депаратмент сотрудника
		declare @employeeDepID int
		set @employeeDepID = dbo.COM_EMPLOYEE_DEP(@employeeId, GETDATE())

		-- сотрудники своего и подчиненных отделов (они же тренеры, указаныt в TRAINER_ID)
		declare @employees table (ID int)
		insert into @employees (ID)
			select EE.ID 
			from COM_EMPLOYEE EE with(nolock) 
			where EE.DEPID in (select ID from [dbo].[COM_GETCHILD_DEPARTMENTS2](@employeeDepID,1))
		
		-- сама выборка где тренер попадает список сотрудников своего и подчиненных отделов
		insert into @ret (ID)
		select T.OPERID
			from COM_TRAINING_OPERATIONS T with (nolock)
			where TRAINING_STATE is null and TRAINER_ID in (select ID from @employees) and OPERID is not null
		union
		select T.OPERID
			from COM_TRAINING_PREPARATORY T with (nolock)
			where TRAINING_STATE is null and TRAINER_ID in (select ID from @employees) and OPERID is not null
		union
		select T.OPERID 
			from COM_TRAINING_MAINTENANCE T with (nolock)
			where TRAINING_STATE is null and TRAINER_ID in (select ID from @employees) and OPERID is not null
		
		RETURN
	end



    insert into @skills (ID)
    select S.SKILLID
		from
		    COM_EMPLOYEE_SKILL S with (nolock)
		where 
			S.EMPLOYEEID=@employeeId 
			and 
			S.CAN_TRAIN=1
		           and dbo.COM_EMPLOYEE_HAS_SKILL2(@employeeId,S.SKILLID,0)=1

	insert into @ret (ID)
	select T.OPERID
	    from COM_TRAINING_OPERATIONS T 
	        join COM_EMPLOYEE E with (nolock) on T.TRAINER_ID=E.ID 
	        join COM_TRAINING TR on T.TRAININGID=TR.ID
	    where TR.SKILLID in (select ID from @skills) and T.CHECKED_TRAINER_ID is null
	union 
	select T.OPERID
	    from COM_TRAINING_PREPARATORY T 
	        join COM_EMPLOYEE E with (nolock) on T.TRAINER_ID=E.ID 
	        join COM_TRAINING TR on T.TRAINING_ID=TR.ID
	    where TR.SKILLID in (select ID from @skills) and T.CHECKED_TRAINER_ID is null
	union 
	select T.OPERID 
	    from COM_TRAINING_MAINTENANCE T 
	        join COM_EMPLOYEE E with (nolock) on T.TRAINER_ID=E.ID 
	        join COM_TRAINING TR on T.TRAININGID=TR.ID
	    where TR.SKILLID in (select ID from @skills) and T.CHECKED_TRAINER_ID is null
    


    RETURN 


END