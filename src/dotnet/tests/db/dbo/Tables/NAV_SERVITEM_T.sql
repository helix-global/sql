CREATE TABLE [dbo].[NAV_SERVITEM_T] (
    [ID]                  INT            IDENTITY (1, 1) NOT NULL,
    [S_CR]                INT            NULL,
    [S_CDT]               DATETIME       NULL,
    [S_MR]                INT            NULL,
    [S_MDT]               DATETIME       NULL,
    [VNESHID]             INT            NOT NULL,
    [type]                NVARCHAR (50)  NULL,
    [number]              NVARCHAR (50)  NULL,
    [description]         NVARCHAR (300) NULL,
    [quantity]            NVARCHAR (50)  NULL,
    [linediscountpercent] NVARCHAR (50)  NULL,
    [warranty]            NVARCHAR (50)  NULL,
    [warrantyfairdealing] NVARCHAR (50)  NULL,
    [applicableoption]    NTEXT          NULL,
    CONSTRAINT [FK_NAV_SERVITEM_T_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[NAV_SERVITEM] ([ID]) ON DELETE CASCADE
);

