create procedure [dbo].[SL_REJECT_CHANGE] @aProductID int, @aOptionID int, @aUserID int , @aMode int
as 
set nocount on

if (@aProductID is not null)
begin
   
   insert into SL_REJECTIONS (GID,S_CR,S_CDT,DD,CAPTION,PRODUCTID)
   values (newid(),@aUserID,getdate(),getdate(),'Product rejected',@aProductID) 

end

if (@aOptionID is not null)
begin
   
   insert into SL_REJECTIONS (GID,S_CR,S_CDT,DD,CAPTION,OPTIONID)
   values (newid(),@aUserID,getdate(),getdate(),'Option rejected',@aOptionID) 

end



set nocount off