using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlMultiStatementTableValuedFunction")]
    internal class DataSchemaModelMultiStatementTableValuedFunction : DataSchemaModelTableValuedFunction
        {
        [PropertyMapping][UsedImplicitly] public String ReturnTableVariable { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelMultiStatementTableValuedFunction(DataSchemaModel Scope)
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
