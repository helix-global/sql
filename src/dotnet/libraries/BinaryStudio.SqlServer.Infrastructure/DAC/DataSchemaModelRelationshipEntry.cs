using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Xml;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    public class DataSchemaModelRelationshipEntry : DataSchemaModelElement
        {
        public SqlObjectReference Reference { get;private set; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelRelationshipEntry(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:ProcessE(XmlReader,String):Boolean
        protected override Boolean ProcessE(XmlReader reader,String localname) {
            switch (localname) {
                case "References":
                    {
                    var r = reader.GetAttribute("Name");
                    if (String.IsNullOrWhiteSpace(r)) { throw new InvalidDataException(@"""Name"" attribute not specified."); }
                    var ExternalSource = reader.GetAttribute("ExternalSource");
                    Reference = new SqlObjectReference(SqlObjectIdentifier.Parse(r),String.Equals(ExternalSource,"BuiltIns"));
                    return true;
                    }
                //case "Element":
                //    {
                //    var r = reader.GetAttribute("Name");
                //    if (String.IsNullOrWhiteSpace(r)) { throw new InvalidDataException(@"""Name"" attribute not specified."); }
                //    Reference = SqlObjectIdentifier.Parse(r);
                //    return true;
                //    }
                }
            return false;
            }
        #endregion
        }
    }
