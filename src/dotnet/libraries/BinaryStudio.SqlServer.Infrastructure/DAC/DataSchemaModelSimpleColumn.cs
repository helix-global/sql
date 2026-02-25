using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlSimpleColumn")]
    [DataSchemaModelSupportedRelationship(nameof(TypeSpecifier))]
    internal class DataSchemaModelSimpleColumn : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsNullable { get; } = true;
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsIdentity { get; } = false;
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String Collation { get; }
        public IDataSchemaModelTypeSpecifier TypeSpecifier { get;private set; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelSimpleColumn(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
            TypeSpecifier = (IDataSchemaModelTypeSpecifier)Relationships[nameof(TypeSpecifier)].Elements[0];
            return;
            }
        #endregion
        }
    }
