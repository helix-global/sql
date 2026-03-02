using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlSimpleColumn")]
    internal class DataSchemaModelSimpleColumn : DataSchemaModelElement,IDataSchemaModelColumn
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsNullable { get; } = true;
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsIdentity { get; } = false;
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String Collation { get; }
        [Relationship("1..1")][UsedImplicitly] public IDataSchemaModelTypeSpecifier TypeSpecifier { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelSimpleColumn(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
            return;
            }
        #endregion
        }
    }
