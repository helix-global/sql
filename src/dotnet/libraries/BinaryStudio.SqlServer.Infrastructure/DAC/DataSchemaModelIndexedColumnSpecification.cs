using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlIndexedColumnSpecification")]
    [DataSchemaModelSupportedRelationship("Column")]
    internal class DataSchemaModelIndexedColumnSpecification : DataSchemaModelElement
        {
        public SqlObjectReference Column { get;private set; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsAscending { get; } = true;

        #region ctor{DataSchemaModel}
        public DataSchemaModelIndexedColumnSpecification(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
            Column = Relationships[nameof(Column)].References[0];
            }
        #endregion
        #region M:ToString:String
        public override String ToString()
            {
            return Column?.Reference?.ToString()??base.ToString();
            }
        #endregion
        }
    }
