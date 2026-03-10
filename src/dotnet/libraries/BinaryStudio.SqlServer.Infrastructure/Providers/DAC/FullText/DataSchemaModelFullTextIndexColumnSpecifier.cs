using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlFullTextIndexColumnSpecifier")]
    internal class DataSchemaModelFullTextIndexColumnSpecifier : DataSchemaModelElement
        {
        [PropertyMapping][UsedImplicitly] public Int32 LanguageId { get; }
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference Column { get; }
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference TypeColumn { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelFullTextIndexColumnSpecifier(DataSchemaModel Scope)
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
            return base.ToString();
            }
        #endregion
        }
    }
