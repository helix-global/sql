using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlClrFunctionImplementation")]
    internal class DataSchemaModelClrFunctionImplementation : DataSchemaModelElement,IDataSchemaModelFunctionImplementation
        {
        [PropertyMapping][UsedImplicitly] public SqlDataAccess DataAccess { get; }
        [PropertyMapping][UsedImplicitly] public SqlSystemDataAccess SystemDataAccess { get; }
        [PropertyMapping][UsedImplicitly] public String FillRowMethodName { get; }
        [PropertyMapping][UsedImplicitly] public String MethodName { get; }
        [PropertyMapping][UsedImplicitly] public String ClassName { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsDeterministic { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsPrecise { get; }
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
