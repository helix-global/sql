using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlExtendedProperty")]
    internal class DataSchemaModelExtendedProperty : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public SqlScript Value { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelExtendedProperty(DataSchemaModel Scope)
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
