CREATE PROCEDURE [dbo].[COM_DH_VP_CHECKAPPROVE] (@VacationType int,@VacationEmplID int, @aUserID int)
AS
BEGIN
set nocount on

if @VacationType = 30 
begin
  if exists (select F.ID from COM_DH_VP_SETTINGS_T F with (nolock) where F.EMPLID = @VacationEmplID)
  begin
     if dbo.DEF_USERINGROUP4(@aUserID,'MNGD',getdate()) <> 1
	 begin
		--if not in group "MNBGD" try to additional check user in "Departments Heads Vacation Proposals Settings"
		
		/* KB5321 Add additional check */
		declare @ParentUser int = 0	
		select 
			@ParentUser = U.ID
			from COM_DH_VP_SETTINGS_T F with (nolock) 
			inner join COM_DH_VP_SETTINGS FV with (nolock) on FV.ID = F.VNESHID
			inner join DEF_USERS U with (nolock) on U.EMPLOYEEID = FV.DEFAULT4EMPLID
			where F.EMPLID = @VacationEmplID
		
		--if user not found in "Departments Heads Vacation Proposals Settings" rise error
		if(@ParentUser <> @aUserID)
		begin
			raiserror('Only members of the "Managing Director" role OR users setted in "Departments Heads Vacation Proposals Settings" can approve the proposal',16,0)
		end
	 end
     

     
  end 
end
  
set nocount off
END