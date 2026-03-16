CREATE function [dbo].[FC_EXT_TRANSLATION_FINEACCESS]( @DocumentID int, @UserID int)
returns nvarchar(max)
as
begin

   declare @res nvarchar(max)
   set @res = ''

   declare @depId int

   select @depId = ENDDEPID
        from FC_EXT_TRANSLATION
        where ID=@DocumentID

   if dbo.COM_DEP_ACCESS2(@depId,5,@UserID,getdate())=0 or @DocumentID=0
        set @res = @res + 'NoActionsMarked=CAN_APPROVE;'

                    
if LEN(@res) = 0
   return null
     
return @res  

end;