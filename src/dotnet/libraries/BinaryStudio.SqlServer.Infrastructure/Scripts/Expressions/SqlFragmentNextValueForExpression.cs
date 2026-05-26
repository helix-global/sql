using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(NextValueForExpression))]
    internal sealed class SqlFragmentNextValueForExpression : SqlFragmentPrimaryExpression<NextValueForExpression>
        {
        #region ctor{IServiceProvider,NextValueForExpression}
        public SqlFragmentNextValueForExpression(IServiceProvider context,NextValueForExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }