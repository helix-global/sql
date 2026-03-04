using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptBetweenBooleanExpression : SqlScriptBooleanExpression<SqlBetweenBooleanExpression>
        {
        #region ctor{IServiceProvider,SqlBetweenBooleanExpression}
        public SqlScriptBetweenBooleanExpression(IServiceProvider context,SqlBetweenBooleanExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }