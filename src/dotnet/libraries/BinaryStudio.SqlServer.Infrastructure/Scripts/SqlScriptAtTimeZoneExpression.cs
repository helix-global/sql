using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptAtTimeZoneExpression : SqlScriptScalarExpression<SqlAtTimeZoneExpression>
        {
        #region ctor{IServiceProvider,SqlAtTimeZoneExpression}
        public SqlScriptAtTimeZoneExpression(IServiceProvider context,SqlAtTimeZoneExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }