-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date, ,>
-- Description: <Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[PR_REQUIRED_REPORTS_PRINTED]
(
    @operId int
)
RETURNS int
AS
BEGIN

    declare @ret int = 1
    declare @barCodePrint int
    declare @devvid int

    select @barCodePrint=isnull(OP.PRINT_BARCODE,0)
          ,@devvid = O.DEVICEID
        from PR_OPERATION O with(nolock)
            join PR_OPERATIONS OP with(nolock) on O.OPERTYPEID=OP.ID
        where O.ID=@operId
    

    if exists(select *
                from PR_OPERATION_REQ_REPORTS R
                where R.REPORTID not in (select P.REPORTID
                                        from PR_PRINTED_REPORTS P
                                        where P.OPERID=@operId)
                        and R.OPERTYPEID in (select O.OPERTYPEID
                                                from PR_OPERATION O
                                                where O.ID=@operId)
                        and dbo.PR_REPORT_USING5(R.REPORTID,@devvid,@operId) = 1 /*KB3352*/
                        )
        set @ret=0


    if @barCodePrint=1 and not exists(select *
                                        from PR_PRINTED_REPORTS P
                                        where P.OPERID=@operId and P.REPORTID=-1)
        set @ret=0

    return @ret
END