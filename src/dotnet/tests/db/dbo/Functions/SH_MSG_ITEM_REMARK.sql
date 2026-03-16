CREATE function [dbo].[SH_MSG_ITEM_REMARK](@shReqDepID int, @aDeviceID int)
returns nvarchar(100)
as
begin
  /*KB752  добавляет строку "No paper Test Results needed" в рассылке по sh.req. */
	declare @checkPrintedDoc int

	select @checkPrintedDoc=isnull(D.CHECK_PRINTED_DOC_REQUIRED,0)
		from COM_DEPARTMENTS D 
		where ID=@shReqDepID

	--if @shReqDepID not in (170/*PLA*/,195/*YLA*/)
	--	return ''

	if @checkPrintedDoc=0
		return ''
  
	declare @res nvarchar(100)

	if dbo.PR_DEVICE_IN_SUBSCRIPTION(@aDeviceID,1)=1
		set @res = 'No paper Test Results needed'       
  
  --if exists (select A.ID 
  --             from MSG_FILENOTIFICATIONS_OUT A with (nolock)
  --           where A.DEVICEID = @aDeviceID)
  --   set @res = 'No paper Test Results needed'       
  
	return isnull(@res,'');
end;