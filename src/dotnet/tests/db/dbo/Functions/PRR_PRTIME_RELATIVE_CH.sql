CREATE FUNCTION [dbo].[PRR_PRTIME_RELATIVE_CH] (@aDepID int, @aMode int,@aMonths int)
RETURNS 
@RES TABLE 
(
        REVID int
        ,YY int 
        ,MM int
        ,MMDELTA int
        ,QTY int  /*produced month */
        ,AVG_ELAPSED decimal(16,2) /*avg. elapsed */
)
AS
BEGIN

	declare @dend date = getdate()
	set @dend = dbo.COM_ENCODE_DATE(year(@dend),MONTH(@dend),1)
	declare @dbeg date = dateadd(month,-@aMonths,@dend)
	set @dbeg = dbo.COM_ENCODE_DATE(year(@dbeg),MONTH(@dbeg),1)

	declare @inclChilds bit = 1
	if (@aMode = 2)
		set @inclChilds = 0

	insert into @RES (REVID,YY,MM,QTY,AVG_ELAPSED)
	select REVID
		  ,year(COMPLETED_DT)
		  ,MONTH(COMPLETED_DT)
		  ,sum(QTY)
		  ,case when sum(QTY) > 0 then SUM(ELAPSED) / sum(QTY) else 0 end
	from (
	select A.REVID
		,A.COMPLETED_DT
		,isnull(A.RESQUANTITY,1) as QTY
		,(select SUM(coalesce(AA.ELAPSEDCORR,AA.ELAPSED_D,AA.ELAPSED)) 
			from PR_OPERATION_TIME AA with (nolock) 
			left join PR_OPERATION BB with (nolock) on BB.ID = AA.OPERID
			where BB.DEVICEID = A.ID 
			and BB.ORDERID = A.ORDERID) as ELAPSED
	from PR_DEVICE A with(nolock)
	left join PR_PRORDER B with(nolock) on B.ID = A.ORDERID
	where A.COMPLETED_DT >= @dbeg
	  and A.COMPLETED_DT < @dend    
	  and isnull(B.ORDERTYPE,0) = 0
	  and B.DEPARTMENTID in (select ID from dbo.COM_GETCHILD_DEPARTMENTS4(@aDepID,@inclChilds)) 
	  and A.REVID is not null
	) M  
	group by REVID,year(COMPLETED_DT),MONTH(COMPLETED_DT)
    
    update @RES set MMDELTA = DATEDIFF(month,@dbeg,dbo.COM_ENCODE_DATE(YY,MM,2))
    
    RETURN 
END