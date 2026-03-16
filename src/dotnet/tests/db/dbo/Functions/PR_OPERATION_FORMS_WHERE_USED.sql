CREATE function [dbo].[PR_OPERATION_FORMS_WHERE_USED] (@aMode int, @aObjectID int, @aUserID int )
returns @res table (ID int)
as 
begin
/*
  @aMode 1 - поиск форм, где используется параметр (@aObjectID - ID параметра)
         2 - BOM item (@aObjectID - ID BOM position)
*/

  declare @mtid int
  declare @id int = @aObjectID
  
  if @aMode = 1
  begin
  
	  select @mtid = A.TYPEID
	  from PR_MODELTYPE_PARAMS A with (nolock)
	  where A.ID = @aObjectID

	  insert into @res (ID)
	  select A.ID 
	  from PR_OPERATIONS A with (nolock)
	  where A.MTID = @mtid
		and cast(FORMXML as xml).exist('/Form/Item[@Type="sfiValue"][@Link=sql:variable("@id")]') =1 

  end
  else if @aMode = 2
  begin
  
	  select @mtid = A.MTID
	  from PR_MODELTYPE_BOM A with (nolock)
	  where A.ID = @aObjectID

	  insert into @res (ID)
	  select A.ID 
	  from PR_OPERATIONS A with (nolock)
	  where A.MTID = @mtid
		and cast(FORMXML as xml).exist('/Form/Item[@Type="sfiItem"][@Link=sql:variable("@id")]') =1 

  end



  return

end