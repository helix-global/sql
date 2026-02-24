using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlApplicationRole")]
    internal class DataSchemaModelApplicationRole : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public String Password { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelApplicationRole(DataSchemaModel Scope)
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
