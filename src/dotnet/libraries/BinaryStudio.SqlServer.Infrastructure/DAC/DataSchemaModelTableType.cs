using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlTableType")]
    [DataSchemaModelSupportedRelationship("Columns")]
    [DataSchemaModelSupportedRelationship("Schema")]
    [DataSchemaModelSupportedRelationship("Constraints")]
    internal class DataSchemaModelTableType : DataSchemaModelElement
        {
        #region ctor{DataSchemaModel}
        public DataSchemaModelTableType(DataSchemaModel Scope)
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
