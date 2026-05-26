using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(BinaryExpression))]
    internal sealed class SqlFragmentBinaryExpression : SqlFragmentScalarExpression<BinaryExpression>
        {
        #region ctor{IServiceProvider,BinaryExpression}
        public SqlFragmentBinaryExpression(IServiceProvider context,BinaryExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }