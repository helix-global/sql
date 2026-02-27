using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlAssembly")]
    [DataSchemaModelSupportedRelationship(nameof(AssemblySources))]
    [DataSchemaModelSupportedRelationship(nameof(Authorizer))]
    [DataSchemaModelSupportedRelationship(nameof(ReferencedAssemblies))]
    internal class DataSchemaModelAssembly : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlAssemblyPermissionSet PermissionSet { get; } = SqlAssemblyPermissionSet.Safe;
        [Relationship("1..*")][UsedImplicitly] public IList<DataSchemaModelAssemblySource> AssemblySources { get; }
        [Relationship("0..*")][UsedImplicitly] public IList<SqlObjectReference> ReferencedAssemblies { get; }
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference Authorizer { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelAssembly(DataSchemaModel Scope)
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
