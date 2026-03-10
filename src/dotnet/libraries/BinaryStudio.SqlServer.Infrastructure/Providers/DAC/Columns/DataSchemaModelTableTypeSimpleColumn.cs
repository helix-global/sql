using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlTableTypeSimpleColumn")]
    internal class DataSchemaModelTableTypeSimpleColumn : DataSchemaModelElement,IDataSchemaModelColumn
        {
        [PropertyMapping][UsedImplicitly] public Boolean IsNullable { get; }
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
