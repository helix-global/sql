using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlInlineTableValuedFunction")]
    internal class DataSchemaModelInlineTableValuedFunction : DataSchemaModelTableValuedFunction
        {
        #region ctor{DataSchemaModel}
        public DataSchemaModelInlineTableValuedFunction(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
            return;
            }
        #endregion
        }
    }
