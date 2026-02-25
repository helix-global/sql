using System;
using System.Collections.Generic;
using System.Text;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlPermissionStatement")]
    internal class DataSchemaModelPermissionStatement : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlPermission Permission { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelPermissionStatement(DataSchemaModel Scope)
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
