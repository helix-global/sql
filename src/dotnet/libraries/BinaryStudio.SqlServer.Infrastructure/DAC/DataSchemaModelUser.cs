using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlUser")]
    [DataSchemaModelSupportedRelationship("DefaultSchema")]
    [DataSchemaModelSupportedRelationship("Login")]
    internal class DataSchemaModelUser : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlUserAuthenticationType AuthenticationType { get; }
        //[Relationship("0..1")] public SqlObjectReference DefaultSchema { get; }
        //[Relationship("1..1")] public SqlObjectReference Login { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelUser(DataSchemaModel Scope)
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
