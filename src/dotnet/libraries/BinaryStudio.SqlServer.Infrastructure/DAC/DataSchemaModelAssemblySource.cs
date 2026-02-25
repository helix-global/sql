using System;
using System.ComponentModel;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlAssemblySource")]
    internal class DataSchemaModelAssemblySource : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][TypeConverter(typeof(SqlBase32ArrayConverter))][UsedImplicitly] public Byte[] Source { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelAssemblySource(DataSchemaModel Scope)
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
