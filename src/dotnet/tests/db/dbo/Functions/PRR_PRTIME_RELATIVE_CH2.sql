CREATE FUNCTION [dbo].[PRR_PRTIME_RELATIVE_CH2] (@aDepID int, @aMode int,@aMonths int,@modelTypes nvarchar(max))
RETURNS 
@RES TABLE 
(
        REVID int
        ,YY int 
        ,MM int
        ,MMDELTA int
        ,QTY int  /*produced month */
        ,AVG_ELAPSED decimal(16,4) /*avg. elapsed per 1 item*/
        ,ELAPSED decimal(16,2) /* AVG_ELAPSED * QTY */
        ,FIRST_AVG_ELAPSED decimal(16,4)   /*AVG_ELAPSED с самого раннего месяца*/
        ,ELAPSED_N decimal(16,2) /* FIRST_AVG_ELAPSED * QTY */ 
        ,DIFF_PR decimal(16,1) /* процент */
        ,FIRST_YYMM date  /*месяц из которого взят FIRST_AVG_ELAPSED*/
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
	  and (@modelTypes is null or A.MODELID in (select LL.ID from PR_MODELS LL with(nolock) where LL.TYPEID in (select ID from dbo.COM_STR2TABLE_INT(@modelTypes))))
	) M  
	group by REVID,year(COMPLETED_DT),MONTH(COMPLETED_DT)
    
    update @RES set MMDELTA = DATEDIFF(month,@dbeg,dbo.COM_ENCODE_DATE(YY,MM,2))
					,ELAPSED = AVG_ELAPSED * QTY
					,FIRST_AVG_ELAPSED = (select top 1 B.AVG_ELAPSED from @RES B where B.REVID = "@RES".REVID and B.AVG_ELAPSED > 0 order by B.YY, B.MM)
					,FIRST_YYMM = (select top 1 dbo.COM_ENCODE_DATE(B.YY,B.MM,1) from @RES B where B.REVID = "@RES".REVID and B.AVG_ELAPSED > 0 order by B.YY, B.MM)
					
    update @RES set ELAPSED_N = FIRST_AVG_ELAPSED * QTY
		
	update @RES set DIFF_PR = case when ELAPSED_N > 0 then (ELAPSED/ELAPSED_N) * 100 - 100 end
    
    RETURN 
END