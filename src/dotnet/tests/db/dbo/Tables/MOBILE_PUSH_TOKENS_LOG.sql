CREATE TABLE [dbo].[MOBILE_PUSH_TOKENS_LOG] (
    [ID]           INT           IDENTITY (1, 1) NOT NULL,
    [DeviceID]     VARCHAR (50)  NOT NULL,
    [Token]        VARCHAR (250) NOT NULL,
    [UserName]     VARCHAR (50)  NOT NULL,
    [OSname]       VARCHAR (50)  NULL,
    [OSver]        VARCHAR (50)  NULL,
    [Manufacturer] VARCHAR (50)  NULL,
    [Model]        VARCHAR (250) NULL,
    [DeviceName]   VARCHAR (250) NULL,
    [InsertDT]     DATETIME      DEFAULT (getdate()) NOT NULL,
    [UserID]       INT           NOT NULL,
    CONSTRAINT [PK_Table_PUSH_LOG_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);

