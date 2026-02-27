using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlTableTypeSimpleColumn")]
    [DataSchemaModelSupportedRelationship(nameof(TypeSpecifier))]
    internal class DataSchemaModelTableTypeSimpleColumn : DataSchemaModelElement,IDataSchemaModelColumn
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsNullable { get; }
        [Relationship("1..1")][UsedImplicitly] public IDataSchemaModelTypeSpecifier TypeSpecifier { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelTableTypeSimpleColumn(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
            }
        #endregion
        }
    }
