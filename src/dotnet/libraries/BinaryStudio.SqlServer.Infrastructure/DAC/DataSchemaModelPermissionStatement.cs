using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlPermissionStatement")]
    internal class DataSchemaModelPermissionStatement : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlPermission Permission { get; }
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference Grantee { get; }
        [Relationship("0..1")][UsedImplicitly] public SqlObjectReference Grantor { get; }
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference SecuredObject { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelPermissionStatement(DataSchemaModel Scope)
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
