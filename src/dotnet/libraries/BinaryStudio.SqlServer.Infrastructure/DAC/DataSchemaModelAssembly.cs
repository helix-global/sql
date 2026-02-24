using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlAssembly")]
    internal class DataSchemaModelAssembly : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public Int32 PermissionSet { get; } //TODO:: Should be enum!
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
