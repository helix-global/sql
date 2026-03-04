using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptConvertExpression : SqlScriptCastExpression<SqlConvertExpression>
        {
        #region ctor{IServiceProvider,SqlConvertExpression}
        public SqlScriptConvertExpression(IServiceProvider context,SqlConvertExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }