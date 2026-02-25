using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlClrFunctionImplementation")]
    [DataSchemaModelSupportedRelationship("Assembly")]
    internal class DataSchemaModelClrFunctionImplementation : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlDataAccess DataAccess { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlSystemDataAccess SystemDataAccess { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String FillRowMethodName { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String MethodName { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String ClassName { get; }
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
