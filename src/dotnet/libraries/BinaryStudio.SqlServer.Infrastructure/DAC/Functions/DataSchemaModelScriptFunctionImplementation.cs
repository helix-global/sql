using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlScriptFunctionImplementation")]
    internal class DataSchemaModelScriptFunctionImplementation : DataSchemaModelElement,IDataSchemaModelFunctionImplementation
        {
        [PropertyMapping][UsedImplicitly] public SqlScript BodyScript { get; }

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
