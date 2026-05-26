using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(OdbcFunctionCall))]
    internal sealed class SqlFragmentOdbcFunctionCall : SqlFragmentPrimaryExpression<OdbcFunctionCall>
        {
        #region ctor{IServiceProvider,OdbcFunctionCall}
        public SqlFragmentOdbcFunctionCall(IServiceProvider context,OdbcFunctionCall source)
            : base(context,source)
            {
            }
        #endregion
        }
    }