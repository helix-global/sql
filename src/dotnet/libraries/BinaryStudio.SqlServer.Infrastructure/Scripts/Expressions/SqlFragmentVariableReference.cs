using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(VariableReference))]
    internal sealed class SqlFragmentVariableReference : SqlFragmentValueExpression<VariableReference>
        {
        #region ctor{IServiceProvider,VariableReference}
        public SqlFragmentVariableReference(IServiceProvider context,VariableReference source)
            : base(context,source)
            {
            }
        #endregion
        }
    }