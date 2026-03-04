using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptUdtStaticMethodExpression : SqlScriptUdtStaticMemberExpression<SqlUdtStaticMethodExpression>
        {
        #region ctor{IServiceProvider,SqlUdtStaticMethodExpression}
        public SqlScriptUdtStaticMethodExpression(IServiceProvider context,SqlUdtStaticMethodExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }