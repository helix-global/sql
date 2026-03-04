using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptSelectStarExpression : SqlScriptSelectExpression<SqlSelectStarExpression>
        {
        #region ctor{IServiceProvider,SqlSelectStarExpression}
        public SqlScriptSelectStarExpression(IServiceProvider context,SqlSelectStarExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }