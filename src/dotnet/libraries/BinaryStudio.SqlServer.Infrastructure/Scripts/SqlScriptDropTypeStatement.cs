using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptDropTypeStatement : SqlScriptDropStatement<SqlDropTypeStatement>
        {
        #region ctor{IServiceProvider,SqlDropTypeStatement}
        public SqlScriptDropTypeStatement(IServiceProvider context,SqlDropTypeStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }