using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlSubroutineParameter")]
    internal class DataSchemaModelSubroutineParameter : DataSchemaModelElement
        {
        [PropertyMapping][UsedImplicitly] public String IsReadOnly { get; }
        [PropertyMapping][UsedImplicitly] public String IsOutput { get; }
        [PropertyMapping][UsedImplicitly] public SqlScript DefaultExpressionScript { get; }
        [Relationship("1..1")][UsedImplicitly] public IDataSchemaModelTypeSpecifier Type { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelSubroutineParameter(DataSchemaModel Scope)
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
