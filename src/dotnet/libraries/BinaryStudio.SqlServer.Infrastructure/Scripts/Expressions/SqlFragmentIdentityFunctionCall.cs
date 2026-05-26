using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(IdentityFunctionCall))]
    internal sealed class SqlFragmentIdentityFunctionCall : SqlFragmentScalarExpression<IdentityFunctionCall>
        {
        #region ctor{IServiceProvider,IdentityFunctionCall}
        public SqlFragmentIdentityFunctionCall(IServiceProvider context,IdentityFunctionCall source)
            : base(context,source)
            {
            }
        #endregion
        }
    }