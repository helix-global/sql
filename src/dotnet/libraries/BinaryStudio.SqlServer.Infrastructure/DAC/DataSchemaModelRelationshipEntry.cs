using System;
using System.Xml;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    public class DataSchemaModelRelationshipEntry : DataSchemaModelElement
        {
        #region ctor{DataSchemaModel}
        public DataSchemaModelRelationshipEntry(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        //#region M:ReadXmlE(XmlReader,String)
        //protected override void ReadXmlE(XmlReader reader,String localname) {
        //    switch (localname) {
        //        case "References":
        //            {
        //            var r = reader.GetAttribute("Name");
        //            if (String.IsNullOrWhiteSpace(r)) {
        //                //throw new InvalidDataException(@"""Name"" attribute not specified.");
        //                Reference = SqlObjectReference.Missing;
        //                return;
        //                }
        //            var ExternalSource = reader.GetAttribute("ExternalSource");
        //            Reference = new SqlObjectReference(SqlObjectIdentifier.Parse(r),String.Equals(ExternalSource,"BuiltIns"));
        //            return;
        //            }
        //        }
        //    base.ReadXmlE(reader,localname);
        //    }
        //#endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return "{Entry}";
            }
        #endregion
        }
    }
