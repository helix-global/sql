--KB5074:2024-11-07: Moved limit check to [dbo].[HR_CH_EMP_LIMITS].
CREATE PROCEDURE [dbo].[COM_CHECK_SHORT_ABSENCE_LEN] (@aID int)
AS
BEGIN
  set nocount on

  /*KB2755*/

  declare @lenProposed int
  declare @lenProposedDayOthers int
  declare @lenWork int
  declare @checkID int
  declare @userDepID int
  declare @lenAllInDay int
  declare @EmpID int
  declare @DBeg date

  select @checkID = A.ID
        ,@lenProposed = A.SHORTDURATION
        ,@lenWork = dbo.COM_WORKPERIOD_LEN2(dbo.COM_WORKTABLE_BY_DATE(A.DBEG,A.EMPLID),1)  
        ,@lenProposedDayOthers = dbo.COM_SH_ABSNS_IN_DAY(A.EMPLID,A.DBEG,A.ID)
        /*,@lenProposedDayOthers = (select sum(B.SHORTDURATION) 
                                    from COM_VACATION B with (nolock) 
                                   where B.EMPLID = A.EMPLID 
                                     and B.DBEG = A.DBEG
                                     and B.VACATIONTYPE = 30
                                     and B.ID <> A.ID
                                     and B.S_S in (1000141, 1000140, 2130051) 
                                  )   */
        ,@userDepID = B.DEPID
        ,@lenAllInDay = dbo.COM_SH_ABSNS_IN_DAY2(A.EMPLID,A.DBEG,A.ID)
        ,@EmpID=[A].[EMPLID]
        ,@DBeg=[A].[DBEG]
  from COM_VACATION A with (nolock)
  left join COM_EMPLOYEE B with(nolock) on B.ID = A.EMPLID 
  where A.ID = @aID
    and A.VACATIONTYPE = 30

  declare @SHRT_ABS_MAX int = 210
  declare @SHRT_ABS_HDV int = 0
  declare @Message nvarchar(max)
  select
    @SHRT_ABS_MAX=[a].[SHRT_ABS_MAX],
    @SHRT_ABS_HDV=[a].[SHRT_ABS_HDV]
  from [dbo].[HR_CH_EMP_LIMITS](@EmpID,@DBeg,null) [a]

  if @lenAllInDay > @SHRT_ABS_MAX
  begin
    set @Message = '#EShort Absence cannot be applied for more than ' + [dbo].[COM_STR_FORMAT_TIMESPAN](@SHRT_ABS_MAX,4)+'.'
    raiserror(@Message,16,1)
    return
  end
  if @SHRT_ABS_HDV=0
  begin
    return
  end

  /*
  TODO: правильнее судить по @lenAllInDay  т.к. она учитывает пересечения
  */       

  if @checkID is not null and @lenWork is not null
  begin

    if (@lenProposed + isnull(@lenProposedDayOthers,0)) > (@lenWork / 2) - 30
    begin
  
       raiserror('#EShort Absence cannot be applied for the half of the working day, you should take the shorter Short Absence or the vacation with the period of the half of the day',16,1)
     
    end

  end

  
  set nocount off
END