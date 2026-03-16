CREATE function [dbo].[COM_VR_REQUEST_ACCESS](@aVR_ID int, @aUserID int, @aMode int, @aDate datetime)
returns int as 
begin
	/* KB4831 05.07.2024 Efimov*/
	/* KB4905 06.08.2024 Efimov refacoring (speedy)*/

	declare @vr_request_state int
	declare @vr_request_depid int
	declare @vr_request_user int
	
	select TOP 1 
		@vr_request_depid = DEPID, @vr_request_state = S_S, @vr_request_user = S_CR
	from VR_REQUEST with (nolock)
	where ID = @aVR_ID


	if (dbo.DEF_USERINGROUP4(@aUserID,'ADM',@aDate) = 1)
			return 1

    

    --MD (Mashkin) and users in group
	if(@aUserID = 19 --Mashkin
	 or
	 dbo.DEF_USERINGROUP4(@aUserID,'VRMD',@aDate) = 1 -- user in group VRMD
	 )
	begin
		-- if User is MD Mashkin
		-- and stage is 5130012	MD - Pending Approval and 5130013	Approved
		if(@vr_request_state in (5130012 /* MD - Pending Approval */,5130013 /* Approved */)
			or
		  --and if user before change state of this documnet by himself (it should be or Approve or Reject - we a re hope that Reject is in list)
		  (exists (select ID
					from DEF_LOG with (nolock)
					where DOCOID= 5130009 /* vr_request */
					and DOCID = @aVR_ID 
					and EV_TYPE = 20002 
					and S_USERID = @aUserID) 
 			and @vr_request_state = 5130014 /*Rejected*/ )	
		  )
			return 1 
		else
			return 0
	end
	else
	begin

		-- see ALL but action limited in FINEACCESS
		if (dbo.DEF_USERINGROUP4(@aUserID,'VRADMIN',@aDate) = 1)	
			return 1

		-- if user HD&VICE 
		--if (@vr_request_depid in (select ID from dbo.COM_ACCESS_DEPARTMENTS_WITH_CHILD(@aUserID, @aMode, @aDate)) and @vr_request_state <> 1) --as HD&VICE for approve
		if (@vr_request_state <> 1 and dbo.COM_DEP_ACCESS2(@vr_request_depid, 3, @aUserID, @aDate) = 1) --as HD&VICE for approve
		begin
			if dbo.DEF_USERINGROUP4(@aUserID,'DH&VICE',@aDate) = 1 
				return 1

		end
		if (@vr_request_user = @aUserID and dbo.COM_DEP_ACCESS2(@vr_request_depid, 3, @aUserID, @aDate) = 1) --as HD&VICE as requestor
		begin
			if dbo.DEF_USERINGROUP4(@aUserID,'DH&VICE',@aDate) = 1 
				return 1
		end

		--IF USER IN GROUP 'VREDITOR' view only themself records
		if (dbo.DEF_USERINGROUP4(@aUserID,'VREDITOR',@aDate) = 1 and @vr_request_user = @aUserID) 
			--or 
			--(dbo.DEF_USERINGROUP4(@aUserID,'VRDEPVIEWER',@aDate) = 1 and dbo.COM_DEP_ACCESS2(@vr_request_depid,3,@aUserID, GETDATE()) = 1)
			return 1

		

	end

	-- default return denied
	return 0
end