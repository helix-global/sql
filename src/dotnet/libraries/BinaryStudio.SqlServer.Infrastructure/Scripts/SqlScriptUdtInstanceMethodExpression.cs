using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlUdtInstanceMethodExpression))]
    internal sealed class SqlScriptUdtInstanceMethodExpression : SqlScriptUdtInstanceMemberExpression<SqlUdtInstanceMethodExpression>
        {
        #region ctor{IServiceProvider,SqlUdtInstanceMethodExpression}
        public SqlScriptUdtInstanceMethodExpression(IServiceProvider context,SqlUdtInstanceMethodExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }