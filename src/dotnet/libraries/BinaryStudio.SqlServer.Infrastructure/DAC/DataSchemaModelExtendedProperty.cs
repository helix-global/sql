using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlExtendedProperty")]
    internal class DataSchemaModelExtendedProperty : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlScript Value { get; }
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference Host { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelExtendedProperty(DataSchemaModel Scope)
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
