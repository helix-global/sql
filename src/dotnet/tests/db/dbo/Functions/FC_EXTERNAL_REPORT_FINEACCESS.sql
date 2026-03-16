CREATE function [dbo].[FC_EXTERNAL_REPORT_FINEACCESS]( @DocumentID int, @aS_S int, @UserID int , @aDate datetime)
returns nvarchar(max)
as
begin

declare @res nvarchar(max)
set @res = ''
/*
if (@aS_S = 2130021 /*generated*/) 
   set @res = 'ReadOnlyGroup=1;ReadOnlyGroup=2;NoAllMarkedActions;'
else    
*/
set @res = 'FullReadOnly;NoAllMarkedActions;'

if (@aS_S = 2130021 /*generated*/) 
begin
   declare @efarToDepAcc int
   declare @efarToDepID int
   
   select @efarToDepAcc = dbo.COM_DEP_ACCESS2(A.EXTREQDEPID,3,@UserID,@aDate) 
         ,@efarToDepID = A.EXTREQDEPID
   from FC_REPORT A with (nolock) 
   where A.ID = @DocumentID

   if isnull(@efarToDepAcc,0) = 0
   begin
       if exists (select A.ID from FC_DEPSHARING A with (nolock)
                   where A.DEPID = @efarToDepID
                     and dbo.COM_DEP_ACCESS2(A.ALLOW2DEPID,3,@UserID,@aDate) = 1)
	   set @efarToDepAcc = 1
   end


   if @efarToDepAcc = 1
   begin
       declare @FR_ARC int
       set @FR_ARC = dbo.DEF_CLASS_ARC(1000111,'fc_report')

       if dbo.DEF_F_ACCESS(@FR_ARC,null,1000131/*analyzed*/,@aDate,@UserID,0) = 1
          set @res = 'ReadOnlyGroup=1;NoAllMarkedActions;'
          
   end
end   

               
if (@aS_S = 1000104/*approved*/)
   set @res = @res + 'BypassActionsMarked=CAN_PRINTAREPORT;'
   

declare @rootDepId int
set @rootDepId = dbo.FC_FAR_ROOT_DEPARTMENT(@DocumentID)
    
if @rootDepId  in (151, 195, 170)
        and dbo.FC_EXT_FAR_ACCESS_FOR_USER(@UserID,6,@rootDepId)=1
    set @res = @res + 'BypassActionsMarked=CAN_CANCELAPPROVE;'    
else
    set @res = @res + 'NoActionsMarked=CAN_CANCELAPPROVE;'  
    

if LEN(@res) = 0
   return null
     
return @res  

end;