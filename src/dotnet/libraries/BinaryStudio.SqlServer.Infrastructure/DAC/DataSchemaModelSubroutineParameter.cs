using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlSubroutineParameter")]
    internal class DataSchemaModelSubroutineParameter : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String IsReadOnly { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String IsOutput { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlScript DefaultExpressionScript { get; }
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
