
CREATE FUNCTION [dbo].[COM_IMP_RECCOMEND_LIST]
(
	@UserID int
)
RETURNS @ret table (ID int)
AS
BEGIN
	if dbo.DEF_USERINGROUP1(@UserID, 'ADM')=1 or dbo.DEF_USERINGROUP1(@UserID, 'IMPREC')=1
	begin
		insert into @ret 
			select ID from COM_IMP_RECOMMENDATIONS

		return
	end
	
	if dbo.DEF_USERINGROUP1(@UserID, 'SPVIMPREC')=1 or dbo.DEF_USERINGROUP1(@UserID, 'PLM')=1
	begin

		insert into @ret 
			select R.ID from COM_IMP_RECOMMENDATIONS R
					join COM_EMPLOYEE E on R.INITIATOR=E.ID
				where E.DEPID=dbo.COM_USER_DEPARTMENT(@UserID)

		return
	end

	insert into @ret 
		select ID from COM_IMP_RECOMMENDATIONS
			where INITIATOR=dbo.DEF_EMPLOYEE(@UserID)
	
	RETURN 
END