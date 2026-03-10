using System;
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
        }
    }