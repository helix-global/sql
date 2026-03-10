using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlCreateViewStatement))]
    internal sealed class SqlScriptCreateViewStatement : SqlScriptCreateAlterViewStatementBase<SqlCreateViewStatement>
        {
        #region ctor{IServiceProvider,SqlCreateViewStatement}
        public SqlScriptCreateViewStatement(IServiceProvider context,SqlCreateViewStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }