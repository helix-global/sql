using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlRole")]
    [DataSchemaModelSupportedRelationship("Authorizer")]
    internal class DataSchemaModelRole : DataSchemaModelElement
        {
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
