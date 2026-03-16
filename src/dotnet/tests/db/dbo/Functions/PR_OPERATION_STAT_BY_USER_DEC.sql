CREATE function [dbo].[PR_OPERATION_STAT_BY_USER_DEC](@OperID int, @aMode int, @now datetime, @userId int)
returns decimal(12,4)
as
begin

/*
@aMode
1 - sum elapsed
2 - завершено рапортом о ошибке
3 - завершено с ошибками
4 - Wait Time
10 - Man-Hour
11 - sum elapsed until now
14 - Wait Time until copletition
20 - duration KB3548
30 - duration, но сумма всех таких-же операций по изделию при производстве (сервис не учит.) KB3548
40 - duration KB4040
50 - duration, но сумма всех таких-же операций по изделию при производстве (сервис не учит.) KB4040
*/

declare @res decimal(12,4)
declare @dbeg datetime
declare @dend datetime
declare @ss int

if @aMode = 1
begin

select @res = SUM(coalesce(A.ELAPSEDCORR,A.ELAPSED_D,A.ELAPSED))
from PR_OPERATION_TIME A with (nolock) where A.OPERID = @OperID and (@userId is null or A.USERID=@userId)

return @res
end
else if @aMode = 2
begin

select @ss = A.S_S from PR_OPERATION A with (nolock) where A.ID = @OperID
if @ss in (1000038,1000079)
return 1

return 0

end
else if @aMode = 3
begin

select @ss = A.S_S from PR_OPERATION A with (nolock) where A.ID = @OperID
if @ss in (1000019)
return 1

return 0

end
else if @aMode = 4
begin

select @dbeg = A.S_CDT from PR_OPERATION A with (nolock) where A.ID = @OperID
select @dend = min(A.DBEG) from PR_OPERATION_TIME A with (nolock) where A.OPERID = @OperID and (@userId is null or A.USERID=@userId)

return datediff(mi,@dbeg,@dend)

end
else if @aMode = 14
begin

select @dbeg = A.S_CDT, @dend = ISNULL(A.COMPLETED_DT,@now) from PR_OPERATION A with (nolock) where A.ID = @OperID

return datediff(mi,@dbeg,@dend)

end
else if @aMode = 10
begin

select @res = isnull(D.MANHOUR2,C.MANHOUR)
from PR_OPERATION A with (nolock)
left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
left join PR_OPERATIONS C with (nolock) on C.ID = A.OPERTYPEID
left join PR_REV_OVER_MH D with (nolock) on D.REVID = B.REVID and D.OPERID = C.ID
where A.ID = @OperID

return @res

end
else if @aMode = 11
begin

select @res = SUM( case when A.DEND is not null then coalesce(A.ELAPSEDCORR,A.ELAPSED_D,A.ELAPSED) else dbo.PR_WORKTIME3(A.ID,@now) end)
from PR_OPERATION_TIME A with (nolock) where A.OPERID = @OperID and (@userId is null or A.USERID=@userId)

return @res
end
else if @aMode = 20
begin

	select @res = sum(datediff(s,A.DBEG,isnull(A.DEND,getdate()))) 
	from PR_OPERATION_TIME A with (nolock) where A.OPERID = @OperID and (@userId is null or A.USERID=@userId)

	return @res / 60.0
	
end
else if @aMode = 30
begin

    declare @devID int
    declare @opertypeID int
    declare @orderID int
    
    select @devId = A.DEVICEID
      ,@opertypeID = A.OPERTYPEID
      ,@orderID = A.ORDERID
      from PR_OPERATION A with(nolock)
      where A.ID = @OperID

	select @res = sum(datediff(s,A.DBEG,isnull(A.DEND,getdate()))) 
	from PR_OPERATION_TIME A with (nolock) 
	where A.OPERID in (select B.ID from PR_OPERATION B with(nolock) 
	                    where B.DEVICEID = @devID
	                      and B.ORDERID = @orderID
	                      and B.OPERTYPEID = @opertypeID)
	  and (@userId is null or A.USERID=@userId)

	return @res  / 60.0
	
end

else if @aMode = 40
begin

	select @res = sum(isnull(A.ELAPSED,0)) 
	from PR_OPERATION_TIME A with (nolock) where A.OPERID = @OperID and (@userId is null or A.USERID=@userId)

	return @res 
	
end
else if @aMode = 50
begin

    declare @devID_4040 int
    declare @opertypeID_4040 int
    declare @orderID_4040 int
    
    select @devId_4040 = A.DEVICEID
      ,@opertypeID_4040 = A.OPERTYPEID
      ,@orderID_4040 = A.ORDERID
      from PR_OPERATION A with(nolock)
      where A.ID = @OperID

	select @res = sum(isnull(A.ELAPSED,0)) 
	from PR_OPERATION_TIME A with (nolock) 
	where A.OPERID in (select B.ID from PR_OPERATION B with(nolock) 
	                    where B.DEVICEID = @devID_4040
	                      and B.ORDERID = @orderID_4040
	                      and B.OPERTYPEID = @opertypeID_4040)
	  and (@userId is null or A.USERID=@userId)

	return @res 
	
end



return null
end;