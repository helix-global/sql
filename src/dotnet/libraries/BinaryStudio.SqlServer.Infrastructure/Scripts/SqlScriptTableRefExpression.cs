using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptTableRefExpression : SqlScriptTableExpression<SqlTableRefExpression>,
        {
        #region ctor{IServiceProvider,SqlTableRefExpression}
        public SqlScriptTableRefExpression(IServiceProvider context,SqlTableRefExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }