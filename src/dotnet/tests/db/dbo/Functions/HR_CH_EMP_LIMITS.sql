-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-11-07
-- Description: Returns employee related compensation balance limits.
-- =============================================
-- KB5074:2024-11-07: Initial update.
-- KB4980:2024-11-07: Applied to [dbo].[COM_CHECK_SHORT_ABSENCE_LEN] routine.
-- KB4832:2024-11-07: Applied to [dbo].[COM_CHECK_SHORT_ABSENCE_LEN] routine.
-- KB4681:2024-11-08: Applied to stage "com_my_added_datetime_check2".
-- KB4888:2024-11-08: For departments related to "Kurzarbeit", the balance should be {+2:-2}
-- KB5079:2024-11-08: For department "LDM" increased the limit of the compensation hours account up to 12 hours.
-- KB5084:2024-11-12: Will be used to load constraint values from the [COM_DISABLE_SH_ABS] and [HR_CH_EMP_OPT] table.
CREATE function [dbo].[HR_CH_EMP_LIMITS](@EmpID int,@Date date,@Options nvarchar(max))
returns @OutputT table
  (
  [EMPID] int,
  [BALANCE_SHRT_ABS] int,
  [BALANCE_OVERTIME] int,
  [SHRT_ABS_MAX] int,
  [SHRT_ABS_HDV] int
  )
as
begin
  declare @DepID int = 0
  insert into @OutputT([EMPID],[SHRT_ABS_MAX],[BALANCE_SHRT_ABS],[BALANCE_OVERTIME],[SHRT_ABS_HDV]) values (isnull(@EmpID,0),3*60+45,8*60,8*60,1)
  if isnull(@EmpID,0) > 0
  begin
    select
      @DepID=[a].[DEPID]
    from [dbo].[COM_EMPLOYEE] [a] with(nolock)
    where [a].[ID]=@EmpID

    declare @BALANCE_SHRT_ABS int = null
    declare @BALANCE_OVERTIME int = null
    declare @SHRT_ABS_MAX int = null
    declare @SHRT_ABS_HDV int = null
    declare @ID int = null

    select
       @ID=[a].[ID]
      ,@BALANCE_SHRT_ABS=[a].[BALANCE_SHRT_ABS]
      ,@BALANCE_OVERTIME=[a].[BALANCE_OVERTIME]
      ,@SHRT_ABS_MAX=[a].[SHRT_ABS_MAX]
      ,@SHRT_ABS_HDV=[a].SHRT_ABS_HDV
    from [dbo].[HR_CH_EMP_OPT] [a] with(nolock)
    where [a].[EMPID]=@EmpID

    if @ID is not null
    begin
      if @BALANCE_SHRT_ABS is not null
        update [a] set
         [a].[BALANCE_SHRT_ABS]=@BALANCE_SHRT_ABS
        from @OutputT [a]
      if @BALANCE_OVERTIME is not null
        update [a] set
         [a].[BALANCE_OVERTIME]=@BALANCE_OVERTIME
        from @OutputT [a]
      if @SHRT_ABS_MAX is not null
        update [a] set
         [a].[SHRT_ABS_MAX]=@SHRT_ABS_MAX
        from @OutputT [a]
      if @SHRT_ABS_HDV is not null
        update [a] set
         [a].[SHRT_ABS_HDV]=@SHRT_ABS_HDV
        from @OutputT [a]
      return
    end

    select
       @ID=[a].[ID]
      ,@BALANCE_SHRT_ABS=[a].[BALANCE_SHRT_ABS]
      ,@BALANCE_OVERTIME=[a].[BALANCE_OVERTIME]
      ,@SHRT_ABS_MAX=[a].[SHRT_ABS_MAX]
      ,@SHRT_ABS_HDV=[a].SHRT_ABS_HDV
    from [dbo].[COM_DISABLE_SH_ABS] [a] with(nolock)
    where [a].[DEPID]=@DepID

    if @ID is not null
    begin
      if @BALANCE_SHRT_ABS is not null
        update [a] set
         [a].[BALANCE_SHRT_ABS]=@BALANCE_SHRT_ABS
        from @OutputT [a]
      if @BALANCE_OVERTIME is not null
        update [a] set
         [a].[BALANCE_OVERTIME]=@BALANCE_OVERTIME
        from @OutputT [a]
      if @SHRT_ABS_MAX is not null
        update [a] set
         [a].[SHRT_ABS_MAX]=@SHRT_ABS_MAX
        from @OutputT [a]
      if @SHRT_ABS_HDV is not null
        update [a] set
         [a].[SHRT_ABS_HDV]=@SHRT_ABS_HDV
        from @OutputT [a]
    end
  end
  return
end