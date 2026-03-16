CREATE TABLE [dbo].[VR_REQUEST_VISITORS] (
    [ID]                      INT              IDENTITY (1, 1) NOT NULL,
    [GID]                     UNIQUEIDENTIFIER NOT NULL,
    [S_CR]                    INT              NOT NULL,
    [S_CDT]                   DATETIME         NOT NULL,
    [S_MR]                    INT              NULL,
    [S_MDT]                   DATETIME         NULL,
    [ARC]                     INT              NULL,
    [VNESHID]                 INT              NOT NULL,
    [VISISTOR_NAME]           NTEXT            NOT NULL,
    [EXT_COMPANY_NAME]        NTEXT            NULL,
    [BRANCH_COUNTRY]          NTEXT            NULL,
    [COMPANY]                 NTEXT            NULL,
    [IPG_RELATIONSHIP]        NTEXT            NULL,
    [VISIT_REASON]            NTEXT            NULL,
    [INVITE_FOR_VISA]         INT              NULL,
    [TRAINING_TITLE]          NTEXT            NULL,
    [TRAINING_CONTENT]        NTEXT            NULL,
    [VISITOR_ARRIVED]         INT              NULL,
    [JOB_TITLE]               NVARCHAR (1000)  NULL,
    [IPG_RELATIONSHIP_KB4920] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_VR_REQUEST_VISITORS_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[VR_REQUEST] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_VR_REQUEST_VISITORS]
    ON [dbo].[VR_REQUEST_VISITORS]([VNESHID] ASC);

