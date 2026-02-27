using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlForeignKeyConstraint")]
    [DataSchemaModelSupportedRelationship(nameof(Columns))]
    [DataSchemaModelSupportedRelationship(nameof(DefiningTable))]
    [DataSchemaModelSupportedRelationship(nameof(ForeignColumns))]
    [DataSchemaModelSupportedRelationship(nameof(ForeignTable))]
    internal class DataSchemaModelForeignKeyConstraint : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlForeignKeyAction OnDeleteAction { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlForeignKeyAction OnUpdateAction { get; }
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference DefiningTable { get; }
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference ForeignTable { get; }
        [Relationship("1..*")][UsedImplicitly] public IList<SqlObjectReference> Columns { get; }
        [Relationship("1..*")][UsedImplicitly] public IList<SqlObjectReference> ForeignColumns { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelForeignKeyConstraint(DataSchemaModel Scope)
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
