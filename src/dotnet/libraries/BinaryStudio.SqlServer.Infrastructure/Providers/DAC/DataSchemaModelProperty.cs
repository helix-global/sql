using System;
using System.IO;
using System.Xml;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    public class DataSchemaModelProperty : DataSchemaModelElement
        {
        [SqlObjectFieldMapping] public String Value { get;private set; }
        public Boolean? QuotedIdentifiers { get;private set; }
        public Boolean? AnsiNulls { get;private set; }

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
                    QuotedIdentifiers = PropB(reader.GetAttribute(nameof(QuotedIdentifiers)));
                    AnsiNulls = PropB(reader.GetAttribute(nameof(AnsiNulls)));
                    Value = reader.ReadElementContentAsString();
                    return;
                    }
                }
            base.ReadXmlE(reader, localname);
            }
        #endregion
        }
    }
