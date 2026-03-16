CREATE TABLE [dbo].[COM_ADP_TIMEENTRIES] (
    [ID]         INT            IDENTITY (1, 1) NOT NULL,
    [AOID]       NVARCHAR (100) NOT NULL,
    [ENTRYDATE]  DATE           NOT NULL,
    [DBEG]       DATETIME       NOT NULL,
    [DEND]       DATETIME       NULL,
    [HOURS]      AS             (CONVERT([decimal](10,2),datediff(minute,[DBEG],[DEND]))/(60)),
    [MINUTES]    AS             (datediff(minute,[DBEG],[DEND])),
    [ENTRYID]    NVARCHAR (100) NULL,
    [EMPLOYEEID] INT            NULL,
    CONSTRAINT [PK_COM_ADP_TIMEENTRIES] PRIMARY KEY CLUSTERED ([ID] ASC)
);

