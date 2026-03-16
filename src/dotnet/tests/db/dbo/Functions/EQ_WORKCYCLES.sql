-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-03-04
-- Description: Calculates equipment work cycles.
-- =============================================
-- KB4645:2024-03-04: Initial update.
-- KB4680:2024-03-25: Updated to use work cycle specific parameters.
--        2024-03-27: Updated to use work cycle specific parameters from other table [PR_OPERATION_PARAMS]->[EQ_OPERATION_PARAMS].
--        2024-03-27: Fixed to use 'datetime' type for @PeriodBeg.
CREATE function [dbo].[EQ_WORKCYCLES](@EqId int, @PeriodBeg datetime,@PeriodEnd date,@ParamId int)
returns int as
begin
  if @EqId is null or @EqId = 0 return 0

  -- Counts number of parameters and sum of its integer value.
  declare @EqParmSUM float = 0
  declare @EqParmCNT int = 0

  select
     @EqParmSUM=sum(isnull([dbo].[COM_CONVERT_TO_FLOAT]([p].[PVALUE]),0))
    ,@EqParmCNT=count([p].[ID])
  from [dbo].[EQ_OPERATION_PARAMS] [p] with(nolock)
    inner join [dbo].[PR_OPERATION]        [o] with(nolock) on [p].[OPERID]=[o].[ID]
    inner join [dbo].[EQ_MODEL_PARAM_REF]  [r] with(nolock) on [r].[PARAMID]=[p].[PARAMID]
    inner join [dbo].[PR_MODELTYPE_PARAMS] [m] with(nolock) on [m].[ID]=[p].[PARAMID]
  where [p].[EQID] = @EqId
    and ([o].[S_S] <> 1000023)
    and ((([o].[COMPLETED_DT] is not null)
    and ((@PeriodBeg is null) or ([o].[COMPLETED_DT] >= @PeriodBeg))
    and ((@PeriodEnd is null) or (cast([o].[COMPLETED_DT] as date) <= @PeriodEnd))) /*or ([o].[COMPLETED_DT] is null)*/)
    and ([r].[USE_IN_WORKCYCLE_CALC]=1)
    and ([m].[PARAMKIND]=1)
    and ([m].[DATATYPE] in (3,4))
    and ((@ParamId=0) or ([m].[ID]=@ParamId))

  if @EqParmCNT > 0 return isnull(@EqParmSUM,0)

  select
    @EqParmCNT=count([p].[ID])
  from [dbo].[PR_OPERATION_PARAMS] [p] with(nolock)
    left join [dbo].[PR_OPERATION] [o] with(nolock) on [p].[OPERID]=[o].[ID]
  where [p].[EQID] = @EqId
    and ([o].[S_S] <> 1000023)
    and ((([o].[COMPLETED_DT] is not null)
    and ((@PeriodBeg is null) or ([o].[COMPLETED_DT] >= @PeriodBeg))
    and ((@PeriodEnd is null) or (cast([o].[COMPLETED_DT] as date) <= @PeriodEnd))) /*or ([o].[COMPLETED_DT] is null)*/)

  return isnull(@EqParmCNT,0)
end