-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION COM_DEPS_SKILL_MATRIX ()
RETURNS 
@ret table
(
	ID int
)
AS
BEGIN

	declare @tmp table (ID int)
	declare @rowcount int = 1

	insert into @tmp 
	select ID 
		from COM_DEPARTMENTS D
		where isnull(D.SKILL_MATRIX,0)=1
	
	while @rowcount>0
	begin
		
		insert into @tmp 
		select C.ID 
			from @tmp t 
				cross apply dbo.COM_GETCHILD_DEPARTMENTS(t.ID) C
				join COM_DEPARTMENTS D on C.ID=D.ID
			where isnull(D.SKILL_MATRIX,0)=1
		except 
		select ID
			from @tmp

		set @rowcount = @@ROWCOUNT

	end

	insert into @ret
	select ID 
		from @tmp

	insert into @ret 
	select C.ID 
		from @tmp t 
			cross apply dbo.COM_GETCHILD_DEPARTMENTS(t.ID) C
			join COM_DEPARTMENTS D on C.ID=D.ID
		where isnull(D.SKILL_MATRIX,-1)<>0
	except 
	select ID
		from @ret

	insert into @ret 
	select D.ID 
		from COM_DEPARTMENTS D
		where isnull(D.SKILL_MATRIX,0)=2
	except 
	select ID
		from @ret

	return

END