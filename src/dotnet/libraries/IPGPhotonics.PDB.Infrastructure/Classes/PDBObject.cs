using System;
using System.Data;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure
    {
    public class PDBObject : SqlObject
        {
        public const String URI_META  = "urn:schemas.ipg.corp:pdb:metadata";
        public const String URI_CTRL  = "urn:schemas.ipg.corp:pdb:control";

        #region ctor
        public PDBObject()
            {
            }
        #endregion
        #region ctor{DataRow}
        public PDBObject(DataRow row)
            : base(row)
            {
            }
        #endregion
        }
    }