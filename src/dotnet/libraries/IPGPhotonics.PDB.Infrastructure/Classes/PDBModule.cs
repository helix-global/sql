using System;
using System.Data;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    public class PDBModule : PDBObject
        {
        [UsedImplicitly][Field(Source = "NAME")]   public String Name { get; }
        [UsedImplicitly][Field(Source = "LABEL")]  public String Label { get; }
        [UsedImplicitly][Field(Source = "REMARK")] public String Remark { get; }
        [UsedImplicitly][Field(Source = "OID")]    public Int32 OID { get; }
        [UsedImplicitly][Field(Source = "GID")]    public Guid UUID { get; }
        [UsedImplicitly][Field(Source = "S_CDT")]  public DateTime? CreatedDate  { get; }
        [UsedImplicitly][Field(Source = "S_MDT")]  public DateTime? ModifiedDate { get; }
        public PDBUser CreatedBy  { get; }
        public PDBUser ModifiedBy { get; }

        #region ctor{ISqlObjectResolver<Int32?,User>,DataRow}
        public PDBModule(ISqlObjectResolver<Int32?,PDBUser> Users,DataRow row)
            : base(row)
            {
            CreatedBy  = Users.GetObject(PropSI4(row["S_CR"]));
            ModifiedBy = Users.GetObject(PropSI4(row["S_MR"]));
            }
        #endregion

        #region M:WriteXml(XmlWriter)
        /// <summary>Converts an object into its XML representation.</summary>
        /// <param name="writer">The <see cref="T:System.Xml.XmlWriter"/> stream to which the object is serialized.</param>
        public override void WriteXml(XmlWriter writer) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            using (writer.ElementGroup("Module",URI_META)) {
                writer.WriteAttributeString("xmlns","xsi",null,URI_XSINIL);
                writer.WriteAttributeString("xmlns","",null,URI_META);
                writer.WriteAttribute(true,"Label",Label);
                writer.WriteAttribute(true,"OID",OID);
                writer.WriteAttribute("UUID",UUID);
                writer.WriteAttribute(true,"CreatedDate",CreatedDate);
                writer.WriteAttribute("ModifiedDate",ModifiedDate);
                writer.WriteReference(true,"CreatedBy",CreatedBy);
                writer.WriteReference(true,"ModifiedBy",ModifiedBy);
                writer.WriteCDATA("Module.Name",URI_META,(CDATA)Name);
                if (!String.IsNullOrEmpty(Remark)) {
                    writer.WriteCDATA("Module.Description",URI_META,(CDATA)Remark);
                    }
                }
            }
        #endregion
        #region M:ToString():String
        public override String ToString()
            {
            return $"{Label}";
            }
        #endregion
        }
    }
