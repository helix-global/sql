using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptSimpleCaseExpression : SqlScriptCaseExpression<SqlSimpleCaseExpression>
        {
        #region ctor{IServiceProvider,SqlSimpleCaseExpression}
        public SqlScriptSimpleCaseExpression(IServiceProvider context,SqlSimpleCaseExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }