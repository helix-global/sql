using System;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlClrFunctionImplementation")]
    internal class DataSchemaModelClrFunctionImplementation : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public Int32 DataAccess { get;private set; } //TODO:: Should be enum!
        [DataSchemaModelPropertyMapping] public Int32 SystemDataAccess { get;private set; } //TODO:: Should be enum!
        [DataSchemaModelPropertyMapping] public String FillRowMethodName { get;private set; }
        [DataSchemaModelPropertyMapping] public String MethodName { get;private set; }
        [DataSchemaModelPropertyMapping] public String ClassName { get;private set; }
        public SqlObjectReference Assembly { get;private set; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelClrFunctionImplementation(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
            Assembly = Relationships["Assembly"].References[0];
            }
        #endregion
        }
    }
