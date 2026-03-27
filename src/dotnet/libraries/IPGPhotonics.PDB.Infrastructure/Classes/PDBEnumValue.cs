using System;
using System.Data;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    public class PDBEnumValue : PDBObject
        {
        [UsedImplicitly][Field("CODE")] public Int32 Code { get; }
        [UsedImplicitly][Field("NAME")] public String Name { get; }
        [UsedImplicitly][Field("OID")]  public Int32 OID { get; }
        [UsedImplicitly][Field(Source = "S_CDT")]  public DateTime? CreatedDate  { get; }
        [UsedImplicitly][Field(Source = "S_MDT")]  public DateTime? ModifiedDate { get; }
        public PDBUser CreatedBy  { get; }
        public PDBUser ModifiedBy { get; }

        #region ctor{ISqlObjectResolver<Int32?,PDBUser>,DataRow}
        internal PDBEnumValue(ISqlObjectResolver<Int32?,PDBUser> Users,DataRow row)
            :base(row)
            {
            CreatedBy  = Users.GetObject(PropSI4(row["S_CR"]));
            ModifiedBy = Users.GetObject(PropSI4(row["S_MR"]));
            }
        #endregion

        #region M:ToString():String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return $"{Name}";
            }
        #endregion
        }
    }