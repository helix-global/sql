using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlPermissionStatement")]
    internal class DataSchemaModelPermissionStatement : DataSchemaModelElement
        {
        [PropertyMapping][UsedImplicitly] public SqlPermission Permission { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsAllPrivileges { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsWithGrantOption { get; }
        [PropertyMapping][UsedImplicitly] public SqlPermissionAction PermissionAction { get; }
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
