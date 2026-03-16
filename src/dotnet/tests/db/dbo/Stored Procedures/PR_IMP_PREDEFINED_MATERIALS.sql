-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date,,>
-- Description: <Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PR_IMP_PREDEFINED_MATERIALS] 
    (@predMaterials dbo.RevisionPredefinedMaterial readonly, @revId int, @UserID int)
AS
BEGIN


/*  if exists(select * from @predMaterials where isnull(QUANTITY,0)=0)
    begin

        
        raiserror ('Some records have empty or 0 quantity. Import operation was aborted. Please check Excel file', 16, 0)

        return

    end*/
    
    declare @t table (CODE nvarchar(16) not null, 
                        UCATEGORY nvarchar(200), 
                        QUANTITY decimal(18,6) not null, 
                        TYPICAL2NAV int,
                        OPTIONNAME nvarchar(300),
                        OPERID int not null,
                        MODELID int,
                        OPTIONID int)

    insert into @t (CODE, 
                        UCATEGORY, 
                        QUANTITY, 
                        TYPICAL2NAV,
                        OPTIONNAME,
                        OPERID,
                        MODELID,
                        OPTIONID)
    select CODE, 
            UCATEGORY, 
            QUANTITY, 
            TYPICAL2NAV,
            OPTIONNAME,
            OPERID, 
            null, 
            null
        from @predMaterials

    update @t set MODELID=C.ID
        from @t T
            join PR_NAV_PN_CACHE C on T.CODE=C.CODE
        
    declare @s nvarchar(2000) = ''

    if exists(select * from @t where MODELID is null)
    begin

        select @s= @s + ','  + T.CODE
            from @t T
            where T.MODELID is null

        set @s = 'Codes ' + SUBSTRING(@s,2,len(@s)-1) + ' not found. Import operation was aborted. Please check Excel file'

        
        raiserror (@s, 16, 0)

        return

    end

    update @t set OPTIONID=O.ID
        from @t T
            join PR_MODELTYPE_OPTIONS O on T.OPTIONNAME=O.NAME


    if exists(select * from @t where OPTIONID is null and isnull(OPTIONNAME,'')<>'')
    begin

        select @s= @s + ','  + T.OPTIONNAME
            from @t T
            where OPTIONID is null and isnull(OPTIONNAME,'')<>''

        set @s = 'Options ' + SUBSTRING(@s,2,len(@s)-1) + ' not found. Import operation was aborted. Please check Excel file'
        
        
        raiserror (@s, 16, 0)

        return

    end
    
    insert into PR_REV_PDMU (GID, S_CR, S_CDT, REVID, OPERID, QUANTITY, MID, ONLYOPTION, TYPICAL2NAV, UCATEGORY)
    select NEWID(), @UserID, GETDATE(), @revId, T.OPERID, T.QUANTITY, T.MODELID, T.OPTIONID, T.TYPICAL2NAV, T.UCATEGORY
        from @t T

END