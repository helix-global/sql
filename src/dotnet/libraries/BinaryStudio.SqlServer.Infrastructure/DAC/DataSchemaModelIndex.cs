using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlIndex")]
    internal class DataSchemaModelIndex : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public Int32? FillFactor { get; }
        [DataSchemaModelPropertyMapping] public Boolean IsUnique { get; }
        [DataSchemaModelPropertyMapping] public Boolean IsClustered { get; }
        [DataSchemaModelPropertyMapping] public SqlScript FilterPredicate { get; }

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
