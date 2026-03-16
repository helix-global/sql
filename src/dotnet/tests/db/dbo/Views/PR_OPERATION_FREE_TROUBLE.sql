create view PR_OPERATION_FREE_TROUBLE with schemabinding as
select A.ID,A.OPERTYPEID,A.TRMAPID 
  from dbo.PR_OPERATION A 
where A.FREETR = 1 /* free */
  and A.S_S = 1000013 /* completed */ 
  and A.TRTYPE = 1 /* srv.map */
GO
CREATE UNIQUE CLUSTERED INDEX [IX_PR_OPERATION_FREE_TROUBLE]
    ON [dbo].[PR_OPERATION_FREE_TROUBLE]([ID] ASC, [OPERTYPEID] ASC, [TRMAPID] ASC);

