using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlExtendedProperty")]
    internal class DataSchemaModelExtendedProperty : DataSchemaModelElement
        {
        [PropertyMapping][UsedImplicitly] public SqlScript Value { get; }
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
