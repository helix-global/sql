using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlClrFunctionImplementation")]
    internal class DataSchemaModelClrFunctionImplementation : DataSchemaModelElement,IDataSchemaModelFunctionImplementation
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlDataAccess DataAccess { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlSystemDataAccess SystemDataAccess { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String FillRowMethodName { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String MethodName { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String ClassName { get; }
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference Assembly { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelClrFunctionImplementation(DataSchemaModel Scope)
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
        public override String ToString() {
            return (SqlObjectIdentifier.Create(
                Assembly.Reference.ObjectName.Value,
                ClassName,
                MethodName)).ToString();
            }
        #endregion
        }
    }
