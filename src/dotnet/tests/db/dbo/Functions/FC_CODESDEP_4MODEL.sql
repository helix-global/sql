CREATE function [dbo].[FC_CODESDEP_4MODEL] (@aModelID int)
returns @res table (ID int)
as 
begin
   /*возвращает ID подразделений, откуда взять коды ошибок/анализа для указанной модели*/

   declare @depID int
   declare @pardepID int
   select @depID = D.ID
         ,@pardepID = D.PARENTDEPARTMENT
   from PR_MODELS B with (nolock)
   left join COM_DEPARTMENTS D on D.ID = B.DEPID
   where B.ID = @aModelID

   insert into @res (ID) values (@depID)
   
   
   /*
   TODO сейчас коды берутся с самого подразделения, чья модель и с родительского (без рекурсии)
   Но надо так: если есть свои - брать свои. Если нет - брать с родителя. Если там нет - брать с родителя родителя.
   */
   if @pardepID is not null
      insert into @res (ID) values (@pardepID)
   

return

end