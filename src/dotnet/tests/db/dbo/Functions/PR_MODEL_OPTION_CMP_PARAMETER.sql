-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date, ,>
-- Description: <Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[PR_MODEL_OPTION_CMP_PARAMETER]
(
    @MODELID int, @OPTIONID int, @PARNAME nvarchar(10)
)
RETURNS nvarchar(200)
AS
BEGIN
    
    declare @parOut nvarchar(200)
    declare @parReq nvarchar(200)
    declare @parBlock nvarchar(200)

    declare @parRet nvarchar(200)

    if exists(select ID
                    from PR_MODEL_OPTION_OVERRIDES O
                    where O.OPTIONID=@OPTIONID and O.MODELID=@MODELID)
        select @parOut=O.CMP_OUT, @parReq=O.CMP_REQ, @parBlock=O.CMP_BLOCK
            from PR_MODEL_OPTION_OVERRIDES O
            where O.OPTIONID=@OPTIONID and O.MODELID=@MODELID
    else
        select @parOut=T.CMP_OUT, @parReq=T.CMP_REQ, @parBlock=T.CMP_BLOCK
            from PR_MODELTYPE_OPTIONS T
                join PR_MODELTYPE_OPTION_GR G on T.OPTGROUP=G.ID
                join PR_MODELS M on G.TYPEID=M.TYPEID
            where M.ID=@MODELID and T.ID=@OPTIONID
        
    if @PARNAME='OUT'
        set @parRet = @parOut 

    if @PARNAME='REQ'
        set @parRet = @parReq 

    if @PARNAME='BLOCK'
        set @parRet = @parBlock 

    return @parRet 

END