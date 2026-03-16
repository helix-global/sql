using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(RightFunctionCall))]
    internal sealed class SqlFragmentRightFunctionCall : SqlFragmentPrimaryExpression<RightFunctionCall>
        {
        #region ctor{IServiceProvider,RightFunctionCall}
        public SqlFragmentRightFunctionCall(IServiceProvider context,RightFunctionCall source)
            : base(context,source)
            {
            }
        #endregion
        }
    }