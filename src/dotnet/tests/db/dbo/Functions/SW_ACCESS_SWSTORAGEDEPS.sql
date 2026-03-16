CREATE function [dbo].[SW_ACCESS_SWSTORAGEDEPS] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin

	insert into @res (ID) 
	select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID, @aMode, @aDate)
	
	/*KB1952*/
	if @aUserID = 19
	begin
	
	   insert into @res (ID) values ( 295 /*CTD*/)
	
	end
	

	return

end