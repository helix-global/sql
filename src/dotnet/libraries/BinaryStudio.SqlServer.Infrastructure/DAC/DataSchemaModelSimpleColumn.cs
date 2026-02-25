using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlSimpleColumn")]
    internal class DataSchemaModelSimpleColumn : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsNullable { get; } = true;
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsIdentity { get; } = false;
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String Collation { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelSimpleColumn(DataSchemaModel Scope)
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
