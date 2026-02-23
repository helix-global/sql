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
        [DataSchemaModelAttributeMapping] public Int32? Disambiguator { get;private set; }
        [DataSchemaModelPropertyMapping] public String Collation { get;private set; }
        [DataSchemaModelPropertyMapping] public Boolean IsAnsiPaddingOn { get;private set; }
        [DataSchemaModelPropertyMapping] public Boolean IsQuotedIdentifierOn { get;private set; }
        [DataSchemaModelPropertyMapping] public Boolean IsCursorDefaultScopeGlobal { get;private set; }
        [DataSchemaModelPropertyMapping] public Boolean IsTornPageProtectionOn { get;private set; }
        [DataSchemaModelPropertyMapping] public Boolean IsFullTextEnabled { get;private set; }
        [DataSchemaModelPropertyMapping] public Boolean IsTrustworthyOn { get;private set; }
        [DataSchemaModelPropertyMapping] public SqlDatabaseRecoveryMode RecoveryMode { get;private set; }
        [DataSchemaModelPropertyMapping] public SqlQueryStoreOperationState QueryStoreDesiredState { get;private set; }
        [DataSchemaModelPropertyMapping] public SqlQueryStoreCaptureMode QueryStoreCaptureMode { get;private set; }
        [DataSchemaModelPropertyMapping] public Int32 QueryStoreMaxStorageSize { get;private set; }
        [DataSchemaModelPropertyMapping] public Int32 QueryStoreStaleQueryThreshold { get;private set; }
        [DataSchemaModelPropertyMapping] public Boolean LegacyCardinalityEstimation { get;private set; }
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
