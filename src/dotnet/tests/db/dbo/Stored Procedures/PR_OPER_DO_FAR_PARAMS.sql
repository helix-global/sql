CREATE procedure [dbo].[PR_OPER_DO_FAR_PARAMS] @OperID int, @UserID int
as 
SET nocount on

declare @farid int
declare @mtid int

select @farid = isnull(A.FAILUREREPORTID,B.FAILUREREPORTID)
      ,@mtid = D.TYPEID
from PR_OPERATION A with (nolock)
left join PR_OPERATION B with (nolock) on B.ID = A.PARENTID
left join PR_DEVICE C with (nolock) on C.ID = A.DEVICEID
left join PR_MODELS D with (nolock) on D.ID = C.MODELID
where A.ID = @OperID

if @farid is null
begin
  SET nocount off
  return
end

declare @now datetime
set @now = getdate()

declare @prmID int
declare @prmType int
declare @toprmID int
declare @pValue sql_variant
declare @hideError int

declare curPrms cursor local read_only for 
select A.PARAMID,A.SETVALUE,A.SETPARAMID,A.HIDECONVERT
  from FC_FAR_FROM_PRMS A with (nolock)
 where A.MTID = @mtid
   and exists (select B.ID from PR_OPERATION_PARAMS B with (nolock) where B.OPERID = @OperID and B.PARAMID = A.PARAMID)
 
open curPrms;
WHILE 1=1
BEGIN
   FETCH NEXT FROM curPrms INTO @prmID,@prmType,@toprmID,@hideError;
   IF @@FETCH_STATUS<>0 BREAK;
   
   /* @prmType enum 1000109
	1000	FAR Additional Parameter
	1	Incoming Inspection Text
	2   Operation Time (hours)
   */
   select @pValue = B.PVALUE
   from PR_OPERATION_PARAMS B with (nolock) where B.OPERID = @OperID and B.PARAMID = @prmID
   
   if @prmType = 1000
   begin
   
     update FC_REPORT_PARAMS set PVALUE = @pValue, S_MR = @UserID, S_MDT = @now where FRID = @farid and PARAMID = @toprmID
     if @@rowcount = 0
       insert into FC_REPORT_PARAMS (GID,S_CR,S_CDT,PVALUE,FRID,PARAMID) values (newid(),@UserID,@now,@pValue,@farid,@toprmID)
     
     update FC_REPORT set S_MR = @UserID, S_MDT = @now where FC_REPORT.ID = @farid
     
   end
   else if @prmType = 1
   begin
   
      update FC_REPORT set S_MR = @UserID, S_MDT = @now, RESULT_INC_INSP = cast(@pValue as nvarchar(1000)) where FC_REPORT.ID = @farid
      
   end
   else if @prmType = 2
   begin
   
      declare @newOpTime decimal(12,1)
      set @newOpTime = null
      if @hideError = 1
      begin
        declare @pStr nvarchar(100)
        declare @prop sql_variant
        set @prop = SQL_VARIANT_PROPERTY(@pValue,'BaseType')
        declare @propS nvarchar(100)
        set @propS = cast(@prop as nvarchar(100))
        set @propS = upper(@propS)
        if @propS = 'FLOAT' or @propS = 'DECIMAL'
        begin
           set @newOpTime = cast(@pValue as decimal(12,1))
        end
        else
        begin
			--print @prmID
			set @pStr = cast(@pValue as nvarchar(100))
			set @pStr = REPLACE(@pStr,',','.')
			--print @pStr
			if (isnumeric(@pStr) = 1)
			   set @newOpTime = cast(@pStr as decimal(12,1))
			else
			   print '#WCannot convert given value to the "Operation Time" value.'
		end
      end
      else
        set @newOpTime = cast(@pValue as decimal(12,1))
        
      if @newOpTime is not null
      begin
         update FC_REPORT set S_MR = @UserID, S_MDT = @now, OPERTIME = @newOpTime where FC_REPORT.ID = @farid
      end   
      
   end
   
END
close curPrms;
deallocate curPrms;
	 

SET nocount off