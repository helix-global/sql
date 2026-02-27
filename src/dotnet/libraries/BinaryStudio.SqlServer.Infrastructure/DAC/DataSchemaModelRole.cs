using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlRole")]
    [DataSchemaModelSupportedRelationship(nameof(Authorizer))]
    internal class DataSchemaModelRole : DataSchemaModelElement
        {
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference Authorizer { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelRole(DataSchemaModel Scope)
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
