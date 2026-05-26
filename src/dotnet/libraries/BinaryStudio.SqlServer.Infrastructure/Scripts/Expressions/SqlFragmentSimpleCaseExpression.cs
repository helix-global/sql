using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SimpleCaseExpression))]
    internal sealed class SqlFragmentSimpleCaseExpression : SqlFragmentCaseExpression<SimpleCaseExpression>
        {
        #region ctor{IServiceProvider,SimpleCaseExpression}
        public SqlFragmentSimpleCaseExpression(IServiceProvider context,SimpleCaseExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }