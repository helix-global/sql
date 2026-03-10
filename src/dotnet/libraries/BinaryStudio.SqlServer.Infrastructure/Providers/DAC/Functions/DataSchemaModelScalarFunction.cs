using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlScalarFunction")]
    internal class DataSchemaModelScalarFunction : DataSchemaModelFunction
        {
        [PropertyMapping][UsedImplicitly] public Boolean IsInline { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsInlineable { get; }
        [Relationship("1..1")][UsedImplicitly] public IDataSchemaModelTypeSpecifier Type { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelScalarFunction(DataSchemaModel Scope)
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
