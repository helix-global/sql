CREATE function [dbo].[FC_REPORT_FINEACCESS]( @DocumentID int, @UserID int , @aDate datetime)
returns nvarchar(max)
as
begin

   declare @res nvarchar(max)
   set @res = ''

declare @emplid int = null

declare @ss int
declare @accToDep int
declare @accFromDep int
declare @fromDepID int
declare @toDepID int
declare @toDepType int /*department-suplier*/
declare @mtid int
declare @isExternal int = 0



select @ss = A.S_S
      ,@accToDep = dbo.COM_DEP_ACCESS2(B.DEPID,3,@UserID,@aDate) 
      ,@accFromDep = dbo.COM_DEP_ACCESS2(A.FROMDEPID,3,@UserID,@aDate) 
      ,@fromDepID = A.FROMDEPID
      ,@toDepID = B.DEPID
      ,@toDepType = BD.DEP_SUPP
      ,@mtid = B.TYPEID
    --  , @isExternal = case when A.EXTPARENTID is not null then 1 else 0 end
from FC_REPORT A with (nolock) 
left join PR_MODELS B with (nolock) on B.ID = A.MODELID
left join COM_DEPARTMENTS BD with (nolock) on BD.ID = B.DEPID
where A.ID = @DocumentID

if @accToDep = 0
begin
  if exists (select A.ID from FC_DEPSHARING A with (nolock)
              where A.DEPID = @toDepID 
                and dbo.COM_DEP_ACCESS2(A.ALLOW2DEPID,3,@UserID,@aDate) = 1)
    set @accToDep = 1           

    
   if @accToDep = 0 and @toDepType = 1 /*supplier 120814 разрешено всем, кто FCA заполнять анализ для внешних поставщиков */
       set @accToDep = 1            
end

if @accFromDep = 0
begin
  if @emplid is null
    select @emplid = A.EMPLOYEEID from DEF_USERS A with (nolock) where A.ID = @UserID

  /*подразделение - автор FAR разрешает его править*/
  if exists(select A.ID from FC_DEPSETTINGS A with (nolock)
             where A.DEPID = @fromDepID
               and isnull(A.ALLOWEDIT,0) = 1
               and dbo.COM_DEP_ACCESS2(A.TODEPID,3,@UserID,@aDate) = 1
               and (A.ONLYEMPLID is null or A.ONLYEMPLID = @emplid)
               )
               set @accFromDep = 1
  
end

if @DocumentID < 1
begin
  set @accToDep = 0
  set @accFromDep = 1
end

if (@accToDep = 0 and @accFromDep = 0)
  set @res = @res + ';FullReadOnly;NoAllMarkedActions;'
else
begin

    declare @CanReport int
    declare @CanAnalysis int
    declare @CanApprove int
    declare @CanCancelApprove int

    declare @FR_ARC int
    set @FR_ARC = dbo.DEF_CLASS_ARC(1000111,'fc_report')

    if @accFromDep = 1 and dbo.DEF_F_ACCESS(@FR_ARC,null,6/*create*/,@aDate,@UserID,0) = 1
      set @CanReport = 1
      
    if @accToDep = 1 and dbo.DEF_F_ACCESS(@FR_ARC,null,1000131/*analyzed*/,@aDate,@UserID,0) = 1-- and @isExternal=0
      set @CanAnalysis = 1

    if @accToDep = 1 and dbo.DEF_F_ACCESS(@FR_ARC,null,1000132/*aprove*/,@aDate,@UserID,0) = 1
      set @CanApprove = 1
  
    if @accToDep = 1 and dbo.DEF_F_ACCESS(@FR_ARC,null,1000144/*cancel aprove*/,@aDate,@UserID,0) = 1
      set @CanCancelApprove = 1
      
    if isnull(@CanReport,0) <> 1
       set @res = @res + 'ReadOnlyGroup=1;NoActionsMarked=CAN_SEND;NoActionsMarked=CAN_DELIVERYNOTE;'

    if isnull(@CanAnalysis,0) <> 1
       set @res = @res + 'ReadOnlyGroup=2;NoActionsMarked=CAN_ANALYZE;NoActionsMarked=CAN_RETURN;'

    if isnull(@CanApprove,0) <> 1
       set @res = @res + 'NoActionsMarked=CAN_APPROVE;'

    if isnull(@CanCancelApprove,0) <> 1
       set @res = @res + 'NoActionsMarked=CAN_CANCELAPPROVE;'
       
    if isnull(@CanReport,0) = 1 and @fromDepID = @toDepID
        set @res = @res + 'NoActionsMarked=CAN_SEND;NoActionsMarked=CAN_DELIVERYNOTE;'

    if @fromDepID = @toDepID 
         set @res = @res + 'NoActionsMarked=CAN_RETURN;'
       
    if @DocumentID < 1
       set @res = @res + 'ReadOnlyGroup=2;NoActionsMarked=CAN_ANALYZE;NoActionsMarked=CAN_RETURN;'
       

