CREATE TABLE [dbo].[COM_SYSSETTINGS] (
    [ID]        INT              IDENTITY (1, 1) NOT NULL,
    [LABEL]     NVARCHAR (100)   NOT NULL,
    [DESC]      NVARCHAR (200)   NULL,
    [USERID]    INT              NULL,
    [VNESHID]   INT              NULL,
    [VNESHOID]  INT              NULL,
    [VNESHGID]  UNIQUEIDENTIFIER NULL,
    [VALUESTR]  NVARCHAR (MAX)   NULL,
    [VALUEINT]  INT              NULL,
    [VALUEDATE] DATETIME         NULL
);

