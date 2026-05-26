using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(ExtractFromExpression))]
    internal sealed class SqlFragmentExtractFromExpression : SqlFragmentScalarExpression<ExtractFromExpression>
        {
        #region ctor{IServiceProvider,ExtractFromExpression}
        public SqlFragmentExtractFromExpression(IServiceProvider context,ExtractFromExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }