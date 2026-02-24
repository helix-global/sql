using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.Linq;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlDatabaseOptions")]
    public class DataSchemaModelDatabaseOptions : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public String Collation { get; }
        [DataSchemaModelPropertyMapping] public Boolean IsAnsiPaddingOn { get; }
        [DataSchemaModelPropertyMapping] public Boolean IsQuotedIdentifierOn { get; }
        [DataSchemaModelPropertyMapping] public Boolean IsCursorDefaultScopeGlobal { get; }
        [DataSchemaModelPropertyMapping] public Boolean IsTornPageProtectionOn { get; }
        [DataSchemaModelPropertyMapping] public Boolean IsFullTextEnabled { get; }
        [DataSchemaModelPropertyMapping] public Boolean IsTrustworthyOn { get; }
        [DataSchemaModelPropertyMapping] public SqlDatabaseRecoveryMode RecoveryMode { get; }
        [DataSchemaModelPropertyMapping] public SqlQueryStoreOperationState QueryStoreDesiredState { get; }
        [DataSchemaModelPropertyMapping] public SqlQueryStoreCaptureMode QueryStoreCaptureMode { get; }
        [DataSchemaModelPropertyMapping] public Int32 QueryStoreMaxStorageSize { get; }
        [DataSchemaModelPropertyMapping] public Int32 QueryStoreStaleQueryThreshold { get; }
        [DataSchemaModelPropertyMapping] public Boolean LegacyCardinalityEstimation { get; }
        public SqlObjectReference DefaultFilegroup { get;private set; }
        [DebuggerBrowsable(DebuggerBrowsableState.Never)] protected internal override IList<DataSchemaModelAnnotation> Annotations { get{ return base.Annotations; }}
        [DebuggerBrowsable(DebuggerBrowsableState.Never)] protected internal override IList<DataSchemaModelElement> Elements { get{ return base.Elements; }}

        #region ctor{DataSchemaModel}
        public DataSchemaModelDatabaseOptions(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
            DefaultFilegroup = Relationships.FirstOrDefault(i=>i.Value.Name == nameof(DefaultFilegroup)).Value?.References.FirstOrDefault();
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
