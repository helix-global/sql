using System;
using System.Text;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlXmlTypeSpecifier")]
    internal class DataSchemaModelXmlTypeSpecifier : DataSchemaModelElement,IDataSchemaModelTypeSpecifier
        {
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference Type { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelXmlTypeSpecifier(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
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
