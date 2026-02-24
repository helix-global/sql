using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlPermissionStatement")]
    internal class DataSchemaModelPermissionStatement : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public Int32 Permission { get; } //TODO:: May be enum!

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
