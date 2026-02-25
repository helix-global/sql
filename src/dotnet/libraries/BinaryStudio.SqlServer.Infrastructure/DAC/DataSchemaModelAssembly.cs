using System;
using System.Collections.Generic;
using System.Text;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlAssembly")]
    [DataSchemaModelSupportedRelationship("AssemblySources")]
    [DataSchemaModelSupportedRelationship("Authorizer")]
    internal class DataSchemaModelAssembly : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlAssemblyPermissionSet PermissionSet { get; } = SqlAssemblyPermissionSet.Safe;

        #region ctor{DataSchemaModel}
        public DataSchemaModelAssembly(DataSchemaModel Scope)
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
