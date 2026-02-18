using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlCheckConstraint")]
    internal class DataSchemaModelCheckConstraint : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public String CheckExpressionScript { get;private set; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelCheckConstraint(DataSchemaModel Scope)
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
