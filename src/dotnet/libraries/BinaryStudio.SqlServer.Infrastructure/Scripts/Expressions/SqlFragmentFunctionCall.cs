using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(FunctionCall))]
    internal sealed class SqlFragmentFunctionCall : SqlFragmentPrimaryExpression<FunctionCall>
        {
        #region ctor{IServiceProvider,FunctionCall}
        public SqlFragmentFunctionCall(IServiceProvider context,FunctionCall source)
            : base(context,source)
            {
            }
        #endregion
        }
    }