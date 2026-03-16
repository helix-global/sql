CREATE FUNCTION dbo.COM_ENCODE_BASE64(@inp VARBINARY(MAX))
RETURNS VARCHAR(MAX)
AS
BEGIN
    DECLARE @Base64 VARCHAR(MAX)
   
    /*
        SELECT dbo.f_BinaryToBase64(CONVERT(VARBINARY(MAX), 'Converting this text to Base64...'))
    */
   
    SET @Base64 = CAST(N'' AS XML).value('xs:base64Binary(xs:hexBinary(sql:variable("@inp")))','VARCHAR(MAX)')
   
    RETURN @Base64
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[COM_ENCODE_BASE64] TO [IPG-DOMAIN\IPGL_Integr_MSCRM]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[COM_ENCODE_BASE64] TO [EMEA\DEPCS]
    AS [dbo];

