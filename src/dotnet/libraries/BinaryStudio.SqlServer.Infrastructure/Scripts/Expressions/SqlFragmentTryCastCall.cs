using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(TryCastCall))]
    internal sealed class SqlFragmentTryCastCall : SqlFragmentPrimaryExpression<TryCastCall>
        {
        #region ctor{IServiceProvider,TryCastCall}
        public SqlFragmentTryCastCall(IServiceProvider context,TryCastCall source)
            : base(context,source)
            {
            }
        #endregion
        }
    }