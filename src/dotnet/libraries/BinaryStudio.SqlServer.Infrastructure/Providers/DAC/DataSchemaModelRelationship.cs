using System;
using System.Xml;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    public class DataSchemaModelRelationship : DataSchemaModelElement
        {
        //public IList<SqlObjectReference> References { get; } = new List<SqlObjectReference>();

        #region ctor{DataSchemaModel}
        public DataSchemaModelRelationship(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion

        #region M:ReadXmlE(XmlReader,String)
        protected override void ReadXmlE(XmlReader reader,String localname) {
            switch (localname) {
                case "Entry":
                    {
                    using (var r = reader.ReadSubtree()) {
                        var o = new DataSchemaModelRelationshipEntry(Scope);
                        o.ReadXml(r);
                        References.AddRange(o.References);
                        Annotations.AddRange(o.Annotations);
                        Elements.AddRange(o.Elements);
                        }
                    return;
                    }
                }
            base.ReadXmlE(reader,localname);
            }
        #endregion
        }
    }
