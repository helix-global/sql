using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(PartitionFunctionCall))]
    internal sealed class SqlFragmentPartitionFunctionCall : SqlFragmentPrimaryExpression<PartitionFunctionCall>
        {
        #region ctor{IServiceProvider,PartitionFunctionCall}
        public SqlFragmentPartitionFunctionCall(IServiceProvider context,PartitionFunctionCall source)
            : base(context,source)
            {
            }
        #endregion
        }
    }