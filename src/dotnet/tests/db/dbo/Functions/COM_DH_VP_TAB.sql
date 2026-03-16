CREATE function [dbo].[COM_DH_VP_TAB] (@UserID int, @dBeg date, @dEnd date, @aMode int)
returns @res table (ID int not null)
as 
begin
             

			 
declare @emplid int
set @emplid = dbo.DEF_EMPLOYEE(@UserID)
                
                
   insert into @res (ID)
   select A.ID
   from COM_VACATION A with (nolock)
  where A.DBEG < @dEnd
    and isnull(A.DEND,A.DBEG) >= @dBeg 
    and A.EMPLID in (select K.EMPLID 
                       from COM_DH_VP_SETTINGS_T K with (nolock) 
                       left join COM_DH_VP_SETTINGS L with (nolock) on L.ID = K.VNESHID
                       where L.CODE = @aMode)
    and exists (select P.ID from COM_DH_VP_SETTINGS P with (nolock) where P.DEFAULT4EMPLID = @emplid or @emplid = 1)

                
   return
    
end