using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptUdtInstanceDataMemberExpression : SqlScriptUdtInstanceMemberExpression<SqlUdtInstanceDataMemberExpression>
        {
        #region ctor{IServiceProvider,SqlUdtInstanceDataMemberExpression}
        public SqlScriptUdtInstanceDataMemberExpression(IServiceProvider context,SqlUdtInstanceDataMemberExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }