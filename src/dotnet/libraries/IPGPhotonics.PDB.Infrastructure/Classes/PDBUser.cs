using System;
using System.Data;
using System.Xml;
using System.Xml.Linq;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    public class PDBUser : PDBObject
        {
        [UsedImplicitly][Field(Source = "FULLNAME")] public String FullName { get; }
        [UsedImplicitly][Field(Source = "GID")]      public Guid UUID { get; }
        [UsedImplicitly][Field(Source = "ID")]       public Int32 ID { get; }
        [UsedImplicitly][Field(Source = "ISGROUP")]  public Boolean IsGroup { get; }

        #region ctor{DataRow}
        public PDBUser(DataRow row)
            : base(row)
            {
            }
        #endregion
        #region ctor{XElement}
        public PDBUser(XElement source)
            {
            FullName = (String)source.Attribute("FullName");
            UUID = (Guid)source.Attribute("UUID");
            ID = (Int32)source.Attribute("ID");
            IsGroup = PropB(source.Attribute("IsGroup"),false);
            }
        #endregion

        #region M:WriteXml(ISqlXmlWriter)
        /// <summary>Converts an object into its XML representation.</summary>
        /// <param name="writer">The <see cref="ISqlXmlWriter"/> stream to which the object is serialized.</param>
        public override void WriteXml(ISqlXmlWriter writer) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            using (writer.ElementGroup("User")) {
                writer.WriteAttribute("FullName",FullName);
                writer.WriteAttribute("UniqueIdentifier",UUID);
                }
            }
        #endregion
        #region M:ToString:String
        public override String ToString()
            {
            return $"{FullName}";
            }
        #endregion
        }
    }
