CREATE procedure [dbo].[PR_CHECK_OPTIONS] @PrOrderID int, @aUserID int
as 

SET nocount on


declare @OptCode nvarchar(50)
declare @ModelCode nvarchar(50)  
declare @ErrLine int
declare @ErrMsg nvarchar(max)

select top 1 
   @ErrLine = B.ID
  ,@ModelCode = C.CODE
  ,@OptCode = D.CODE
from PR_PRORDER_T A
left join PR_PRORDER_TO B on B.OPID = A.ID
left join PR_MODELS C on C.ID = A.MODELID
left join PR_MODELTYPE_OPTIONS D on D.ID = B.OPTID
where A.PRORDERID = @PrOrderID
  and not exists (select K.ID from PR_MODEL_OPTIONS K where K.MODELID = A.MODELID and K.OPTIONID = B.OPTID)
  
  
if (@ErrLine > 0)
begin
	if dbo.DEF_USERINGROUP3(@aUserID,1114) = 1 /*dep heads & vice*/
	begin
      set @ErrMsg = '#EOption with code "'+@OptCode+'" not applicable to model "'+@ModelCode+'".'
      print @ErrMsg
	end
	else
	begin
      set @ErrMsg = 'Option with code "'+@OptCode+'" not applicable to model "'+@ModelCode+'". Only department head or his/her deputy can start production by this order.'
      raiserror(@ErrMsg,16,0)
    end
end

  
SET nocount off