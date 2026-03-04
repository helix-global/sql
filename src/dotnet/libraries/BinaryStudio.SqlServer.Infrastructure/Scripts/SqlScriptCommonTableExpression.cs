using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptCommonTableExpression : SqlScriptTableExpression<SqlCommonTableExpression>
        {
        #region ctor{IServiceProvider,SqlCommonTableExpression}
        public SqlScriptCommonTableExpression(IServiceProvider context,SqlCommonTableExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }