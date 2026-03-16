CREATE procedure [dbo].[PR_CHECK_ORDER] @OrderID int, @aMode int, @aUserID int 
as 

set nocount on
declare @ordRowID int;
declare @modID int;
declare @reqGrID int;
declare @reqGrID2 int;
declare @reqGrID3 int;
declare @reqGrID4 int;
declare @reqGrID5 int;

declare @tmp int;
declare @orderN nvarchar(50)

declare @errMess nvarchar(500);

/*
declare @now datetime;
set @now = GETDATE()
*/

declare @OrderDepID int
select @OrderDepID = A.DEPARTMENTID
      ,@orderN = A.NN
  from PR_PRORDER A with (nolock)
  where A.ID = @OrderID
  
if @orderN <> ltrim(rtrim(@orderN))
begin
   update PR_PRORDER set NN = ltrim(rtrim(NN)) where ID = @OrderID
end  
  
declare @ErrModelCode nvarchar(200)
set @ErrModelCode = null

select top 1 @ErrModelCode = B.CODE
from PR_PRORDER_T A with (nolock)
left join PR_MODELS B with (nolock) on B.ID = A.MODELID
where A.PRORDERID = @OrderID
  and A.MODELID not in (select G.ID from dbo.PR_MODELS_CAN_PRODUCE(@OrderDepID) G)
  
if @ErrModelCode is not null   
begin
     set @errMess = 'Model "'+@ErrModelCode+'" cannot be produced in this department.'
     raiserror(@errMess,15,0);     
     set nocount off
     return
end

declare cur cursor local read_only for 
select A.ID,A.MODELID,RG.OPTIONGRID,RG.OPTIONGRID2,RG.OPTIONGRID3,RG.OPTIONGRID4,RG.OPTIONGRID5
from PR_PRORDER_T A 
left join PR_MODEL_REQOPTIONGR RG with (nolock) on RG.MODELID = A.MODELID 
where A.PRORDERID = @OrderID
open cur;
WHILE 1=1
BEGIN
   FETCH NEXT FROM cur INTO @ordRowID,@modID,@reqGrID,@reqGrID2,@reqGrID3,@reqGrID4,@reqGrID5;
   IF @@FETCH_STATUS<>0 BREAK;
   
   
   set @tmp = -1
   if @reqGrID is not null
   begin
     select @tmp = count(B.ID) from PR_PRORDER_TO B 
				   where B.OPID = @ordRowID 
				     and B.OPTID in (select O.ID 
					                   from PR_MODELTYPE_OPTIONS O  with (nolock)
   								      where O.OPTGROUP in (@reqGrID,@reqGrID2,@reqGrID3,@reqGrID4,@reqGrID5))
	 if @tmp = 0
	 begin
	   select @tmp = count(*) 
	     from PR_MODEL_OPTIONS A 
	    where A.MODELID = @modID 
		  and isnull(A.PREDEFINEDOPT,0) = 1
		  and A.OPTIONID in (select O.ID 
					           from PR_MODELTYPE_OPTIONS O  with (nolock)
   							  where O.OPTGROUP in (@reqGrID,@reqGrID2,@reqGrID3,@reqGrID4,@reqGrID5))
	 end
	 
   end									  
   if (@tmp = 0)
   begin				  
	 declare @modelname nvarchar(200) 
	 declare @optgrname nvarchar(200) 
	 select @modelname = NAME from PR_MODELS with (nolock) where ID = @modID
	 
	 select @optgrname = NAME from PR_MODELTYPE_OPTION_GR with (nolock) where ID = @reqGrID
	 if @reqGrID2 is not null
	   select @optgrname = @optgrname +',' + NAME from PR_MODELTYPE_OPTION_GR with (nolock) where ID = @reqGrID2
	 if @reqGrID3 is not null
	   select @optgrname = @optgrname +',' + NAME from PR_MODELTYPE_OPTION_GR with (nolock) where ID = @reqGrID3
	 if @reqGrID4 is not null
	   select @optgrname = @optgrname +',' + NAME from PR_MODELTYPE_OPTION_GR with (nolock) where ID = @reqGrID4
	 if @reqGrID5 is not null
	   select @optgrname = @optgrname +',' + NAME from PR_MODELTYPE_OPTION_GR with (nolock) where ID = @reqGrID5
	 
	 set @errMess = 'The model "'+@modelname+'" requires one option from group(s): '+@optgrname+'.'
     raiserror(@errMess,15,0);     
   end
   
END
close cur;
deallocate cur;	 

declare @c2OptCode nvarchar(50)
declare @c2OptName nvarchar(250)
declare @c2BomName nvarchar(250)

declare cur2 cursor local read_only for 
select C.CODE, C.NAME, K.NAME
from PR_PRORDER_T A
left join PR_PRORDER_TO B on B.OPID = A.ID
left join PR_MODELTYPE_OPTIONS C with (nolock) on C.ID = B.OPTID
left join PR_MODELTYPE_OPTION_GR_T F with (nolock) on F.VNESHID = C.OPTGROUP
left join PR_MODELTYPE_BOM K with (nolock) on K.ID = F.BOMITEMID
where A.PRORDERID = @OrderID
  and F.BOMITEMID is not null
  and not exists (select FF.PARTMODELID from dbo.PR_ORDERROW_BOM_MODELS(A.ID) FF where FF.BOMID = F.BOMITEMID and FF.PARTMODELID is not null )
open cur2;
WHILE 1=1
BEGIN
   FETCH NEXT FROM cur2 INTO @c2OptCode,@c2OptName,@c2BomName
   IF @@FETCH_STATUS<>0 BREAK;

   set @errMess = 'The option "'+@c2OptName+'" ('+@c2OptCode+') requires the model specified for BOM item: '+@c2BomName+'.'
   raiserror(@errMess,15,0);     

END
close cur2;
deallocate cur2;	 

exec PR_CHECK_ORDER_COMP_OPTIONS @OrderID, @aUserID

set nocount off