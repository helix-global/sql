CREATE PROCEDURE [dbo].[COM_CHECK_ZEITREPORT] (@dID int, @aUserID int, @MethodOID int)
AS
BEGIN
set nocount on

declare @empid int
declare @weekDate datetime

declare @d1S datetime
declare @d1E datetime
declare @d1P datetime

declare @d2S datetime
declare @d2E datetime
declare @d2P datetime

declare @d3S datetime
declare @d3E datetime
declare @d3P datetime

declare @d4S datetime
declare @d4E datetime
declare @d4P datetime

declare @d5S datetime
declare @d5E datetime
declare @d5P datetime

declare @d6S datetime
declare @d6E datetime
declare @d6P datetime

declare @d7S datetime
declare @d7E datetime
declare @d7P datetime


select @empid = A.EMPLID
   ,@weekDate = A.WEEKDD
   ,@d1S = D1_START, @d1E = D1_END, @d1P = D1_PAUSE
   ,@d2S = D2_START, @d2E = D2_END, @d2P = D2_PAUSE
   ,@d3S = D3_START, @d3E = D3_END, @d3P = D3_PAUSE
   ,@d4S = D4_START, @d4E = D4_END, @d4P = D4_PAUSE
   ,@d5S = D5_START, @d5E = D5_END, @d5P = D5_PAUSE
   ,@d6S = D6_START, @d6E = D6_END, @d6P = D6_PAUSE
   ,@d7S = D7_START, @d7E = D7_END, @d7P = D7_PAUSE
from COM_ZEITARBEITREPORT A 
where A.ID = @dID

exec COM_CHECK_ZEITREPORT_ONEDAY 1, @weekDate, @d1S, @d1E, @d1P, @empid, @aUserID, @MethodOID
exec COM_CHECK_ZEITREPORT_ONEDAY 2, @weekDate, @d2S, @d2E, @d2P, @empid, @aUserID, @MethodOID
exec COM_CHECK_ZEITREPORT_ONEDAY 3, @weekDate, @d3S, @d3E, @d3P, @empid, @aUserID, @MethodOID
exec COM_CHECK_ZEITREPORT_ONEDAY 4, @weekDate, @d4S, @d4E, @d4P, @empid, @aUserID, @MethodOID
exec COM_CHECK_ZEITREPORT_ONEDAY 5, @weekDate, @d5S, @d5E, @d5P, @empid, @aUserID, @MethodOID
exec COM_CHECK_ZEITREPORT_ONEDAY 6, @weekDate, @d6S, @d6E, @d6P, @empid, @aUserID, @MethodOID
exec COM_CHECK_ZEITREPORT_ONEDAY 7, @weekDate, @d7S, @d7E, @d7P, @empid, @aUserID, @MethodOID
  
set nocount off
END