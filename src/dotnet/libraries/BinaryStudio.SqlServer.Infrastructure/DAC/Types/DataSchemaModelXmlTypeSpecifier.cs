using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlXmlTypeSpecifier")]
    [DataSchemaModelSupportedRelationship(nameof(Type))]
    internal class DataSchemaModelXmlTypeSpecifier : DataSchemaModelElement,IDataSchemaModelTypeSpecifier
        {
        public SqlObjectReference Type { get;private set; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelXmlTypeSpecifier(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
            Type = Relationships[nameof(Type)].References[0];
            }
        #endregion
        #region M:ToString:String
        public override String ToString() {
            var r = new StringBuilder();
            if (Type.IsBultIn) {
                var TypeName = Type.Reference.ObjectName;
                r.Append(TypeName);
                }
            return r.ToString();
            }
        #endregion
        }
    }
