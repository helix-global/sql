CREATE TABLE [dbo].[temp_f_report_history] (
    [id]                  INT            IDENTITY (1, 1) NOT NULL,
    [department_id]       INT            NULL,
    [record_id]           INT            NULL,
    [preliminary]         INT            NULL,
    [report_nr]           VARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
    [model_id]            INT            NULL,
    [sn]                  VARCHAR (40)   COLLATE Latin1_General_CI_AS NULL,
    [rma]                 VARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [customer_id]         INT            NULL,
    [date_of_return]      DATE           NULL,
    [failure_description] VARCHAR (1000) COLLATE Latin1_General_CI_AS NULL,
    [failure_analysis]    VARCHAR (1000) COLLATE Latin1_General_CI_AS NULL,
    [action_points]       VARCHAR (1000) COLLATE Latin1_General_CI_AS NULL,
    [issue_date]          DATE           NULL,
    [issued_by_id]        INT            NULL,
    [approved_by]         VARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
    [remark]              VARCHAR (400)  COLLATE Latin1_General_CI_AS NULL
);

