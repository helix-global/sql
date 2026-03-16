
CREATE PROCEDURE [dbo].[CP_TICKET_CHECK] (@TicketID int, @UserID int)
AS
BEGIN
set nocount on

declare @nn nvarchar(24)
declare @nn1 decimal(10,0)
declare @nn2 decimal(10,0)
declare @i int = 1

select @nn = A.TN
from CP_TICKETS A with (nolock)
where A.ID = @TicketID

if (@nn is null)
begin
   
    while 1=1
    begin
       set @i = @i + 1
       if (@i > 100)
       begin
         raiserror ('Cannot find new ticket number.',16,0)
         set nocount off
         return
       end
       set @nn1 = cast(rand() * 10000000000 as decimal(10,0))
       set @nn2 = cast(rand() * 10000000000 as decimal(10,0))
       if not exists (select B.ID from CP_TICKETS B where B.TN_PART1 = @nn1 and B.TN_PART2 = @nn2)
       begin
         set @nn = cast(@nn1 as nvarchar)
         
         if len(@nn) < 10 
           set @nn = @nn + replicate('0',10-len(@nn))
         
         set @nn = @nn + cast(@nn2 as nvarchar)
         
         if len(@nn) < 20 
           set @nn = @nn + replicate('0',20-len(@nn))
         
         set @nn = substring(@nn,1,20)
         
         set @nn = substring(@nn,1,4) + '-' + substring(@nn,5,4) + '-' + substring(@nn,9,4) + '-' + substring(@nn,13,4) + '-' + substring(@nn,17,4)
         
         update CP_TICKETS set TN_PART1 = @nn1, TN_PART2 = @nn2, TN = @nn where ID = @TicketID 
         
         BREAK;
       end
    
    end
  

end

set nocount off
END