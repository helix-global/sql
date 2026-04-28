using System;
using System.Data;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;
    public class PDBDataUnit : PDBObject
        {
        [UsedImplicitly][Field("LABEL")] public String Label { get; }
        [UsedImplicitly][Field("NAME")]  public String Name { get; }
        [UsedImplicitly][Field("MODULEOID")] private Int32 ModuleOID { get; }
        [UsedImplicitly][Field("OID")]  public Int32 OID { get; }
        [UsedImplicitly][Field("GID")]    public Guid UUID { get; }
        [UsedImplicitly][Field("S_CDT")]  public DateTime? CreatedDate  { get; }
        [UsedImplicitly][Field("S_MDT")]  public DateTime? ModifiedDate { get; }
        [UsedImplicitly][Field(Source = "DESCRIPTION")] public String Description { get; }
        [UsedImplicitly][Field(Source = "NATIVECLASS")] public String NativeClassName { get; }
        [UsedImplicitly][Field(Source = "TEXT")] public String Body { get; }
        public PDBUser CreatedBy  { get; }
        public PDBUser ModifiedBy { get; }
        public PDBModule Module { get; }

        #region ctor{DataRow,ISqlObjectResolver<Int32?,PDBUser>,ISqlObjectResolver<Int32?,PDBModule>}
        internal PDBDataUnit(DataRow row,ISqlObjectResolver<Int32?,PDBUser> Users,ISqlObjectResolver<Int32?,PDBModule> modules)
            :base(row)
            {
            CreatedBy  = Users.GetObject(PropSI4(row["S_CR"]));
            ModifiedBy = Users.GetObject(PropSI4(row["S_MR"]));
            Module = modules.GetObject(ModuleOID);
            }
        #endregion

        #region M:WriteXml(ISqlXmlWriter)
        /// <summary>Converts an object into its XML representation.</summary>
        /// <param name="writer">The <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> stream to which the object is serialized.</param>
        public override void WriteXml(ISqlXmlWriter writer) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            using (writer.ElementGroup("DataUnit",URI_META)) {
                writer.WriteAttribute("xmlns","xsi",null,URI_XSINIL);
                writer.WriteAttribute("xmlns","",null,URI_META);
                using (writer.NewLineOnAttribute())
                    {
                    writer.WriteAttribute(nameof(Label),Label);
                    writer.WriteAttribute(nameof(OID),OID);
                    }
                writer.WriteAttribute(nameof(UUID),UUID);
                using (writer.NewLineOnAttribute())
                    {
                    writer.WriteAttribute(nameof(CreatedDate),CreatedDate);
                    }
                writer.WriteAttribute(nameof(ModifiedDate),ModifiedDate);
                using (writer.NewLineOnAttribute())
                    {
                    writer.WriteReference(nameof(CreatedBy),CreatedBy);
                    writer.WriteReference(nameof(ModifiedBy),ModifiedBy);
                    writer.WriteAttribute(nameof(NativeClassName),NativeClassName);
                    }
                writer.WriteCData(nameof(Name),URI_META,Name);
                writer.WriteCData(nameof(Description),URI_META,Description);
                writer.WriteCData(nameof(Body),URI_META,Body);
                }
            }
        #endregion
        #region M:ToString():String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return $"{Label}";
            }
        #endregion
        }
    }
