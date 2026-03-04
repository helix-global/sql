using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptAlterViewStatement : SqlScriptCreateAlterViewStatementBase<SqlAlterViewStatement>
        {
        #region ctor{IServiceProvider,SqlAlterViewStatement}
        public SqlScriptAlterViewStatement(IServiceProvider context,SqlAlterViewStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }