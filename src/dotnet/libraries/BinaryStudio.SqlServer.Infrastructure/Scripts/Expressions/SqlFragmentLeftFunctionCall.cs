using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(LeftFunctionCall))]
    internal sealed class SqlFragmentLeftFunctionCall : SqlFragmentPrimaryExpression<LeftFunctionCall>
        {
        #region ctor{IServiceProvider,LeftFunctionCall}
        public SqlFragmentLeftFunctionCall(IServiceProvider context,LeftFunctionCall source)
            : base(context,source)
            {
            }
        #endregion
        }
    }