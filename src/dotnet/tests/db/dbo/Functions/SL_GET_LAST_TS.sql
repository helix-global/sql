-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date, ,>
-- Description: <Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[SL_GET_LAST_TS]()
RETURNS binary(8)
AS
BEGIN
    declare @ret binary(8)

    select @ret= MAX(T.TS)
        from (
            select TS from PR_MODELTYPE_OPTION_GR
            union
            select TS from PR_MODELTYPE_OPTIONS
            union
            select TS from PR_MODEL_OPTIONS
            union
            select TS from PR_MODEL_REQOPTIONGR
            union
            select TS from PR_MODELS
            union
            select TS from SL_OPTION_FILES_V
            union
            select TS from SW_TOOL_VERSIONS
            union
            select TS from PR_MODEL_FILES
            ) T

    return @ret
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SL_GET_LAST_TS] TO [IPG-DOMAIN\IPGL_Integr_MSCRM]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SL_GET_LAST_TS] TO [EMEA\DEPCS]
    AS [dbo];

