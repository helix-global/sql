using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlTypeSpecifier")]
    internal class DataSchemaModelTypeSpecifier : DataSchemaModelElement
        {
        public SqlObjectReference Type { get;private set; }
        [DataSchemaModelPropertyMapping] public Int32? Length { get;private set; }

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
