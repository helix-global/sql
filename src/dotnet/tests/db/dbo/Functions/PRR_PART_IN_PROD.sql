CREATE function [dbo].[PRR_PART_IN_PROD](@aEmplID int, @YYYY int, @MM int)
returns int
as
begin

  declare @res int
  
  declare @dd datetime = dbo.COM_ENCODE_DATE(@YYYY, @MM, 1)
  declare @dend datetime = dateadd(day,-1,dateadd(month,1,@dd))
  
  if not exists (select A.ID from COM_EMPL_PARTINPROD A with (nolock) where A.PARTINPRODUCTION is not null and A.EMPLID = @aEmplID and A.DD >= @dd and A.DD <= @dend)
  begin
  
	  select top 1 @res = A.PARTINPRODUCTION 
	  from COM_EMPL_PARTINPROD A with (nolock)
	  where A.PARTINPRODUCTION is not null
    and A.EMPLID = @aEmplID
		and A.DD <= @dd
	  order by A.EMPLID, A.DD desc
  
  end
  else
  begin  
      
	  select @res = avg(RES)
	  from (  
	  select A.DDATE
			,(select top 1 B.PARTINPRODUCTION from COM_EMPL_PARTINPROD B with (nolock) where B.PARTINPRODUCTION is not null and B.EMPLID = @aEmplID and B.DD <= A.DDATE order by B.DD desc) as RES
	  from dbo.COM_DAY_PERIOD(@dd,@dend) A 
	  ) M
	  
  end
  
  return isnull(@res,100);
  
end;