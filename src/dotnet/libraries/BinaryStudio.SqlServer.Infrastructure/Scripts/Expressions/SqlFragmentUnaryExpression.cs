using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(UnaryExpression))]
    internal sealed class SqlFragmentUnaryExpression : SqlFragmentScalarExpression<UnaryExpression>
        {
        #region ctor{IServiceProvider,UnaryExpression}
        public SqlFragmentUnaryExpression(IServiceProvider context,UnaryExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }