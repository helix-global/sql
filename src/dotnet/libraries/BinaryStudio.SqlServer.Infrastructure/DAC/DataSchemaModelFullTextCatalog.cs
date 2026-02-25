using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlFullTextCatalog")]
    [DataSchemaModelSupportedRelationship("Authorizer")]
    internal class DataSchemaModelFullTextCatalog : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsAccentSensitive { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelFullTextCatalog(DataSchemaModel Scope)
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
