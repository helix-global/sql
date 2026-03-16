using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlColumnIdentity))]
    internal class SqlScriptColumnIdentity : SqlScriptConstraint<SqlColumnIdentity>,ISqlColumnIdentity
        {
        [UsedImplicitly][Field] public Int32? Increment { get; }
        [UsedImplicitly][Field] public Int32? Seed { get; }
        [UsedImplicitly][Field] public Boolean NotForReplicationClause { get; }

        #region ctor{IServiceProvider,SqlColumnIdentity}
        public SqlScriptColumnIdentity(IServiceProvider context,SqlColumnIdentity source)
            : base(context,source)
            {
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString() {
            return ToString(DEFConstraintFormatter.Instance);
            }
        #endregion
        #region M:ToString(ISqlObjectFormatter<ISqlConstraint>):String
        public override String ToString(ISqlObjectFormatter<ISqlConstraint> formatter)
            {
            formatter.WriteTo(this,out var r);
            return r;
            }
        #endregion
        }
    }