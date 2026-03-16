CREATE function [dbo].[COM_ZEIT_LEN_WEEKTOTAL](@aZeitReportID int)
returns datetime
as
begin

declare @totalMinutes int

select @totalMinutes = dbo.COM_ZEIT_LEN_MINUTES(A.D1_START,A.D1_END,A.D1_PAUSE)+
	 dbo.COM_ZEIT_LEN_MINUTES(A.D2_START,A.D2_END,A.D2_PAUSE)+
	 dbo.COM_ZEIT_LEN_MINUTES(A.D3_START,A.D3_END,A.D3_PAUSE)+
	 dbo.COM_ZEIT_LEN_MINUTES(A.D4_START,A.D4_END,A.D4_PAUSE)+
	 dbo.COM_ZEIT_LEN_MINUTES(A.D5_START,A.D5_END,A.D5_PAUSE)+
	 dbo.COM_ZEIT_LEN_MINUTES(A.D6_START,A.D6_END,A.D6_PAUSE)+
	 dbo.COM_ZEIT_LEN_MINUTES(A.D7_START,A.D7_END,A.D7_PAUSE)
from COM_ZEITARBEITREPORT A with (nolock) 
where A.ID = @aZeitReportID

declare @res datetime = '19000101'
set @res = dateadd(minute,@totalMinutes,@res)

return @res

end;