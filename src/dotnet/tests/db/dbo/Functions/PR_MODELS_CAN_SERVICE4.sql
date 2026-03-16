

create function [dbo].[PR_MODELS_CAN_SERVICE4] (@aDepID int, @aServMapID int)
returns @res table (MODELID int, CUSTOMERID int)
as 
begin

 /*
 ver.2 отбирает с учетом выбранной сервисной карты (если она выбрана)
 */
 
  if @aServMapID is not null or @aServMapID = 0
  begin
     declare @mapMTID int
     select @mapMTID = A.MTID from PR_MAP A with (nolock) where A.ID = @aServMapID

     insert into @res (MODELID, CUSTOMERID)
     select S.MODELID, S.CUSTOMERID
     from dbo.PR_MODELS_CAN_SERVICE3(@aDepID) S
	   left join PR_MODELS A with (nolock) on A.ID=S.MODELID
	   where A.TYPEID = @mapMTID
     
  end
  else
  begin
     insert into @res (MODELID, CUSTOMERID)
     select MODELID, CUSTOMERID from dbo.PR_MODELS_CAN_SERVICE3(@aDepID)
  end   
  
  return

end