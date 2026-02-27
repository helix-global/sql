using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlTableTypeIndexedColumnSpecification")]
    [DataSchemaModelSupportedRelationship(nameof(Column))]
    internal class DataSchemaModelTableTypeIndexedColumnSpecification : DataSchemaModelElement
        {
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference Column { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelTableTypeIndexedColumnSpecification(DataSchemaModel Scope)
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
