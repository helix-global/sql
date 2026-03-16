-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date, ,>
-- Description: <Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[PR_PROCESS_MACROS]
(
    @text nvarchar(4000), @deviceId int, @forFile bit
)
RETURNS nvarchar(4000)
AS
BEGIN
    declare @ret nvarchar(4000)

    declare @SN nvarchar(50)
            , @MODEL_NAME nvarchar(200)
            , @MODEL_CODE nvarchar(16)
            , @MODEL_DESCRIPTION nvarchar(300)
            , @REVISION_NAME nvarchar(200)
            , @MODEL_GROUP_NAME nvarchar(200)
            , @CUSTOMER_NAME nvarchar(100)
            , @COUNTRY_NAME nvarchar(100)

    select @SN=ISNULL(D.SN,''), 
        @MODEL_NAME=ISNULL(M.NAME,''), 
        @MODEL_CODE=ISNULL(M.CODE, ''), 
        @MODEL_DESCRIPTION=ISNULL(M.DESCSTR,''), 
        @REVISION_NAME=ISNULL(R.NAME,''), 
        @MODEL_GROUP_NAME=ISNULL(G.NAME,''), 
        @CUSTOMER_NAME=ISNULL(C.NAME,''), 
        @COUNTRY_NAME=ISNULL(CR.NAME,'')
    from PR_DEVICE D
        left join PR_MODELS M on D.MODELID=M.ID
        left join PR_MODELTYPE T on M.TYPEID=T.ID
        left join PR_REVISION R on D.REVID=R.ID
        left join PR_MODEL_GROUP G on M.MODELGROUPID = G.ID
        left join PR_SUPPLY S on D.SORDERID=S.ID
        left join COM_CUSTOMER C on S.CUSTOMERID=C.ID
        left join COM_COUNTRIES CR on C.COUNTRY=CR.ID
    where D.ID=@deviceId


    declare @dateNow datetime = getdate()
    declare @dateStr nvarchar(8) = RIGHT(CAST(YEAR(@dateNow) as nvarchar(4)),2) +
                                    CASE WHEN LEN(CAST(MONTH(@dateNow) as nvarchar(2)))=1 then '0' else '' END + CAST(MONTH(@dateNow) as nvarchar(2)) +
                                    CASE WHEN LEN(CAST(DAY(@dateNow) as nvarchar(2)))=1 then '0' else '' END + CAST(DAY(@dateNow) as nvarchar(2))


    set @ret = @text
    set @ret = replace(@ret,'@SN@',@SN)
    set @ret = replace(@ret,'@Model@',@MODEL_NAME)
    set @ret = replace(@ret,'@ModelCode@',@MODEL_CODE)
    set @ret = replace(@ret,'@ModelDescription@',@MODEL_DESCRIPTION)
    set @ret = replace(@ret,'@RevisionName@',@REVISION_NAME)
    set @ret = replace(@ret,'@Now@',CONVERT(nvarchar(10),getdate(),104))
    set @ret = replace(@ret,'@NowYYMMDD@',@dateStr)
    set @ret = replace(@ret,'@ModelGroup@',@MODEL_GROUP_NAME)
    set @ret = replace(@ret,'@Customer@',@CUSTOMER_NAME)
    set @ret = replace(@ret,'@CustomerCountry@',@COUNTRY_NAME)

    if @forFile=1
    begin
        set @ret = REPLACE( REPLACE( REPLACE( REPLACE( @ret, '!', '' ), '#', '' ), '$', '' ), '&', '' )
        if len(@ret)>200
            set @ret = SUBSTRING(@ret,1,200)
    end

    return @ret
END