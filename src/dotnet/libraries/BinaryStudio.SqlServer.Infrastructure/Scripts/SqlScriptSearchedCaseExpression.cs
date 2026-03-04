using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptSearchedCaseExpression : SqlScriptCaseExpression<SqlSearchedCaseExpression>
        {
        #region ctor{IServiceProvider,SqlSearchedCaseExpression}
        public SqlScriptSearchedCaseExpression(IServiceProvider context,SqlSearchedCaseExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }