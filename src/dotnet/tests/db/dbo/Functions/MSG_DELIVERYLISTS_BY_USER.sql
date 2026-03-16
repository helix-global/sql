
CREATE FUNCTION MSG_DELIVERYLISTS_BY_USER (@DELIVERYTYPE int, @aUSERID int)
returns @res table (ID int)
as 
begin
		insert into @res	
		select ID from MSG_DELIVERYLIST where DELIVERYTYPE = @DELIVERYTYPE and DEPID in (
			select ID from COM_DEPARTMENTS_BY_PARENT_ID(
				(select EE.DEPID from DEF_USERS UU
				left join COM_EMPLOYEE
				EE on UU.EMPLOYEEID = EE.ID 
				where UU.ID = @aUserID)
			)
		)

		return
end