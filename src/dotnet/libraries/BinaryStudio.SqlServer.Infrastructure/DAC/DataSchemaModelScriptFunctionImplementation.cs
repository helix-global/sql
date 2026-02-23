using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlScriptFunctionImplementation")]
    internal class DataSchemaModelScriptFunctionImplementation : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public SqlScript BodyScript { get;private set; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelScriptFunctionImplementation(DataSchemaModel Scope)
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
