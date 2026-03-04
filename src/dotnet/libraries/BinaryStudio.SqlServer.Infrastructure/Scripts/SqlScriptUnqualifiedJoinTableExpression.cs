using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptUnqualifiedJoinTableExpression : SqlScriptJoinTableExpression<SqlUnqualifiedJoinTableExpression>
        {
        #region ctor{IServiceProvider,SqlUnqualifiedJoinTableExpression}
        public SqlScriptUnqualifiedJoinTableExpression(IServiceProvider context,SqlUnqualifiedJoinTableExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }