CREATE procedure [dbo].[PR_PRORDER_2PROD] 
 @ContextID int, @UserID int, @aMode int
as 
/*
  @aMode 
   1 - to production
   2 - prepare
*/

SET nocount on

if exists (select A.ID from PR_PRORDER A where A.ID = @ContextID and len(ltrim(rtrim(A.NN))) = 0)
begin
  raiserror('Unable to start production with empty order number.',15,0);
  SET nocount off
  return
end  

if exists (select A.ID from PR_PRORDER A where A.ID = @ContextID and A.EXPDATE is null)
begin
  raiserror('Please specify "Planned Date" value.',15,0);
  SET nocount off
  return
end  
  

update PR_PRORDER_T set REVID = (select top 1 C.ID from PR_REVISION C with (nolock) where C.MODELID = PR_PRORDER_T.MODELID and C.S_S = 1000017) 
where PR_PRORDER_T.PRORDERID = @ContextID
  and PR_PRORDER_T.REVID is null
  and (select count(*) from PR_REVISION C with (nolock) where C.MODELID = PR_PRORDER_T.MODELID and C.S_S = 1000017) = 1
/*
if exists (select A.ID from PR_PRORDER_T A 
             join PR_MODELS MDL on MDL.ID = A.MODELID
             join PR_MODELTYPE MDT on MDT.ID = MDL.TYPEID
            where A.PRORDERID = @ContextID and A.QUANTITY > 5000 and isnull(MDT.ACCMODE,0) = 0 )
begin            
  raiserror('Quantity limit of 5000 pieces per line exceeded.',15,0);
  SET nocount off
  return
end  
*/

declare @positionsCount int
select @positionsCount = sum(A.QUANTITY)  
 from PR_PRORDER_T A 
 left join PR_MODELS MDL with (nolock) on MDL.ID = A.MODELID
 left join PR_MODELTYPE MDT with (nolock) on MDT.ID = MDL.TYPEID
where A.PRORDERID = @ContextID 
  and isnull(MDT.ACCMODE,0) = 0 
  and coalesce(MDL.OPERCRMODE,MDT.OPERCRMODE,0) = 0 /* all */
  
if @positionsCount > 5000 and @aMode = 1  
begin            
  raiserror('Quantity limit of 5000 pieces per order exceeded.',15,0);
  SET nocount off
  return
end  


declare @BlockedRevID int
declare @BlockedRevName nvarchar(200)
select @BlockedRevID = R.ID
      ,@BlockedRevName = isnull(R.NAME,'NA')
from PR_PRORDER_T A 
left join PR_REVISION R with (nolock) on R.ID = A.REVID
left join PR_MODELS M with (nolock) on M.ID = R.MODELID
left join PR_MODELTYPE T with (nolock) on T.ID = M.TYPEID
where A.PRORDERID = @ContextID
  and T.DEPARTMENTID <> M.DEPID
  and isnull(R.MTO_APPROVED,0) = 2
if @BlockedRevID is not null
begin
   declare @blockErr nvarchar(max)
   set @blockErr = 'Revision "'+@BlockedRevName+'" is rejected by model type owner. Unable to start production.'
   raiserror(@blockErr,15,0);
   SET nocount off
   return
end  

exec PR_CHECK_OPTIONS @ContextID, @UserID;

/* Supply order */  
declare @toState int
set @toState = 1000042/*in production*/
if @aMode = 2
   set @toState = 1000083/*prepare*/

declare @SupplyOrderID int

declare @SOonly4IO int
declare @SourceNumber nvarchar(100)
declare @SupplyOrderFillMode int

select @SOonly4IO = isnull(B.SUPLORDERONLY4IO,0) 
      ,@SourceNumber = upper(rtrim(A.NN2))
      ,@SupplyOrderID = A.CREATED_BY_SUPPLY
      ,@SupplyOrderFillMode = isnull(B.SUPPLYFILLMODE,0)
from PR_PRORDER A 
left join COM_DEPARTMENTS B with (nolock) on B.ID = A.DEPARTMENTID
where A.ID = @ContextID

if @SOonly4IO = 0 or @SourceNumber like 'IO-%'
begin 
    if @SupplyOrderID is null
    begin
        declare @soFlagMin int  /*KB2028*/
        declare @soFlagMax int
        
        select @soFlagMin = min(isnull(T.DONOTCREATESUPPLYORD,0)), @soFlagMax = max(isnull(T.DONOTCREATESUPPLYORD,0))
        from PR_PRORDER_T A with (nolock)
		left join PR_MODELS M with (nolock) on M.ID = A.MODELID
		left join PR_MODELTYPE T with (nolock) on T.ID = M.TYPEID
        where A.PRORDERID = @ContextID
        
        declare @doNotCreateSO int = 0
        if @soFlagMin = 1 and @soFlagMax = 1
          set @doNotCreateSO = 1
          
        if @doNotCreateSO <> 1
        begin
    
			insert into PR_SUPPLY (S_S,S_CR,S_CDT,GID,ND,DEPARTMENTID,URGENCY,CUSTOMERID,DD,SPREQ,CREATEDBYORDERID,CDD,NN3)
			select @toState,@UserID,getdate(),newid(),isnull(A.NN2,A.NN),A.DEPARTMENTID,A.URGENCY,A.CUSTOMERID,A.EXPDATE,A.SPREQ,A.ID,A.CDD,A.NN3
			from PR_PRORDER A where A.ID = @ContextID
	 
			set @SupplyOrderID = @@IDENTITY  
	        
			if @SupplyOrderFillMode = 1  /*KB1611*/
			begin
			   declare @FirstModelID int
			   select top 1 @FirstModelID = B.MODELID from PR_PRORDER_T B with (nolock) where B.PRORDERID = @ContextID order by B.ID
			   declare @FirstModelQTYSum int
			   select @FirstModelQTYSum = sum(B.QUANTITY) from PR_PRORDER_T B with (nolock) where B.PRORDERID = @ContextID and B.MODELID = @FirstModelID
	           
			   update PR_SUPPLY set MODELID = @FirstModelID, QTY = @FirstModelQTYSum
			   where PR_SUPPLY.ID = @SupplyOrderID
			end
        
        end
    end
end  
    
set @toState = 1000029 /*pend.prod.*/
if @aMode = 2
   set @toState = 1000057/*prepared*/

/* was befor --KB<https://devops.emea.ipg.corp/PDB/PDB/_workitems/edit/6052> 
insert into PR_DEVICE (S_CR,S_CDT,GID,S_S,SN,MODELID,ORDERID,REVID,ORDERROWID,SORDERID,MAPID,RESQUANTITY,ORDQUANTITY,STOREDREADINESS)
select @UserID,getdate(),NEWID(),@toState,substring(convert(varchar(38),NEWID()),1,12),A.MODELID,A.PRORDERID,A.REVID,A.ID,@SupplyOrderID,R.MAPID,1,1,0
from PR_PRORDER_T A
left join PR_MODELS M with (nolock) on M.ID = A.MODELID
left join PR_REVISION R with (nolock) on R.ID = A.REVID
left join PR_MODELTYPE T with (nolock) on T.ID = M.TYPEID
left join COM_NUMBER NB with (nolock) on NB.N > 0 and NB.N <= A.QUANTITY
where A.PRORDERID = @ContextID 
  and isnull(T.ACCMODE,0) in (0,6) /* учет по серийному номеру - генерится столько приборов, сколько заказано */

*/


/* --KB<https://devops.emea.ipg.corp/PDB/PDB/_workitems/edit/6052> */
select @UserID as S_CR,getdate() as S_CDT,NEWID() as GID,@toState as S_S,substring(convert(varchar(38),NEWID()),1,12) as SN,A.MODELID,A.PRORDERID,A.REVID,A.ID,@SupplyOrderID as SORDERID,R.MAPID,1 as RESQUANTITY,1 as ORDQUANTITY,0 as STOREDREADINESS
into #DEVS
from PR_PRORDER_T A
left join PR_MODELS M with (nolock) on M.ID = A.MODELID
left join PR_REVISION R with (nolock) on R.ID = A.REVID
left join PR_MODELTYPE T with (nolock) on T.ID = M.TYPEID
left join COM_NUMBER NB with (nolock) on NB.N > 0 and NB.N <= A.QUANTITY
where A.PRORDERID = @ContextID 
  and isnull(T.ACCMODE,0) in (0,6) /* учет по серийному номеру - генерится столько приборов, сколько заказано */

select top 0 * into #DEVS_2 from #DEVS
--move 100 rows at a time to eliminate fullscan of parent table PR_PRORDER. KB<https://devops.emea.ipg.corp/PDB/PDB/_workitems/edit/6052>
While ( (select count(*) from #DEVS)>0)
Begin
       delete top (100) from #DEVS
       output DELETED.*
       into #DEVS_2

       insert into PR_DEVICE (S_CR,S_CDT,GID,S_S,SN,MODELID,ORDERID,REVID,ORDERROWID,SORDERID,MAPID,RESQUANTITY,ORDQUANTITY,STOREDREADINESS)
       select * from #DEVS_2

       truncate table #DEVS_2
end
drop table #DEVS
drop table #DEVS_2
/* --KB<https://devops.emea.ipg.corp/PDB/PDB/_workitems/edit/6052> */



insert into PR_DEVICE(S_CR,S_CDT,GID,S_S,SN,MODELID,ORDERID,REVID,ORDERROWID,SORDERID,ORDQUANTITY,MAPID,RESQUANTITY,STOREDREADINESS)
select @UserID,getdate(),NEWID(),@toState,substring(convert(varchar(38),NEWID()),1,12),A.MODELID,A.PRORDERID,A.REVID,A.ID,@SupplyOrderID,A.QUANTITY,R.MAPID,A.QUANTITY,0
from PR_PRORDER_T A
left join PR_MODELS M with (nolock) on M.ID = A.MODELID
left join PR_REVISION R with (nolock) on R.ID = A.REVID
left join PR_MODELTYPE T with (nolock) on T.ID = M.TYPEID
where A.PRORDERID = @ContextID 
  and isnull(T.ACCMODE,0) not in (0,6) /* учет по серийному номеру лота + номер внутри лота либо длина - генерится 1 изделие */


exec PR_GEN_NEXT_SN @ContextID;

exec PR_CREATE_OPTIONS @ContextID, @UserID;

/*KB4253*/
update A set A.REMARK = B.REMARK
from PR_DEVICE A 
left join PR_PRORDER_T B with(nolock) on B.ID = A.ORDERROWID
left join PR_MODELS M with(nolock) on M.ID = A.MODELID
left join PR_MODELTYPE T with (nolock) on T.ID = M.TYPEID
where A.ORDERID = @ContextID
  and A.REMARK is null
  and isnull(T.USEREMARKFROMORDER,0) = 1


if @aMode = 2 and not exists (select F.ID from PR_PRORDER_T F where F.PRORDERID = @ContextID and F.REVID is null)
begin
  if exists (select F.ID from PR_PRORDER_T F where F.PRORDERID = @ContextID)
    print '#WThis order allows you to start production' 
end   

exec PR_PLACE_ORDERS3 @ContextID,@UserID
  
  
SET nocount off