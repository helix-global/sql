using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlIndex")]
    internal class DataSchemaModelIndex : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public Int32? FillFactor { get;private set; }
        [DataSchemaModelPropertyMapping] public Boolean IsUnique { get;private set; }
        [DataSchemaModelPropertyMapping] public Boolean IsClustered { get;private set; }
        [DataSchemaModelPropertyMapping] public SqlScript FilterPredicate { get;private set; }

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
