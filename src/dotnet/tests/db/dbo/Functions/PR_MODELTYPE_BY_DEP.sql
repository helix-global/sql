CREATE function [dbo].[PR_MODELTYPE_BY_DEP] (@DepID int, @aUserID int,@aMode int)
returns @res table (ID int)
as 
begin
   /* возвращает типы моделей по которым у указанного подразделения есть модели */

	insert into @res (ID) 
	select distinct A.TYPEID 
	from PR_MODELS A with (nolock) 
	where A.DEPID = @DepID

	return

end