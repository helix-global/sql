using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptSimpleWhenClause : SqlScriptCodeObject<SqlSimpleWhenClause>
        {
        #region ctor{IServiceProvider,SqlSimpleWhenClause}
        public SqlScriptSimpleWhenClause(IServiceProvider context,SqlSimpleWhenClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }