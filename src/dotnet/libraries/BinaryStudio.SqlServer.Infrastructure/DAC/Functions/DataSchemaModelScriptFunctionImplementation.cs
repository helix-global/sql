using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlScriptFunctionImplementation")]
    internal class DataSchemaModelScriptFunctionImplementation : DataSchemaModelElement,IDataSchemaModelFunctionImplementation
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlScript BodyScript { get; }

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
