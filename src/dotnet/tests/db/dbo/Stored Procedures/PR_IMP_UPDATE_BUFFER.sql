CREATE procedure [dbo].[PR_IMP_UPDATE_BUFFER] @ToDepID int, @PacketID int
WITH EXECUTE AS OWNER , RECOMPILE
as

if @ToDepID <> 275 return

set nocount on

insert into PDB_BUFFER..IPGP_Modules_Diodes(ID,SN,CODE,NAME,Voltage,Wavelength,"NA_10%","Current",Box,Lot,Pout)
SELECT A.ID, A.SN, M.CODE, M.NAME
      ,dbo.PR_DEVICE_PARAM_FLOAT(A.ID,163) as Voltage
      ,dbo.PR_DEVICE_PARAM_FLOAT(A.ID,164) as Wavelength
      ,dbo.PR_DEVICE_PARAM_FLOAT(A.ID,165) as "NA_10%"
      ,dbo.PR_DEVICE_PARAM_FLOAT(A.ID,308) as "Current"
      ,dbo.PR_DEVICE_PARAM_STR(A.ID,166) as Box
      ,dbo.PR_DEVICE_PARAM_STR(A.ID,2922) as Lot
      ,dbo.PR_DEVICE_PARAM_FLOAT(A.ID,162) as Pout
FROM PDB.dbo.PR_DEVICE AS A WITH (nolock) 
LEFT OUTER JOIN PDB.dbo.PR_MODELS AS M WITH (nolock) ON M.ID = A.MODELID
WHERE M.TYPEID = 9 AND A.IMPPACKDEP = 275 /*IPGP-Modules*/
  and not exists (select G.ID from PDB_BUFFER..IPGP_Modules_Diodes G where G.ID = A.ID) 

set nocount off