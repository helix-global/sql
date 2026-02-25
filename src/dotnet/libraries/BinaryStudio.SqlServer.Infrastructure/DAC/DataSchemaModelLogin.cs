using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlLogin")]
    internal class DataSchemaModelLogin : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsMappedToWindowsLogin { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsCheckPolicyOn { get; } = true;
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String DefaultLanguage { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String DefaultDatabase { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelLogin(DataSchemaModel Scope)
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

