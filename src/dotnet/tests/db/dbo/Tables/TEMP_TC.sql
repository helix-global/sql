CREATE TABLE [dbo].[TEMP_TC] (
    [ID]     INT           IDENTITY (1, 1) NOT NULL,
    [SOURCE] NVARCHAR (10) NOT NULL,
    CONSTRAINT [CK_Source] CHECK ([SOURCE]='IPGL' AND upper(original_login())='IPG-DOMAIN\D_NORKIN' OR [SOURCE]='IPM' AND upper(original_login())='IPG-DOMAIN\D_NORKIN2')
);

