using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlUniqueConstraint))]
    internal sealed class SqlScriptUniqueConstraint : SqlScriptUniqueConstraintBase<SqlUniqueConstraint>
        {
        #region ctor{IServiceProvider,SqlUniqueConstraint}
        public SqlScriptUniqueConstraint(IServiceProvider context,SqlUniqueConstraint source)
            : base(context,source)
            {
            return;
            }
        #endregion
        }
    }