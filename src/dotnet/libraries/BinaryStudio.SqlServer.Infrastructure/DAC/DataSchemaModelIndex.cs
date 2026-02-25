using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlIndex")]
    internal class DataSchemaModelIndex : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Int32? FillFactor { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsUnique { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsClustered { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlScript FilterPredicate { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelIndex(DataSchemaModel Scope)
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
