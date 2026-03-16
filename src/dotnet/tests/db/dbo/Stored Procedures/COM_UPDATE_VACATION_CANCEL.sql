CREATE PROCEDURE [dbo].[COM_UPDATE_VACATION_CANCEL] (@CancellationID int, @UserID int)
AS
BEGIN
set nocount on

declare @VacationID int
declare @CancelType int
declare @CancelState int

declare @dbeg date
declare @dend date
declare @vacationDBeg date
declare @vacationDEnd date
declare @navNN int

select @VacationID = A.VACATIONID
      ,@CancelType = A.CAN_TYPE
      ,@CancelState = A.S_S
    ,@dbeg = A.DBEG
    ,@dend = A.DEND
    ,@vacationDBeg = B.DBEG
    ,@vacationDEnd = B.DEND
    ,@navNN = B.NAVNN
from COM_VACATION_CANCEL A 
left join COM_VACATION B on B.ID = A.VACATIONID
where A.ID = @CancellationID


if @CancelState in (1000160 /*approved*/ ,2130053 /*submitted*/)
begin
  if @CancelType = 1 /*full*/
  begin
  
     update COM_VACATION set S_S = 1000147/*canceled*/ , S_MR = @UserID, S_MDT = getdate() where ID = @VacationID
     
     if @navNN > 0
		update COM_VACATION set S_S = 1000147/*canceled*/ , S_MR = @UserID, S_MDT = getdate() where NAVNN = @navNN and ID <> @VacationID
     
  end
  else if @CancelType = 2 /*partial*/
  begin

      set @vacationDEnd = isnull(@vacationDEnd,@vacationDBeg)

      if (@dbeg < @vacationDBeg) or (@dend > @vacationDEnd)
	  begin
		raiserror('Wrong period of partial cancelation.',16,0)
		set nocount off
		return
	  end
  
      if (@dbeg <> @vacationDBeg) and (@dend <> @vacationDEnd)
	  begin
		raiserror('Cannot cancel days in the middle of vacation.',16,0)
		set nocount off
		return
	  end
	   
	  if (@dbeg = @vacationDBeg) and (@dend = @vacationDEnd)
	  begin
		raiserror('Please use "Full" cancelation type instead.',16,0)
		set nocount off
		return
	  end
	  
	  if (@dbeg = @vacationDBeg)
	  begin
	     update COM_VACATION set DBEG = dateadd(day,1,@dend) , S_MR = @UserID, S_MDT = getdate() where ID = @VacationID
	  end
	  else if (@dend = @vacationDEnd)
	  begin
	     update COM_VACATION set DEND = dateadd(day,-1,@dbeg) , S_MR = @UserID, S_MDT = getdate() where ID = @VacationID
	  end
	  
	  update COM_VACATION set DEND = null, PERIODTYPE = 1 /*full */ where ID = @VacationID and DBEG = DEND and PERIODTYPE is null
     
  
  end
     
end

  
set nocount off
END