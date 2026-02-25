using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlTypeSpecifier")]
    internal class DataSchemaModelTypeSpecifier : DataSchemaModelElement
        {
        public SqlObjectReference Type { get;private set; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Int32? Length { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Int32? Scale { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Int32? Precision { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean? IsMax { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelTypeSpecifier(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
            Type = Relationships[nameof(Type)].References[0];
            }
        #endregion
        }
    }
