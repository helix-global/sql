using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlRoleMembership")]
    internal class DataSchemaModelRoleMembership : DataSchemaModelElement
        {
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference Member { get; }
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference Role { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelRoleMembership(DataSchemaModel Scope)
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
        }
    }

