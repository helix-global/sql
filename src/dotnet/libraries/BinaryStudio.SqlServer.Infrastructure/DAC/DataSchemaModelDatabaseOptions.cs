using System;
using System.Collections.Generic;
using System.Diagnostics;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlDatabaseOptions")]
    [DataSchemaModelSupportedRelationship(nameof(DefaultFilegroup))]
    public class DataSchemaModelDatabaseOptions : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String Collation { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsAnsiPaddingOn { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsQuotedIdentifierOn { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsCursorDefaultScopeGlobal { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsTornPageProtectionOn { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsFullTextEnabled { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsTrustworthyOn { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlDatabaseRecoveryMode RecoveryMode { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlQueryStoreOperationState QueryStoreDesiredState { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlQueryStoreCaptureMode QueryStoreCaptureMode { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Int32 QueryStoreMaxStorageSize { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Int32 QueryStoreStaleQueryThreshold { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Int32 TargetRecoveryTimePeriod { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean LegacyCardinalityEstimation { get; }
        [DebuggerBrowsable(DebuggerBrowsableState.Never)] protected internal override IList<DataSchemaModelAnnotation> Annotations { get{ return base.Annotations; }}
        [DebuggerBrowsable(DebuggerBrowsableState.Never)] protected internal override IList<DataSchemaModelElement> Elements { get{ return base.Elements; }}
        [Relationship("0..1")] public SqlObjectReference DefaultFilegroup { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelDatabaseOptions(DataSchemaModel Scope)
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
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return Name??"DatabaseOptions";
            }
        #endregion
        }
    }
