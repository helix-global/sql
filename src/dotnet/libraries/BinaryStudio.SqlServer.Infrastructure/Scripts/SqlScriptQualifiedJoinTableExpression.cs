using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptQualifiedJoinTableExpression : SqlScriptJoinTableExpression<SqlQualifiedJoinTableExpression>
        {
        #region ctor{IServiceProvider,SqlQualifiedJoinTableExpression}
        public SqlScriptQualifiedJoinTableExpression(IServiceProvider context,SqlQualifiedJoinTableExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }