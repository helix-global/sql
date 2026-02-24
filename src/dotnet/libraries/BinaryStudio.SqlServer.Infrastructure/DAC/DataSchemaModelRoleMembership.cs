using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlRoleMembership")]
    internal class DataSchemaModelRoleMembership : DataSchemaModelElement
        {
        #region ctor{DataSchemaModel}
        public DataSchemaModelRoleMembership(DataSchemaModel Scope)
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

