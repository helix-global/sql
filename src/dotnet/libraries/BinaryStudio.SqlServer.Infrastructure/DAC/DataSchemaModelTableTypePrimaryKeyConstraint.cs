using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlTableTypePrimaryKeyConstraint")]
    internal class DataSchemaModelTableTypePrimaryKeyConstraint : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public Boolean IsClustered { get;private set; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelTableTypePrimaryKeyConstraint(DataSchemaModel Scope)
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
