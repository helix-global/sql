using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlMultiStatementTableValuedFunction")]
    internal class DataSchemaModelMultiStatementTableValuedFunction : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public Boolean IsAnsiNullsOn { get;private set; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelMultiStatementTableValuedFunction(DataSchemaModel Scope)
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
