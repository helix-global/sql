using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlFullTextIndex")]
    [DataSchemaModelSupportedRelationship(nameof(Catalog))]
    [DataSchemaModelSupportedRelationship(nameof(Columns))]
    [DataSchemaModelSupportedRelationship(nameof(IndexedObject))]
    [DataSchemaModelSupportedRelationship(nameof(KeyName))]
    internal class DataSchemaModelFullTextIndex : DataSchemaModelElement
        {
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference Catalog { get; }
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference IndexedObject { get; }
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference KeyName { get; }
        [Relationship("1..*")][UsedImplicitly] public IList<DataSchemaModelFullTextIndexColumnSpecifier> Columns { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelFullTextIndex(DataSchemaModel Scope)
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
