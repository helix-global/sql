using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Xml;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    public class DataSchemaModelProperty : DataSchemaModelElement
        {
        [DataSchemaModelAttributeMapping] public String Value { get;private set; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelProperty(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:ReadXmlE(XmlReader,String)
        protected override void ReadXmlE(XmlReader reader,String localname) {
            switch (localname) {
                case "Value":
                    {
                    if (Value != null) { throw new InvalidDataException($@"""Value"" attribute already specified for ""{GetType().Name}""."); }
                    Value = reader.ReadElementContentAsString();
                    return;
                    }
                }
            base.ReadXmlE(reader, localname);
            }
        #endregion
        }
    }
