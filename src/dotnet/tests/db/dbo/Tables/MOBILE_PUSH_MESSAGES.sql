CREATE TABLE [dbo].[MOBILE_PUSH_MESSAGES] (
    [ID]             INT             IDENTITY (1, 1) NOT NULL,
    [TOUSERID]       INT             NOT NULL,
    [TITLE]          VARCHAR (200)   NULL,
    [BODY]           VARCHAR (MAX)   NULL,
    [DOCOID]         INT             NULL,
    [DOCID]          INT             NULL,
    [CR_DT]          DATETIME        DEFAULT (getdate()) NULL,
    [LASTSEND_DT]    DATETIME        NULL,
    [ISSENDED]       BIT             NULL,
    [CANCELED]       BIT             NULL,
    [CANCELREASON]   NVARCHAR (1024) NULL,
    [EMPLNAME]       NVARCHAR (250)  NULL,
    [PAYLOADCOMMAND] VARCHAR (50)    NULL,
    CONSTRAINT [PK_MOBILE_PUSH_MESSAGES] PRIMARY KEY CLUSTERED ([ID] ASC)
);

