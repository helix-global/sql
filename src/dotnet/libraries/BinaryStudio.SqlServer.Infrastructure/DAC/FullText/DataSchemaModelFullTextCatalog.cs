using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlFullTextCatalog")]
    internal class DataSchemaModelFullTextCatalog : DataSchemaModelElement
        {
        [PropertyMapping][UsedImplicitly] public Boolean IsAccentSensitive { get; }
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
