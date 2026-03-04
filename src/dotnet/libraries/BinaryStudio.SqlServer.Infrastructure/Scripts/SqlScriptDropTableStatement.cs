using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptDropTableStatement : SqlScriptDropStatement<SqlDropTableStatement>
        {
        #region ctor{IServiceProvider,SqlDropTableStatement}
        public SqlScriptDropTableStatement(IServiceProvider context,SqlDropTableStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }