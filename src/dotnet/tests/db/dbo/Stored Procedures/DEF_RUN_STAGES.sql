CREATE PROCEDURE [dbo].[DEF_RUN_STAGES]
    (@DocumentID int
        , @DocOID int
        , @UserID int
        , @MethodOID int
        , @UpdateKind int
        , @UpdateKindStr nvarchar(100)
        , @MethodRemark nvarchar(1000)
        , @StagesType int =2 /*1 - before, 2 - after*/)
AS
BEGIN
    

declare @params nvarchar(4000)

set @params = N'@DocumentID int, @DocOID int, @UserID int, @MethodOID int, @UpdateKind int, @UpdateKindStr nvarchar(100), ' +
        N'@MethodRemark nvarchar(1000), @ContextID int, @RowID int, @WasCopiedFromID int'

declare @stages table (SQLTEXT nvarchar(max))

declare @ContextID int = @DocumentID
declare @RowID int = @DocumentID
declare @WasCopiedFromID int = -1

--set xact_abort on
--begin tran
    
    if @StagesType = 1
    begin
        insert into @stages
        select S.SQLTEXT
            from DEF_STAGES S
                where S.CLASSOID=@DocOID
                    and S.STAGETYPE=4
                order by S.SORTORDER
    end
    
    
    if @StagesType = 2
    begin
        insert into @stages
        select S.SQLTEXT
            from DEF_STAGES S
                where S.CLASSOID=@DocOID
                    and S.STAGETYPE in(5,2,3,1)
                order by case S.STAGETYPE when 5 then 1
                                        when 2 then 2
                                        when 3 then 3
                                        when 1 then 4 end,
                                S.SORTORDER
    end


    declare @sql nvarchar(max)

    declare cur_stages cursor for
    select SQLTEXT from @stages
                    
    open cur_stages

    fetch next from cur_stages into @sql

    while @@fetch_status=0
    begin
        
        EXECUTE sp_executesql @sql, @params, @DocumentID
            , @DocOID
            , @UserID
            , @MethodOID
            , @UpdateKind
            , @UpdateKindStr
            , @MethodRemark
            , @ContextID
            , @RowID
            , @WasCopiedFromID
    
         fetch next from cur_stages into @sql
    end

    close cur_stages
    deallocate cur_stages

--commit



END