CREATE function [dbo].[SM_SERVICECALL_HAS_SERVICECASE](@aID int)

--KB2614 
returns nvarchar(max) as 
begin
  declare @res nvarchar(max)

  begin
	select @res = IIF(SC.CASEID is not null /*has service case*/ and SC.SCTYPE=2 /*e-mail type*/ and CS.READONLYSTATE = 0 /*not readonly state*/ ,convert(varchar,SC.CASEID),'NoActionsMarked=DISABLE_ADD') 
	from SM_SERVICECALL SC with(nolock)
	left join SM_SERVICECASE S with(nolock) on S.ID = SC.CASEID -- service case
	left join DEF_CLASS_STATES CS with(nolock) on S.S_S = CS.OID -- state (for readonly heck)
	where SC.ID = @aID
  end 

     
  return @res
  
end