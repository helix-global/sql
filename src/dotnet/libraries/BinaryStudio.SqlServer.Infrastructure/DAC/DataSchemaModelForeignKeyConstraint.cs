using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlForeignKeyConstraint")]
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
