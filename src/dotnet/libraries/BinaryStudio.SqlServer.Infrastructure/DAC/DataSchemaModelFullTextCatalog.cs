using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlFullTextCatalog")]
    [DataSchemaModelSupportedRelationship(nameof(Authorizer))]
    internal class DataSchemaModelFullTextCatalog : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsAccentSensitive { get; }
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference Authorizer { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelFullTextCatalog(DataSchemaModel Scope)
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
