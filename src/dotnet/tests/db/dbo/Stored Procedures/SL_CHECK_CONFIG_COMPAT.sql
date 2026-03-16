CREATE procedure [dbo].[SL_CHECK_CONFIG_COMPAT] @DocID int, @aMode int, @aUserID int 
as 
/*KB2600 проверка совместимости если включен режим совместимости */
set nocount on

declare @CheckID int
declare @CompatMode int
declare @modelsCount int

select @CheckID = A.ID
      ,@CompatMode = isnull(A.COMPATMODE,0) 
      ,@modelsCount = (select count(distinct MODELID) from SL_QUOTE2_T J with (nolock) where J.VNESHID = A.ID) 
from SL_QUOTE2 A with (nolock)
where A.ID = @DocID


if @CheckID is not null and @CompatMode = 1 and @modelsCount > 1
begin
  /*
    логика реализована в подсчете кол-ва правил совместимости между моделями в конфигурации
    если нет ни одной модкли с 0 в кол-ве правил - все хорошо
    если модель только одна - тоже хорошо ?? (можно отключить выше @modelsCount если не нужно)    
  */

  declare @CompatCheck table (MODELID int not null, COMPAT_QTY int not null, QTROWID int not null)
  
  insert into @CompatCheck (MODELID,COMPAT_QTY,QTROWID)
  select A.MODELID,0,A.ID
  from SL_QUOTE2_T A
  where A.VNESHID = @CheckID
  
  declare @oneModelID int
  declare @oneRowID int
  declare @compatWith table (QTROWID int not null)

  declare cur cursor local read_only for 
  select MODELID,QTROWID from @CompatCheck
  open cur 
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM cur INTO @oneModelID,@oneRowID;
      IF @@FETCH_STATUS<>0 BREAK;

      delete from @compatWith
      
      insert into @compatWith (QTROWID)
      select A.QTROWID
      from @CompatCheck A
      where A.QTROWID <> @oneRowID
        and dbo.SL_ROWS_ARE_COMPATIBLE(A.QTROWID,@oneRowID) = 1
        
      if exists (select QTROWID from @compatWith)
      begin
        
        update @CompatCheck set COMPAT_QTY = COMPAT_QTY + 1
        where QTROWID in (select QTROWID from @compatWith 
                          union all 
                          select @oneRowID)
      
      end   
        
  END
  close cur;
  deallocate cur;
  
  declare @err nvarchar(max) = null

  select top 1 @err = '"'+B.NAME+'" (' + B.CODE+')'
  from @CompatCheck A
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  where A.COMPAT_QTY = 0
  order by A.QTROWID desc
  
  if @err is not null
  begin
    set @err = '#EModel '+@err+' is not compatible with other models in configuration.'
    raiserror(@err,16,0)
  end
  

end

set nocount off