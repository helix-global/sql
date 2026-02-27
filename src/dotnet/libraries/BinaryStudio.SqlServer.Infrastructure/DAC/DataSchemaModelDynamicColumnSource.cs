using System.Collections.Generic;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlDynamicColumnSource")]
    [DataSchemaModelSupportedRelationship(nameof(Columns))]
    internal class DataSchemaModelDynamicColumnSource : DataSchemaModelElement
        {
        [Relationship("1..*")] public IList<IDataSchemaModelColumn> Columns { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelDynamicColumnSource(DataSchemaModel Scope)
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
