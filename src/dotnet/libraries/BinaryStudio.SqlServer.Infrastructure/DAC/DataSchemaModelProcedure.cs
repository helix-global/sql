using System;
using System.Collections.Generic;
using System.ComponentModel;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlProcedure")]
    internal class DataSchemaModelProcedure : DataSchemaModelSubroutine
        {
        [PropertyMapping][UsedImplicitly] public SqlScript BodyScript { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsAnsiNullsOn { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsQuotedIdentifierOn { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsRecompiled { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsCaller { get; }=true;
        [PropertyMapping][UsedImplicitly] public String MethodName { get; }
        [PropertyMapping][UsedImplicitly] public String ClassName { get; }
        [Relationship("0..*")][UsedImplicitly] public IList<SqlObjectReference> BodyDependencies { get; }
        [Relationship("0..*")][UsedImplicitly] public IList<DataSchemaModelDynamicColumnSource> DynamicObjects { get; }
        [Relationship("0..1")][UsedImplicitly] public SqlObjectReference Assembly { get;}

        #region ctor{DataSchemaModel}
        public DataSchemaModelProcedure(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
            return;
            }
        #endregion
        #region M:ApplyProperty(PropertyDescriptor,Object)
        protected override void ApplyProperty(PropertyDescriptor target,Object value) {
            switch (target.Name) {
                case nameof(IsAnsiNullsOn):
                    base.ApplyProperty(target,PropB(value,true));
                    break;
                case nameof(IsQuotedIdentifierOn):
                    base.ApplyProperty(target,PropB(value,true));
                    break;
                default:
                    base.ApplyProperty(target, value);
                    break;
                }
            }
        #endregion
        }
    }
