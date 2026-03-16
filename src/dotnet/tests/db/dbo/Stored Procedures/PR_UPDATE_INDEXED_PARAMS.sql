CREATE procedure dbo.PR_UPDATE_INDEXED_PARAMS
 @DoneOperID int
as
  set nocount on

  update PR_OPERATION_PARAMS set INDEX_STR = upper(CAST(PVALUE AS nvarchar(250)))
  from PR_OPERATION_PARAMS
  where PARAMID in (select B.PRMID from PR_IMP_INDEX_PRMS B with (nolock))
    and OPERID=@DoneOperID
    and ((INDEX_STR is null and PVALUE is not null) or (INDEX_STR is not null and PVALUE is null) or INDEX_STR<>upper(CAST(PVALUE AS nvarchar(250))))

  set nocount off