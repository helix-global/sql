CREATE procedure [dbo].[REVCH_MODELS_CHANGE_APPLY]
@DocumentID int, @UserID int
as
set nocount on

declare @modelsCount int
declare @mtid int

select 
 @modelsCount = (select count(*) from REVCH_MODEL_MODELS B where B.VNESHID = A.ID)
,@mtid = A.MTID
from REVCH_MODEL A
where A.ID = @DocumentID

if @modelsCount = 0
begin
raiserror('Affected models table is empty. Cannot apply the changing.',16,0)
set nocount off
return
end

if exists (select B.ID
from REVCH_MODEL_MODELS A
left join PR_MODELS B on B.ID = A.MODELID
where A.VNESHID = @DocumentID
and B.TYPEID <> @mtid
)
begin
raiserror('Affected models table contains models from different model type. Cannot apply the changing.',16,0)
set nocount off
return
end


if exists (select B.ID
from REVCH_MODEL_OPTIONS A
left join PR_MODELTYPE_OPTIONS B on B.ID = A.OPTIONID
left join PR_MODELTYPE_OPTION_GR OG on OG.ID = B.OPTGROUP
where A.VNESHID = @DocumentID
and OG.TYPEID <> @mtid
)
begin
raiserror('Options table contains options from different model type. Cannot apply the changing.',16,0)
set nocount off
return
end


if exists (select OG.ID
from REVCH_MODEL_REQOPTIONGR A
left join PR_MODELTYPE_OPTION_GR OG on OG.ID = A.OPTIONGRID
where A.VNESHID = @DocumentID
and OG.TYPEID <> @mtid
)
begin
raiserror('Required Option Groups table contains option groups from different model type. Cannot apply the changing.',16,0)
set nocount off
return
end


if exists (select OG.ID
from REVCH_MODEL_REQOPTIONGR A
left join PR_MODELTYPE_OPTION_GR OG on OG.ID = A.OPTIONGRID2
where A.VNESHID = @DocumentID
and OG.TYPEID <> @mtid
)
begin
raiserror('Required Option Groups table contains option groups from different model type. Cannot apply the changing.',16,0)
set nocount off
return
end


if exists (select OG.ID
from REVCH_MODEL_REQOPTIONGR A
left join PR_MODELTYPE_OPTION_GR OG on OG.ID = A.OPTIONGRID3
where A.VNESHID = @DocumentID
and OG.TYPEID <> @mtid
)
begin
raiserror('Required Option Groups table contains option groups from different model type. Cannot apply the changing.',16,0)
set nocount off
return
end

if exists (select OG.ID
from REVCH_MODEL_REQOPTIONGR A
left join PR_MODELTYPE_OPTION_GR OG on OG.ID = A.OPTIONGRID4
where A.VNESHID = @DocumentID
and OG.TYPEID <> @mtid
)
begin
raiserror('Required Option Groups table contains option groups from different model type. Cannot apply the changing.',16,0)
set nocount off
return
end

if exists (select OG.ID
from REVCH_MODEL_REQOPTIONGR A
left join PR_MODELTYPE_OPTION_GR OG on OG.ID = A.OPTIONGRID5
where A.VNESHID = @DocumentID
and OG.TYPEID <> @mtid
)
begin
raiserror('Required Option Groups table contains option groups from different model type. Cannot apply the changing.',16,0)
set nocount off
return
end

if     not exists (select B.ID from REVCH_MODEL_OPTIONS B where B.VNESHID = @DocumentID)
   and not exists (select B.ID from REVCH_MODEL_REQOPTIONGR B where B.VNESHID = @DocumentID)
   and not exists (select B.ID from REVCH_MODEL_SHARINGR B where B.VNESHID = @DocumentID)
begin
raiserror('The document does not contains any changes. Cannot apply the document.',16,0)
set nocount off
return
end

declare @hasChanges int = 0


if dbo.DEF_USERINGROUP4(@UserID,'DH&VICE',getdate()) = 0
begin
update PR_MODELS set S_S = 1 where ID in (select B.MODELID from REVCH_MODEL_MODELS B where B.VNESHID = @DocumentID) and S_S = 1000016 /*Approved*/
if @@rowcount > 0
print '#IModels should be approved after changings by department head or vice.'
end



