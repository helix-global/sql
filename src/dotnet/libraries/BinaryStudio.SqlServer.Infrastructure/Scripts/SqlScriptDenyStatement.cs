using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlDenyStatement))]
    internal sealed class SqlScriptDenyStatement : SqlScriptGdrStatement<SqlDenyStatement>
        {
        #region ctor{IServiceProvider,SqlDenyStatement}
        public SqlScriptDenyStatement(IServiceProvider context,SqlDenyStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }