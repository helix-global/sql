CREATE procedure [dbo].[SL_CHECK_CONFIG3] @OrderID int, @aMode int, @aUserID int 
as 

set nocount on
declare @qRowID int
declare @ModelID int;
declare @reqGrID int;
declare @reqGrID2 int;
declare @reqGrID3 int;
declare @reqGrID4 int;
declare @reqGrID5 int;

declare @tmp int;
declare @errMess nvarchar(500);


/*проверка допустимости опций*/
declare fff cursor local read_only for 
select 'Option "'+O.NAME+'" ('+O.CODE+') is not compatible with the model "'+M.NAME+'" ('+M.CODE+').' as ERRR
from SL_QUOTE3_T A 
left join SL_QUOTE3_TO B on B.OPOSID = A.ID 
left join SL_MODELS M on M.ID = A.MODELID
left join SL_OPTIONS O on O.ID = B.OPTID
where A.VNESHID = @OrderID
  and B.OPTID is not null
  and not exists (select H.ID from SL_MODEL_OPTIONS H where H.MODELID = A.MODELID and H.OPTIONID = B.OPTID)
open fff;
WHILE 1=1
BEGIN
   FETCH NEXT FROM fff INTO @errMess;
   IF @@FETCH_STATUS<>0 BREAK;
   raiserror(@errMess,15,0);     
END
close fff;
deallocate fff;	 


/*проверка наличия обязательных опций*/
declare cur cursor local read_only for 
select A.ID,A.MODELID,RG.OPTIONGRID,RG.OPTIONGRID2,RG.OPTIONGRID3,RG.OPTIONGRID4,RG.OPTIONGRID5
from SL_QUOTE3_T A 
left join SL_REQ_OPTIONS RG with (nolock) on RG.MODELID = A.MODELID 
where A.VNESHID = @OrderID
  and RG.OPTIONGRID is not null

open cur;
WHILE 1=1
BEGIN
   FETCH NEXT FROM cur INTO @qRowID,@ModelID,@reqGrID,@reqGrID2,@reqGrID3,@reqGrID4,@reqGrID5;
   IF @@FETCH_STATUS<>0 BREAK;
   
   set @tmp = -1
   if @reqGrID is not null
   begin
     select @tmp = count(B.ID) from SL_QUOTE3_TO B 
				   where B.OPOSID = @qRowID
				     and B.QUANTITY > 0
				     and B.OPTID in (select O.ID 
					                   from SL_OPTIONS O  with (nolock)
   								      where O.GROUPID in (@reqGrID,@reqGrID2,@reqGrID3,@reqGrID4,@reqGrID5))
	 if @tmp = 0
	 begin
	   select @tmp = count(*) 
	     from PR_MODEL_OPTIONS A 
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


/*проверка что есть customized модели недопустимые этому заказчику*/
declare @modelErrCust nvarchar(200)

select top 1 @modelErrCust = C.CODE
 from SL_QUOTE3 A
 left join SL_QUOTE3_T B on B.VNESHID = A.ID
 left join SL_MODELS C on C.ID = B.MODELID
where A.ID = @OrderID
  and C.PRTYPE = 2
  and dbo.SL_CHECK_CUSTOMIZED5(C.PRTYPE,C.CUSTOM4GROUP,C.CUSTOM4ID,A.CUSTID) = 0
    
if @modelErrCust is not null
begin
  set @errMess = 'The customized model "'+@modelErrCust+'" is not allowed to use with this customer.'
  raiserror(@errMess,15,0);     
end    

set @modelErrCust = null

/*проверка что есть customized опции недопустимые этому заказчику*/
select top 1 @modelErrCust = C.CODE
 from SL_QUOTE3 A
 left join SL_QUOTE3_T B on B.VNESHID = A.ID
 left join SL_QUOTE3_TO BB on BB.OPOSID = B.ID
 left join SL_OPTIONS C on C.ID = BB.OPTID
where A.ID = @OrderID
  and C.PRTYPE = 2
  and dbo.SL_CHECK_CUSTOMIZED5(C.PRTYPE,C.CUSTOM4GROUP,C.CUSTOM4ID,A.CUSTID) = 0
    
if @modelErrCust is not null
begin
  set @errMess = 'The customized option "'+@modelErrCust+'" is not allowed to use with this customer.'
  raiserror(@errMess,15,0);     
end    

/*проверка блокирующих опций */

declare @checkBlock table (ID int,CODE nvarchar(50), MODELID int, CMP_OUT nvarchar(200), CMP_OUT2 nvarchar(200), CMP_BLOCK nvarchar(200))
insert into @checkBlock (ID,CODE,MODELID,CMP_OUT,CMP_OUT2,CMP_BLOCK)
select C.ID, D.CODE, B.MODELID, D.CMP_OUT, L.CMP_OUT2, D.CMP_BLOCK
from SL_QUOTE3 A with (nolock)
left join SL_QUOTE3_T B on B.VNESHID = A.ID
left join SL_QUOTE3_TO C on C.OPOSID = B.ID
left join SL_OPTIONS D on D.ID = C.OPTID
left join SL_MODEL_OPTIONS L on L.MODELID = B.MODELID and L.OPTIONID = C.OPTID
where A.ID = @OrderID

declare @errOptCode nvarchar(50)

select top 1 @errOptCode = A.CODE 
from @checkBlock A
where A.CMP_BLOCK is not null
  and exists (select B.ID 
                from @checkBlock B
			   where B.MODELID = A.MODELID
			     and B.ID <> A.ID
				 and exists (select * from dbo.COM_STR2TABLE_STR(A.CMP_BLOCK) L where L.ITEM in (select ITEM from dbo.COM_STR2TABLE_STR(B.CMP_OUT) union select ITEM from dbo.COM_STR2TABLE_STR(B.CMP_OUT2) ))
		     )		 
			 
if @errOptCode is not null
begin
  set @errMess = 'Option "'+@errOptCode+'" cannot be used in this configuration. Rule with blocking compatibility parameter defined.'
  raiserror(@errMess,15,0);     
end    



set nocount off