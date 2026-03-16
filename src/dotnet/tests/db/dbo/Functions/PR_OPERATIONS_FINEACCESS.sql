CREATE function [dbo].[PR_OPERATIONS_FINEACCESS](@aDepID int, @aMTDepID int, @aUserID int, @aMode int, @aDate datetime)
returns nvarchar(max)
as
begin

declare @res nvarchar(max)
set @res = ''


if dbo.COM_DEP_ACCESS(null,@aDepID,@aMode,@aUserID,@aDate) <> 1
begin
  set @res = 'FullReadOnly;NoAllActions';
  
  /* если свой тип модели показать действия помеченные 'MTOWNER' */
  if dbo.COM_DEP_ACCESS(null,@aMTDepID,@aMode,@aUserID,@aDate) = 1
     set @res = @res+';BypassActionsMarked=MTOWNER';
     
  /*KB2725 ReadOnlyDesigner показывать пункты "Test with..."*/   
  if dbo.COM_DEP_ACCESS(null,@aDepID,8,@aUserID,@aDate) = 1
	set @res = @res+';BypassActionsMarked=allowTest'  /*KB2896*/
	/*set @res = @res+';BypassFineAccessIf=allowTest';*/
	
     
end

if (@aDepID = 190 /*SG*/ and @aMTDepID <> 190/*SG*/)  
begin
  if dbo.COM_USER_DEPARTMENT(@aUserID) not in (348/* IL */)
    set @res = @res+';NoActionsMarked=APPROVE';
   /*TODO как еще сделать ? Когда подразделение по расшаренным моделям создает свои формы на 
     чужой тип моделей, то начальник самого подразделения их утверждает, а в случае SG должен утверждать IL 
     KB1046 */
   
  if @aUserID in (758,21008)  /*KB2014*/
  begin
     set @res = @res+';BypassActionsMarked=APPROVE';
  end
     
end     
	                
if LEN(@res) = 0
   return null
     
return @res  

end;