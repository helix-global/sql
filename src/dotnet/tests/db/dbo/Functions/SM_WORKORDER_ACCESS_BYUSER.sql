CREATE function [dbo].[SM_WORKORDER_ACCESS_BYUSER](@UserID int)
returns @res table (ID int)
as
  begin

    /*if (dbo.DEF_USERINGROUP7(@UserID, 'WOMSG' /*Work Order Supervisor In Service Group*/) = 1)*/
    if (dbo.DEF_USERINGROUP5(@UserID, 'WOMSG' /*Work Order Supervisor In Service Group*/, 'ADM', 'MNGD', null, null) = 1)
    begin
      insert into @res (ID)
      select distinct A.ID
      from SM_WORKORDER A with (nolock)
      where dbo.COM_DEP_ACCESS(null,A.SDEPID,1,@UserID,getdate()) = 1 -- A.SDEPID in (select BB.ID from dbo.COM_ACCESS_DEPARTMENTS2(@UserID,1,getdate()) BB) 
    end
    else
    begin
      insert into @res (ID)
      select distinct A.ID
      from SM_WORKORDER A with (nolock)
      where dbo.COM_DEP_ACCESS(null,A.SDEPID,1,@UserID,getdate()) = 1 --A.SDEPID in (select BB.ID from dbo.COM_ACCESS_DEPARTMENTS2(@UserID,1,getdate()) BB) 
        /*and A.S_S<>1 KB2721 */ 
        and A.EMPLID=dbo.DEF_EMPLOYEE(@UserID)
    end

    return

  end