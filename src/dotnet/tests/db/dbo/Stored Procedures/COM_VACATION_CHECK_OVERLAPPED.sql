CREATE PROCEDURE [dbo].[COM_VACATION_CHECK_OVERLAPPED] (@VacationID int)
AS
BEGIN
set nocount on

declare @emplID int 
declare @dtbeg datetime 
declare @dtend datetime
declare @vtype int

select @emplID = A.EMPLID
      ,@dtbeg = dbo.COM_VACATION_DBEG(A.ID) 
      ,@dtend = dbo.COM_VACATION_DEND(A.ID) 
      ,@vtype = A.VACATIONTYPE
from COM_VACATION A with (nolock)
where A.ID = @VacationID

if @vtype = 20 /*sickleave*/
begin
   set nocount off
   return
end


declare @dtbeg2 datetime 
declare @dtend2 datetime
declare @errVID int
declare @errm nvarchar(max)

select top 1 @errVID = A.ID
from COM_VACATION A with (nolock)
where A.EMPLID = @emplID
  and A.ID <> @VacationID
  and A.VACATIONTYPE = @vtype
  and A.S_S not in (1,1000142,1000147) /*new,rejected,canceled*/
  and dbo.COM_VACATION_DBEG(A.ID) < @dtend
  and dbo.COM_VACATION_DEND(A.ID) > @dtbeg

if (@errVID is not null)
begin
  
  select 
       @dtbeg2 = dbo.COM_VACATION_DBEG(A.ID) 
      ,@dtend2 = dbo.COM_VACATION_DEND(A.ID) 
  from COM_VACATION A with (nolock)
  where A.ID = @errVID
    

  set @errm = 'Period of the vacation proposal '+ltrim(rtrim(str(@VacationID)))+' overlapped with another vacation proposal '+ltrim(rtrim(str(@errVID)))+' from '+dbo.COM_FORMAT_DATETIME(@dtbeg2,1)+' to '+dbo.COM_FORMAT_DATETIME(@dtend2,1)
  raiserror(@errm,16,0)

end

  
set nocount off
END