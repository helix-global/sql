using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    using SqlTypeSpecifier=IDataSchemaModelTypeSpecifier;
    [DataSchemaModelMapping("SqlSubroutineParameter")]
    [DataSchemaModelSupportedRelationship(nameof(Type))]
    internal class DataSchemaModelSubroutineParameter : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String IsReadOnly { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String IsOutput { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlScript DefaultExpressionScript { get; }
        public SqlTypeSpecifier Type { get;private set; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelSubroutineParameter(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
            Type = (SqlTypeSpecifier)Relationships[nameof(Type)].Elements[0];
            }
        #endregion
        }
    }
