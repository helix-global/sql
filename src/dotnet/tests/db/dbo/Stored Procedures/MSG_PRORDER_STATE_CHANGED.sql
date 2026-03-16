-- Notifications about production order state change;
-- called from pr_notifications_KB4073 stage (row trigger) and other places where PR_PRORDER's state is changed.
-- 
-- KB4073:     Initial implementation.
-- Azure#39:   Changes in message (added link to A2 doc), optional filter by orders' old states / new states, optional filter by department relation and overall refactoring.
--
-- test:       exec [dbo].[MSG_PRORDER_STATE_CHANGED] 3553491, 3, 1000007, 1000020
--
-- Note: DeliveryList for ProdOrder 'State' change supports following options (option names are case-insensitive), separated by semicolon:
--   * OldStates - filter by previous prod. order statuses, comma-separated. If option is empty, all statuses are handled.
--   * NewStates - filter by new prod. order statuses, comma-separated. If option is empty, all statuses are handled.
--   * UseCustomerDepID - use department ID from prod. order's customer instead of prod. order's department.
--
-- Options example:
-- OldStates=1,1000007,1000058;NewStates=1000020,1000021;UseCustomerDepID
CREATE PROCEDURE [dbo].[MSG_PRORDER_STATE_CHANGED] @OrderID int, @UserID int, @oldState int, @newState int
AS
BEGIN
  set nocount on

	declare @subject nvarchar(100) = 'PO: Status was changed',
    @htmlBodyDraft nvarchar(max) = 
'<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<style type="text/css">
.segoe
{
  font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif; font-size: 14px; text-indent:0pt; margin:0pt 0pt 0pt 0pt
}
.segoe-small
{
  font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif; font-size: 10px; text-indent:0pt; margin:0pt 0pt 0pt 0pt
}
table
{
  width: auto;
  table-layout: auto;
  border-collapse: collapse;
}
th
{
  background-color: #f0f0f0;
  margin: 2px 16px;
}
td
{
  background-color: #ffffff;
  margin: 2px;
}
th, td
{
  padding: 0px;
  border: 1px solid #ccc;
  font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif;
  font-size: 12px;
  text-align: center;
}
</style>
</head>
<body>
<p class="segoe">Dear All,<br><br>
the following production order status was changed:</p><br>
<table>
<tr><th>Production Order</th><th>Source Number</th><th>External Number</th><th>Customer</th><th>Planned Date</th><th>Confirmed Date</th><th>Previous Status</th><th>New Status</th></tr>
<tr>';

  -- Append model type name to subject (will work if there is at least one order position).
  select top 1 @subject = concat(@subject, ', MT: ', modelType.[NAME])
	from
    [dbo].[PR_PRORDER_T] prOrderPositions (nolock)
	  join [dbo].[PR_MODELS] models (nolock) on models.[ID] = prOrderPositions.[MODELID]
    join [dbo].[PR_MODELTYPE] modelType (nolock) on modelType.[ID] = models.[TYPEID]
	where
    prOrderPositions.[PRORDERID] = @OrderID;
	
  declare @orderDepID int,
    @orderCustomerDepID int;

  select
    @orderDepID = prOrder.[DEPARTMENTID],
    @orderCustomerDepID = customerDepartament.[ID],
		@htmlBodyDraft = concat(@htmlBodyDraft,
      '<td>',      '<a href="a2l://doc/?ClassLabel=pr_production_order&ID=', @OrderID, '">', isnull(prOrder.[NN], 'NA'), '</a>',
      '</td><td>', isnull(prOrder.[NN2], 'NA'),
      '</td><td>', isnull(prOrder.[NN3], 'NA'),
      '</td><td>', isnull(customer.[NAME], 'NA'),
      '</td><td>', isnull(convert(nvarchar, prOrder.[EXPDATE], 104), ''),
      '</td><td>', isnull(convert(nvarchar, prOrder.[CDD], 104), ''),
      '</td>')
	from
    [dbo].[PR_PRORDER] prOrder (nolock)
	  left join [dbo].[COM_CUSTOMER] customer (nolock) on customer.[ID] = prOrder.[CUSTOMERID]
    left join [dbo].[COM_DEPARTMENTS] customerDepartament (nolock) on customerDepartament.[CUSTOMERID] = prOrder.[CUSTOMERID]
	where
    prOrder.[ID] = @OrderID;
  
  
  declare @deliveryDepID int,
    @options nvarchar(512),
    @useOrderCustomerDepID bit,
    @oldStatesFilter nvarchar(512),
    @newStatesFilter nvarchar(512),
    @htmlBodyToSend nvarchar(max);

  declare deliveryListCursor cursor for
      select [DEPID], [OPTIONS] from [dbo].[MSG_DELIVERYLIST] (nolock) where [DELIVERYTYPE] = 1617;

  open deliveryListCursor;
  fetch next from deliveryListCursor into @deliveryDepID, @options;

  while @@FETCH_STATUS = 0
  begin
    select @useOrderCustomerDepID = case when charindex('UseCustomerDepID', @options collate Latin1_General_CI_AS) > 0 then 1 else 0 end;
    
    if  ((@useOrderCustomerDepID = 0 and @deliveryDepID = @orderDepID)
      or (@useOrderCustomerDepID = 1 and @deliveryDepID = @orderCustomerDepID))
    begin
        select @oldStatesFilter = right(value, len(value) - charindex('=', value))
        from string_split(@options, ';')
        where charindex('=', value) > 0 and charindex('OldStates', left(value, charindex('=', value) - 1) collate Latin1_General_CI_AS) > 0;

        select @newStatesFilter = right(value, len(value) - charindex('=', value))
        from string_split(@options, ';')
        where charindex('=', value) > 0 and charindex('NewStates', left(value, charindex('=', value) - 1) collate Latin1_General_CI_AS) > 0;

        if ((@oldStatesFilter is null or exists(select ID from [dbo].[COM_STR2TABLE_INT](@oldStatesFilter) where ID = @oldState))
            and
            (@newStatesFilter is null or exists(select ID from [dbo].[COM_STR2TABLE_INT](@newStatesFilter) where ID = @newState)))
        begin
            set @htmlBodyToSend = concat(@htmlBodyDraft,
              '<td>',       isnull(dbo.DEF_STATE_NAME_EN(@oldState), ''),
              '</td><td>',  isnull(dbo.DEF_STATE_NAME_EN(@newState), ''),
              '</td></table><br><br><p class="segoe-small">This e-mail was created automatically. Please do not respond.<br>PDB</p>',
              '<!-- @deliveryDepID=', cast(@deliveryDepID as nvarchar(10)), ', @UserID=', cast(@UserID as nvarchar(10)), ', @options=', isnull(@options, '{null}'), ' --></body></html>');
	
            exec MSG_SEND_TODELIVERYGROUP4 @UserID, 1617, @deliveryDepID, @subject, @htmlBodyToSend, null
            --exec MSG_SEND_TOUSER @UserID, 44451, @subject, @htmlBodyToSend    /* TEST */
        end
     end

    fetch next from deliveryListCursor into @deliveryDepID, @options;
  end

  close deliveryListCursor;
  deallocate deliveryListCursor;

  set nocount off	
END