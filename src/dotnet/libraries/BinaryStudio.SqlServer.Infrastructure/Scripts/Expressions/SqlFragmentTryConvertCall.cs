using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(TryConvertCall))]
    internal sealed class SqlFragmentTryConvertCall : SqlFragmentPrimaryExpression<TryConvertCall>
        {
        #region ctor{IServiceProvider,TryConvertCall}
        public SqlFragmentTryConvertCall(IServiceProvider context,TryConvertCall source)
            : base(context,source)
            {
            }
        #endregion
        }
    }