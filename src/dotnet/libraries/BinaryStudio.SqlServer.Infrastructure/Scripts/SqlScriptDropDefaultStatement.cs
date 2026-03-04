using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlDropDefaultStatement))]
    internal sealed class SqlScriptDropDefaultStatement : SqlScriptDropStatement<SqlDropDefaultStatement>
        {
        #region ctor{IServiceProvider,SqlDropDefaultStatement}
        public SqlScriptDropDefaultStatement(IServiceProvider context,SqlDropDefaultStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }