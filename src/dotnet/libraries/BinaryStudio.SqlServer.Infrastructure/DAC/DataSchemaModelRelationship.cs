using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    public class DataSchemaModelRelationship : DataSchemaModelElement
        {
        public IList<SqlObjectReference> References { get; } = new List<SqlObjectReference>();

        #region ctor{DataSchemaModel}
        public DataSchemaModelRelationship(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion

        #region M:ProcessE(XmlReader,String):Boolean
        protected override Boolean ProcessE(XmlReader reader,String localname) {
            switch (localname) {
                case "Entry":
                    {
                    using (var r = reader.ReadSubtree()) {
                        var o = new DataSchemaModelRelationshipEntry(Scope);
                        o.ReadXml(r);
                        if (o.Reference != null) { References.Add(o.Reference); }
                        foreach (var e in o.Elements) {
                            Elements.Add(e);
                            }
                        }
                    return true;
                    }
                }
            return false;
            }
        #endregion
        }
    }
