using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlFullTextIndexColumnSpecifier")]
    internal class DataSchemaModelFullTextIndexColumnSpecifier : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Int32 LanguageId { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelFullTextIndexColumnSpecifier(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
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
