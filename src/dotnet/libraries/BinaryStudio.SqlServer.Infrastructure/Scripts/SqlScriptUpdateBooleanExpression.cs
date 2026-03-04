using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptUpdateBooleanExpression : SqlScriptBooleanExpression<SqlUpdateBooleanExpression>
        {
        #region ctor{IServiceProvider,SqlUpdateBooleanExpression}
        public SqlScriptUpdateBooleanExpression(IServiceProvider context,SqlUpdateBooleanExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }