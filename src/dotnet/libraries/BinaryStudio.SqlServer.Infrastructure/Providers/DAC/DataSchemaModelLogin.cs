using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlLogin")]
    internal class DataSchemaModelLogin : DataSchemaModelElement
        {
        [PropertyMapping][UsedImplicitly] public Boolean IsMappedToWindowsLogin { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsCheckPolicyOn { get; } = true;
        [PropertyMapping][UsedImplicitly] public String DefaultLanguage { get; }
        [PropertyMapping][UsedImplicitly] public String DefaultDatabase { get; }

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