if exists (select B.ID from REVCH_MODEL_OPTIONS B where B.VNESHID = @DocumentID)
begin

  delete from PR_MODEL_OPTIONS
  where MODELID in (select B.MODELID from REVCH_MODEL_MODELS B where B.VNESHID = @DocumentID)
    and OPTIONID in (select distinct C.OPTIONID from REVCH_MODEL_OPTIONS C where C.VNESHID = @DocumentID and C.ACTION in (1,100))
  
  insert into PR_MODEL_OPTIONS (GID, S_CR, S_CDT, MODELID, OPTIONID, PREDEFINEDOPT, OVERPTYPE, CMP_OUT2, CUSTOM4GROUP, CUSTOM4ID) 
  select newid(),@UserID,getdate(),A.MODELID,B.OPTIONID,B.PREDEFINEDOPT, B.OVERPTYPE, B.CMP_OUT2, B.CUSTOM4GROUP, B.CUSTOM4ID
  from REVCH_MODEL_OPTIONS B
  left join REVCH_MODEL_MODELS A on A.VNESHID = B.VNESHID
  where B.VNESHID = @DocumentID
    and B.ACTION in (1,2)
  
  
  set @hasChanges = 1

end



if exists (select B.ID from REVCH_MODEL_REQOPTIONGR B where B.VNESHID = @DocumentID)
begin

  delete A  
  from PR_MODEL_REQOPTIONGR A
  inner join REVCH_MODEL_REQOPTIONGR B on B.OPTIONGRID=A.OPTIONGRID and isnull(B.OPTIONGRID2,0)=isnull(A.OPTIONGRID2,0) and isnull(B.OPTIONGRID3,0)=isnull(A.OPTIONGRID3,0) and isnull(B.OPTIONGRID4,0)=isnull(A.OPTIONGRID4,0)and isnull(B.OPTIONGRID5,0)=isnull(A.OPTIONGRID5,0)
  where MODELID in (select B.MODELID from REVCH_MODEL_MODELS B where B.VNESHID = @DocumentID)
    and B.ACTION in (1,100)
  
  insert into PR_MODEL_REQOPTIONGR (GID, S_CR, S_CDT, MODELID, OPTIONGRID, OPTIONGRID2, OPTIONGRID3, OPTIONGRID4, OPTIONGRID5)
  select newid(),@UserID,getdate(),A.MODELID,B.OPTIONGRID, B.OPTIONGRID2, B.OPTIONGRID3, B.OPTIONGRID4, B.OPTIONGRID5
  from REVCH_MODEL_REQOPTIONGR B
  left join REVCH_MODEL_MODELS A on A.VNESHID = B.VNESHID
  where B.VNESHID = @DocumentID
    and B.ACTION in (1,2)
  
  
  set @hasChanges = 1

end



if exists (select B.ID from REVCH_MODEL_SHARINGR B where B.VNESHID = @DocumentID)
begin

  delete from PR_MODEL_SHARINGR
  where MODELID in (select B.MODELID from REVCH_MODEL_MODELS B where B.VNESHID = @DocumentID)
    and DEPARTMENTID in (select distinct C.DEPARTMENTID from REVCH_MODEL_SHARINGR C where C.VNESHID = @DocumentID and C.ACTION in (1,100))
  
  insert into PR_MODEL_SHARINGR (GID, S_CR, S_CDT, MODELID, DEPARTMENTID, RULETYPE)
  select newid(),@UserID,getdate(),A.MODELID,B.DEPARTMENTID,B.RULETYPE
  from REVCH_MODEL_SHARINGR B
  left join REVCH_MODEL_MODELS A on A.VNESHID = B.VNESHID
  where B.VNESHID = @DocumentID
    and B.ACTION in (1,2)
  
  
  set @hasChanges = 1

end



if (@hasChanges = 1)
begin
update PR_MODELS
set S_MR = @UserID, S_MDT=getdate()
where ID in (select B.MODELID from REVCH_MODEL_MODELS B where B.VNESHID = @DocumentID)
end


set nocount off