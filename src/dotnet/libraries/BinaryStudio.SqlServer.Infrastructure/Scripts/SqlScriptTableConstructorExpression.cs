using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptTableConstructorExpression : SqlScriptQueryExpression<SqlTableConstructorExpression>
        {
        #region ctor{IServiceProvider,SqlTableConstructorExpression}
        public SqlScriptTableConstructorExpression(IServiceProvider context,SqlTableConstructorExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }