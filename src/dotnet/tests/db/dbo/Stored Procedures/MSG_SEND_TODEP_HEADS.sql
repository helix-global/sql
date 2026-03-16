-- Azure#6100 2025-10-06: Use department's email from COM_DEPARTMENTS if department has no head or deputy.
-- KB4817     2024-05-29: @aMode=1 means inverse of @vTo and @aToCC
--
-- Test: exec [dbo].[MSG_SEND_TODEP_HEADS] 1620 /* IPGL-PDB-Agent */, 153, '', 0, 'subj', 'body'
CREATE PROCEDURE [dbo].[MSG_SEND_TODEP_HEADS]
  @aUserID int, @aToDepID int, @aToCC nvarchar(1024), @aMode int, @aSubj nvarchar(1024), @aBoby nvarchar(max)
AS
BEGIN
  
  declare @vTo nvarchar(1024) = ''

  select @vTo = isnull(@vTo,'') + case when len(@vTo) > 0 then '; ' else '' end + [EMAIL]
  from [dbo].[COM_EMPLOYEE] (nolock)
  where [DEPID] = @aToDepID
    and [EMAIL] is not null
    and [ROLEINDEP] in (10, 100) /*Deputy, Head of department*/
    and [S_S] <> 1000092 /*dismissed*/
  order by [ROLEINDEP] desc;

  if len(@vTo) = 0
  begin
    select top 1 @vTo = [EMAIL] from [dbo].[COM_DEPARTMENTS] (nolock) where [ID] = @aToDepID;
  end

  if @aMode = 0 and len(@vTo) > 1
  begin
    exec MSG_SEND2 @aUserID, @vTo, @aToCC, @aSubj, @aBoby
  end
  else if @aMode = 1
  begin
    exec MSG_SEND2 @aUserID, @aToCC, @vTo, @aSubj, @aBoby
  end
END