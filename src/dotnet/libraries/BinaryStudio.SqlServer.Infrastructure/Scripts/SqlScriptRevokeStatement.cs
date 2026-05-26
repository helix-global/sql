using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlRevokeStatement))]
    internal sealed class SqlScriptRevokeStatement : SqlScriptGdrStatement<SqlRevokeStatement>
        {
        #region ctor{IServiceProvider,SqlRevokeStatement}
        public SqlScriptRevokeStatement(IServiceProvider context,SqlRevokeStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }