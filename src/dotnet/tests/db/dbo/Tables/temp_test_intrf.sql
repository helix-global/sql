CREATE TABLE [dbo].[temp_test_intrf] (
    [OID]            INT            NOT NULL,
    [CAPTION]        NVARCHAR (100) NOT NULL,
    [COMMAND]        NVARCHAR (400) NULL,
    [PARENTOID]      INT            NOT NULL,
    [WORKSPACEGROUP] NVARCHAR (100) NULL,
    [WORKSPACECOUNT] INT            NULL,
    [ONLYIFQUERY]    INT            NULL,
    [INTRFNAME]      NVARCHAR (100) NULL,
    [INTRFOID]       INT            NULL,
    [WSBCOLOR]       INT            NULL,
    [NEWNAME]        NVARCHAR (150) NULL,
    [NEWCOMMAND]     NVARCHAR (454) NULL
);

