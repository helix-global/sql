using System;
using System.Collections.Generic;
using System.Diagnostics;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlDatabaseOptions")]
    public class DataSchemaModelDatabaseOptions : DataSchemaModelElement
        {
        [PropertyMapping][UsedImplicitly] public String Collation { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsAnsiPaddingOn { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsQuotedIdentifierOn { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsCursorDefaultScopeGlobal { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsTornPageProtectionOn { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsFullTextEnabled { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsTrustworthyOn { get; }
        [PropertyMapping][UsedImplicitly] public SqlDatabaseRecoveryMode RecoveryMode { get; }
        [PropertyMapping][UsedImplicitly] public SqlQueryStoreOperationState QueryStoreDesiredState { get; }
        [PropertyMapping][UsedImplicitly] public SqlQueryStoreCaptureMode QueryStoreCaptureMode { get; }
        [PropertyMapping][UsedImplicitly] public Int32 QueryStoreMaxStorageSize { get; }
        [PropertyMapping][UsedImplicitly] public Int32 QueryStoreStaleQueryThreshold { get; }
        [PropertyMapping][UsedImplicitly] public Int32 TargetRecoveryTimePeriod { get; }
        [PropertyMapping][UsedImplicitly] public Boolean LegacyCardinalityEstimation { get; }
        [DebuggerBrowsable(DebuggerBrowsableState.Never)] protected internal override IList<DataSchemaModelAnnotation> Annotations { get{ return base.Annotations; }}
        [DebuggerBrowsable(DebuggerBrowsableState.Never)] protected internal override IList<DataSchemaModelElement> Elements { get{ return base.Elements; }}
        [Relationship("0..1")][UsedImplicitly] public SqlObjectReference DefaultFilegroup { get; }

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
