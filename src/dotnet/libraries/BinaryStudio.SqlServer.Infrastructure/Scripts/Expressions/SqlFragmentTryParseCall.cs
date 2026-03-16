using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(TryParseCall))]
    internal sealed class SqlFragmentTryParseCall : SqlFragmentPrimaryExpression<TryParseCall>
        {
        #region ctor{IServiceProvider,TryParseCall}
        public SqlFragmentTryParseCall(IServiceProvider context,TryParseCall source)
            : base(context,source)
            {
            }
        #endregion
        }
    }