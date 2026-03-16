CREATE procedure [dbo].[PR_PRORDER_STORE_SNS] 
 @OrderID int, @UserID int, @aDate datetime
as 
SET nocount on

  declare @Text nvarchar(max) = '' 

  declare @cc int 
  select @cc = count(*) from PR_DEVICE A with (nolock) where A.ORDERID = @OrderID and A.SN like 'SN not assigned%'
  if (@cc > 0)
     set @Text = ltrim(rtrim(str(@cc))) + ' items with not assigned SN.' + char(13)+ char(10)


  select @Text = @Text + A.SN + char(13)+ char(10) from PR_DEVICE A with (nolock) where A.ORDERID = @OrderID and A.SN not like 'SN not assigned%'
  
  update PR_PRORDER set PR_PRORDER.RUNLOG = @Text where ID = @OrderID

SET nocount off