CREATE function [dbo].[COM_DEP_FINEACCESS](@aDepID int, @aUserID int, @aMode int, @aDate datetime)
returns nvarchar(max)
as
begin

  declare @res nvarchar(100) = null;

  if dbo.COM_DEP_ACCESS(null,@aDepID,@aMode,@aUserID,@aDate) <> 1
  begin
	  set @res = 'FullReadOnly;NoAllActions';
  
    if (dbo.DEF_USERINGROUP7(@aUserID,'R&D_PL') = 1  /*KB4812*/ or dbo.DEF_USERINGROUP7(@aUserID,'DEP_MODELS') = 1 /*KB5386*/ )
	  begin
		  set @res = @res + ';BypassActionsMarked=mdls';
	  end

    /*Azure#6048: для mode = ReadOnlyDesigner показывать действия с FineAccessMark = 'allowTest' (по аналогии с функцией PR_OPERATIONS_FINEACCESS) */
    if dbo.COM_DEP_ACCESS(null, @aDepID, 8 /*Designer & readonly designer in department*/, @aUserID, @aDate) = 1
    begin
	    set @res = @res + ';BypassActionsMarked=allowTest'
    end
  end

  return @res

end