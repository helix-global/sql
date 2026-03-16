CREATE procedure [dbo].[SL_CHECK_CONFIG] @OrderID int, @aMode int, @aUserID int 
as 

set nocount on
declare @ModelID int;
declare @reqGrID int;
declare @reqGrID2 int;
declare @reqGrID3 int;
declare @reqGrID4 int;
declare @reqGrID5 int;

declare @tmp int;

declare @errMess nvarchar(500);

declare cur cursor local read_only for 
select A.MODELID,RG.OPTIONGRID,RG.OPTIONGRID2,RG.OPTIONGRID3,RG.OPTIONGRID4,RG.OPTIONGRID5
from SL_QUOTE A 
left join SL_REQ_OPTIONS RG on RG.MODELID = A.MODELID 
where A.ID = @OrderID
  and RG.OPTIONGRID is not null

open cur;
WHILE 1=1
BEGIN
   FETCH NEXT FROM cur INTO @ModelID,@reqGrID,@reqGrID2,@reqGrID3,@reqGrID4,@reqGrID5;
   IF @@FETCH_STATUS<>0 BREAK;
   
   set @tmp = -1
   if @reqGrID is not null
   begin
     select @tmp = count(B.ID) from SL_QUOTE_TO B 
				   where B.OPID = @OrderID
				     and B.OPTID in (select O.ID 
					                   from SL_OPTIONS O  with (nolock)
   								      where O.GROUPID in (@reqGrID,@reqGrID2,@reqGrID3,@reqGrID4,@reqGrID5))
	 if @tmp = 0
	 begin
	   select @tmp = count(*) 
	     from PR_MODEL_OPTIONS A with (nolock)
	    where A.MODELID = @ModelID 
		  and isnull(A.PREDEFINEDOPT,0) = 1
		  and A.OPTIONID in (select O.ID 
					           from PR_MODELTYPE_OPTIONS O  with (nolock)
   							  where O.OPTGROUP in (@reqGrID,@reqGrID2,@reqGrID3,@reqGrID4,@reqGrID5))
	 end
	 
   end									  
   if (@tmp = 0)
   begin				  
	 declare @modelname nvarchar(200) 
	 declare @optgrname nvarchar(500) 
	 select @modelname = NAME from PR_MODELS with (nolock) where ID = @ModelID
	 
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


set nocount off