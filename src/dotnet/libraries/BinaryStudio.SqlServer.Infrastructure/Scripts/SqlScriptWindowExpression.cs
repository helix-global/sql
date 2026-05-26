using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlWindowExpression))]
    internal sealed class SqlScriptWindowExpression : SqlScriptCodeObject<SqlWindowExpression>
        {
        #region ctor{IServiceProvider,SqlWindowExpression}
        public SqlScriptWindowExpression(IServiceProvider context,SqlWindowExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }