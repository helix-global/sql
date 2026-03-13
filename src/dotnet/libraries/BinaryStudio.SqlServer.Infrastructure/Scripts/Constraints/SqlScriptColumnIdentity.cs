using System;
using System.Text;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlColumnIdentity))]
    internal class SqlScriptColumnIdentity : SqlScriptConstraint<SqlColumnIdentity>
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
            var r = new StringBuilder();
            r.Append("identity");
            if ((Increment != null) && (Seed != null)) {
                r.Append($"({Seed},{Increment})");
                }
            else if (Seed != null)
                {
                r.Append($"({Seed})");
                }
            return r.ToString();
            }
        #endregion
        }
    }