end      
   
/*
FC_CLOSE_FAR.NOANALYSIS :
1   Close Only For One Department
2   Close All Departments Except One
3   Close Only For Model Type
4   Close All Model Types Except One
*/   

declare @emplDepID int
select @emplDepID = G.DEPID from COM_EMPLOYEE G with (nolock) where G.ID = (select U.EMPLOYEEID from DEF_USERS U with (nolock) where U.ID = @UserID)

if exists (select A.ID from FC_CLOSE_FAR A with (nolock) where A.DEPID = @emplDepID)
begin
    /*есть прямой запрет на тип моделей или отдел*/
    if exists (select A.ID 
                 from FC_CLOSE_FAR A with (nolock)
                where A.DEPID = @emplDepID
                  and A.NOANALYSIS in (1,3) and (A.PARAMDEPID = @toDepID or A.PARAMMTID = @mtid)
               )
    begin
       set @res = @res + 'InvisibleGroup=2;NoActionsMarked=CAN_ANALYZE;'              
    end
    else
    begin
        /* есть запрет на все отделы, и в исключениях нет @toDepID*/
        if exists (select A.ID 
                     from FC_CLOSE_FAR A with (nolock)
                    where A.DEPID = @emplDepID
                      and A.NOANALYSIS = 2
                      and not exists (select B.ID from FC_CLOSE_FAR B with (nolock) where B.DEPID = @emplDepID and B.NOANALYSIS = 2 and B.PARAMDEPID = @toDepID)
                   )
        set @res = @res + 'InvisibleGroup=2;NoActionsMarked=CAN_ANALYZE;'              
        /* есть запрет на все типы моделей, и в исключениях нет @mtid*/
        if exists (select A.ID 
                     from FC_CLOSE_FAR A with (nolock)
                    where A.DEPID = @emplDepID
                      and A.NOANALYSIS = 4
                      and not exists (select B.ID from FC_CLOSE_FAR B with (nolock) where B.DEPID = @emplDepID and B.NOANALYSIS = 4 and B.PARAMMTID = @mtid)
                   )
        set @res = @res + 'InvisibleGroup=2;NoActionsMarked=CAN_ANALYZE;'              
    end 
end


if exists (select B.ID from FC_TRANSIT_DEP B with (nolock) where B.DEPID = @emplDepID and B.FOR_DEPID = @fromDepID )
    set @res = @res + 'BypassActionsMarked=CAN_DELIVERYNOTE;'              
       
declare @rootDepId int
set @rootDepId = dbo.FC_FAR_ROOT_DEPARTMENT(@DocumentID)
if @rootDepId  in (151, 195, 170)
        and dbo.FC_EXT_FAR_ACCESS_FOR_USER(@UserID,5,@rootDepId)=1
    set @res = @res + 'BypassActionsMarked=CAN_REQUEST_EXT;'    
else
    set @res = @res + 'NoActionsMarked=CAN_REQUEST_EXT;' 
    
if @rootDepId  in (151, 195, 170)
        and dbo.FC_EXT_FAR_ACCESS_FOR_USER(@UserID,6,@rootDepId)=1
    set @res = @res + 'BypassActionsMarked=CAN_CANCELAPPROVE;'    
else
    set @res = @res + 'NoActionsMarked=CAN_CANCELAPPROVE;'  
                    
if LEN(@res) = 0
   return null
     
return @res  

end;