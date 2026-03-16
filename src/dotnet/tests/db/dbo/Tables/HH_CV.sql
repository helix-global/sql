CREATE TABLE [dbo].[HH_CV] (
    [ID]           INT              IDENTITY (1, 1) NOT NULL,
    [GID]          UNIQUEIDENTIFIER NULL,
    [S_CR]         INT              NOT NULL,
    [S_CDT]        DATETIME         NOT NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [ARC]          INT              NULL,
    [NAME]         NVARCHAR (250)   NOT NULL,
    [CONTACT]      NVARCHAR (250)   NULL,
    [PROJECTID]    INT              NOT NULL,
    [REMARK]       NTEXT            NULL,
    [PHOTO]        IMAGE            NULL,
    [INCDATE]      DATETIME         NULL,
    [CONTACTN]     NTEXT            NULL,
    [SHINFO]       NVARCHAR (200)   NULL,
    [S_S]          INT              NOT NULL,
    [INCOMINGFROM] INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_HH_CV_PROJECTID] FOREIGN KEY ([PROJECTID]) REFERENCES [dbo].[HH_PROJECT] ([ID])
);

