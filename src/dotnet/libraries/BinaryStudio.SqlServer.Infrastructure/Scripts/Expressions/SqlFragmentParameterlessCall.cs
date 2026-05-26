using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(ParameterlessCall))]
    internal sealed class SqlFragmentParameterlessCall : SqlFragmentPrimaryExpression<ParameterlessCall>
        {
        #region ctor{IServiceProvider,ParameterlessCall}
        public SqlFragmentParameterlessCall(IServiceProvider context,ParameterlessCall source)
            : base(context,source)
            {
            }
        #endregion
        }
    }