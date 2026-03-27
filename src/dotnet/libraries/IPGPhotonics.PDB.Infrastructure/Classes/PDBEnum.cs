using System;
using System.Collections.Generic;
using System.Data;
using System.Xml;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    public class PDBEnum : PDBObject
        {
        public IList<PDBEnumValue> Values { get; }
        [UsedImplicitly][Field("OID")]       public Int32 OID { get; }
        [UsedImplicitly][Field("NAME")]      public String Name { get; }
        [UsedImplicitly][Field("LABEL")]     public String Label { get; }
        [UsedImplicitly][Field("MODULEOID")] private Int32 ModuleOID { get; }
        [UsedImplicitly][Field(Source = "S_CDT")]  public DateTime? CreatedDate  { get; }
        [UsedImplicitly][Field(Source = "S_MDT")]  public DateTime? ModifiedDate { get; }
        [UsedImplicitly][Field(Source = "GID")]    public Guid UUID { get; }
        public PDBUser CreatedBy  { get; }
        public PDBUser ModifiedBy { get; }

        #region ctor{ISqlObjectResolver<Int32?,PDBUser>,DataRow}
        internal PDBEnum(ISqlObjectResolver<Int32?,PDBUser> users,DataRow source,IDictionary<Int32,IList<DataRow>> values)
            :base(source)
            {
            CreatedBy  = users.GetObject(PropSI4(source["S_CR"]));
            ModifiedBy = users.GetObject(PropSI4(source["S_MR"]));

            Values = new List<PDBEnumValue>();
            try
                {
                if (values.TryGetValue(OID,out var rows)) {
                    foreach (var row in rows) {
                        var o = new PDBEnumValue(users,row);
                        Values.Add(o);
                        }
                    }
                }
            finally
                {
                Values = Values.AsReadOnly();
                }
            }
        #endregion

        #region M:WriteXml(XmlWriter)
        /// <summary>Converts an object into its XML representation.</summary>
        /// <param name="writer">The <see cref="T:System.Xml.XmlWriter"/> stream to which the object is serialized.</param>
        public override void WriteXml(XmlWriter writer) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            using (writer.ElementGroup("Enum",URI_META)) {
                writer.WriteAttributeString("xmlns","xsi",null,URI_XSINIL);
                writer.WriteAttributeString("xmlns","",null,URI_META);
                writer.WriteAttribute(true,"Label",Label);
                writer.WriteAttribute(true,"OID",OID);
                writer.WriteAttribute("UUID",UUID);
                writer.WriteAttribute(true,"CreatedDate",CreatedDate);
                writer.WriteAttribute("ModifiedDate",ModifiedDate);
                writer.WriteReference(true,"CreatedBy",CreatedBy);
                writer.WriteReference(true,"ModifiedBy",ModifiedBy);
                writer.WriteCDATA("Enum.Name",URI_META,(CDATA)Name);
                //if (!String.IsNullOrEmpty(Remark)) {
                //    writer.WriteCDATA("Module.Description",URI_META,(CDATA)Remark);
                //    }
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