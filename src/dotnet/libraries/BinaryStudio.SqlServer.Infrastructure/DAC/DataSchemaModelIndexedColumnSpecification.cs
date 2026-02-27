using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlIndexedColumnSpecification")]
    [DataSchemaModelSupportedRelationship(nameof(Column))]
    internal class DataSchemaModelIndexedColumnSpecification : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsAscending { get; } = true;
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference Column { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelIndexedColumnSpecification(DataSchemaModel Scope)
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
        #region M:ToString:String
        public override String ToString()
            {
            return Column?.Reference?.ToString()??base.ToString();
            }
        #endregion
        }
    }
