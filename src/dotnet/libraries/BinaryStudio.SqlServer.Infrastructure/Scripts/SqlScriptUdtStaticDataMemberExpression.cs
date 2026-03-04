using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlUdtStaticDataMemberExpression))]
    internal sealed class SqlScriptUdtStaticDataMemberExpression : SqlScriptUdtStaticMemberExpression<SqlUdtStaticDataMemberExpression>
        {
        #region ctor{IServiceProvider,SqlUdtStaticDataMemberExpression}
        public SqlScriptUdtStaticDataMemberExpression(IServiceProvider context,SqlUdtStaticDataMemberExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }