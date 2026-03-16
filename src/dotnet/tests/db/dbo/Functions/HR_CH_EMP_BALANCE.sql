-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-12-11
-- Description: Returns employee compensation balance.
-- =============================================
-- KB5272:2025-02-24: Using option @Year=?.
-- KB5194:2025-01-29: Fixed error using [COM_EMPLOYEE].[CH_BALANCE_FROM] field.
-- KB5194:2025-01-21: Updated to use [COM_EMPLOYEE].[CH_BALANCE_FROM] field.
-- KB5146:2024-12-11: Initial update.
CREATE function [dbo].[HR_CH_EMP_BALANCE](@EmpID int,@Options nvarchar(max))
returns @OutputT table
  (
  [EMPID] int,
  [CURRENT_BALANCE_SHRT_ABS]  int,
  [CURRENT_BALANCE_OVERTIME]  int,
  [CURRENT_BALANCE]           int,
  [LIMIT_BALANCE_SHRT_ABS]    int,
  [LIMIT_BALANCE_OVERTIME]    int,
  [BALANCE_THIS_YEAR] int,
  [BALANCE_PREV_YEAR] int
  )
as
begin
  declare @OptionsT table([OPTION] nvarchar(max))
  insert into @OptionsT
    select [a].[OPTION]
    from [dbo].[COM_OPT_SPLIT](@Options) [a]

  declare @OvrID int = null
  declare @VacID int = null
  declare @YearBalanceP int
  declare @YearBalanceC int
  declare @Year int = year(getdate())
  declare @CalcFrom date = null

  if exists(select * from @OptionsT [a] where [a].[OPTION] like N'@Year=%')
  begin
    select top 1
      @Year=right([a].[OPTION],len([a].[OPTION])-6)
    from @OptionsT [a] where [a].[OPTION] like N'@Year=%'
  end

  select
    @CalcFrom=[e].[CH_BALANCE_FROM]
  from [dbo].[COM_EMPLOYEE] [e] with(nolock)
  where [e].[ID]=@EmpID

  if @CalcFrom is null or year(@CalcFrom)<@Year
  begin
    select
      @YearBalanceP=sum(isnull([a].[BALANCE],0))
    from [dbo].[HR_CH_EMP_BALANCE_YEAR] [a] with(nolock)
    where [a].[YEAR]=@Year-1
      and [a].[EMPID]=@EmpID
      and [a].[S_S]=6290001
  end

  set @YearBalanceP = isnull(@YearBalanceP,0)

  if exists(select * from @OptionsT [a] where [a].[OPTION] like N'@VacID=%')
  begin
    select top 1
      @VacID=right([a].[OPTION],len([a].[OPTION])-7)
    from @OptionsT [a] where [a].[OPTION] like N'@VacID=%'
  end
  if exists(select * from @OptionsT [a] where [a].[OPTION] like N'@OvrID=%')
  begin
    select top 1
      @OvrID=right([a].[OPTION],len([a].[OPTION])-7)
    from @OptionsT [a] where [a].[OPTION] like N'@OvrID=%'
  end

  set @YearBalanceC = [dbo].[COM_CH_BALANCE_MINUTES](@EmpID,@Year,@VacID)
  if @OvrID is not null
  begin
    declare @Delta int = null
    select
      @Delta=datediff(mi,[a].[DBEG],[a].[DEND])
    from [dbo].[COM_ADDED_WORKTIME] [a] with(nolock)
    where [a].[ID]=@OvrID
    set @YearBalanceC = @YearBalanceC-isnull(@Delta,0)
  end

  declare @BALANCE_OVERTIME int = 480
  declare @BALANCE_SHRT_ABS int = 480
  select
    @BALANCE_OVERTIME=[a].[BALANCE_OVERTIME],
    @BALANCE_SHRT_ABS=[a].[BALANCE_SHRT_ABS]
  from [dbo].[HR_CH_EMP_LIMITS](@EmpID,null,null) [a]
  set @BALANCE_OVERTIME=isnull(@BALANCE_OVERTIME,480)
  set @BALANCE_SHRT_ABS=isnull(@BALANCE_SHRT_ABS,480)

  declare @Balance int = @YearBalanceC + @YearBalanceP
  declare @O int = @BALANCE_OVERTIME - @Balance
  declare @A int = @BALANCE_SHRT_ABS + @Balance
  if @A<0 set @A=0
  if @O<0 set @O=0

  insert into @OutputT(
    [EMPID],[CURRENT_BALANCE_SHRT_ABS],[CURRENT_BALANCE_OVERTIME],
    [LIMIT_BALANCE_SHRT_ABS],[LIMIT_BALANCE_OVERTIME],
    [BALANCE_THIS_YEAR],[BALANCE_PREV_YEAR],[CURRENT_BALANCE])
  values (@EmpID,@A,@O,@BALANCE_SHRT_ABS,@BALANCE_OVERTIME,@YearBalanceC,@YearBalanceP,@YearBalanceC+@YearBalanceP)
  return
end