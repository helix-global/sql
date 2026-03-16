CREATE function [dbo].[IE_FIND_WHERE_SN] (@FindText nvarchar(max), @UserID int)
returns @res table (ID int)
as 
begin
                      
   insert into @res (ID)
   select B.ID
   from IE_IEITEMS A with (nolock)
   left join IE_IE B with (nolock) on B.ID = A.VNESHID
   where A.SN = @FindText
              
   insert into @res (ID)
   select B.ID
   from IE_IEITEMS A with (nolock)
   left join IE_IE B with (nolock) on B.ID = A.VNESHID
   left join PR_DEVICE C with (nolock) on C.ID = A.DEVICEID
   where C.SN = @FindText
           
              
                      
   return
    
end